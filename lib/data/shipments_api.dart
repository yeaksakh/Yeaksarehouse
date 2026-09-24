import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fulfilment_stage.dart';
import '../models/box_label.dart';
import '../models/order.dart';
import '../models/stock_item.dart';
import '../state/server_config.dart';

/// A shipment request that did not work, with a message fit to show as is.
class ShipmentsException implements Exception {
  ShipmentsException(this.message, {this.status, this.code});

  final String message;

  /// The HTTP status, when the server answered at all.
  final int? status;

  /// The server's machine-readable reason, e.g. `taken` or `items_not_packed`.
  final String? code;

  /// The session is gone -- revoked, expired, or the account was switched off.
  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}

/// One tab's worth of shipments, and how many sit at every status.
class ShipmentPage {
  const ShipmentPage({required this.orders, required this.counts, this.ridersCount});

  final List<Order> orders;
  final Map<FulfilmentStage, int> counts;

  /// The Riders tab's count (`counts.riders`); null from an older server.
  final int? ridersCount;
}

/// The website's /shipments page, for this app: `core/api/views_shipments.py`.
///
/// Every call carries the Bearer token from `/api/auth/login`, so the server
/// applies that person's own permissions and records them as the one who
/// accepted, packed or moved each shipment.
class ShipmentsApi {
  ShipmentsApi({
    String Function()? baseUrl,
    String? Function()? token,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
  })  : _baseUrl = baseUrl ?? (() => ServerConfig.defaultUrl),
        _token = token ?? (() => null),
        _http = httpClient ?? http.Client();

  /// Both read on every request, so a changed server or a new sign-in is used
  /// at once.
  final String Function() _baseUrl;
  final String? Function() _token;
  final Duration timeout;
  final http.Client _http;

  /// Shipments at [stage], newest first, as the website lists them.
  ///
  /// Not oldest first, although a queue is worked front to back: the live book
  /// holds thousands of `ordered` sales going back years that nobody will ever
  /// pack, and oldest first put those at the top of every shift.
  Future<ShipmentPage> list(FulfilmentStage stage,
          {int limit = 100, String query = ''}) =>
      _page(stage.apiValue, limit, query);

  /// The Riders tab: shipments a rider has taken and not finished, plus the
  /// ones delivered today, each with the rider's latest step.
  ///
  /// [query] is the server's `q`: invoice number, customer name or mobile,
  /// searched over the whole book rather than only the loaded page.
  Future<ShipmentPage> riders({int limit = 100, String query = ''}) =>
      _page('riders', limit, query);

  Future<ShipmentPage> _page(String status, int limit, String query) async {
    final body = await _send('GET', '/api/shipments', query: {
      'status': status,
      'limit': '$limit',
      if (query.isNotEmpty) 'q': query,
    });
    final counts = <FulfilmentStage, int>{};
    final raw = body['counts'];
    if (raw is Map) {
      raw.forEach((key, value) {
        final status = stageFromApiOrNull(key);
        if (status != null && value is num) counts[status] = value.toInt();
      });
    }
    final rows = body['data'];
    return ShipmentPage(
      orders: rows is List
          ? rows.whereType<Map<String, dynamic>>().map(Order.fromApi).toList()
          : const [],
      counts: counts,
      ridersCount: raw is Map && raw['riders'] is num
          ? (raw['riders'] as num).toInt()
          : null,
    );
  }

  /// The business's stock-tracked products with what is on hand at each branch,
  /// from `GET /api/stock?tracked=1`, page by page (the server caps a page at 200).
  Future<List<StockItem>> stock({int pageSize = 200, int max = 6000}) async {
    final out = <StockItem>[];
    for (var offset = 0; offset < max; offset += pageSize) {
      final body = await _send('GET', '/api/stock', query: {
        'tracked': '1',
        'limit': '$pageSize',
        'offset': '$offset',
      });
      final rows = body['data'];
      if (rows is! List || rows.isEmpty) break;
      out.addAll(rows.whereType<Map<String, dynamic>>().map(StockItem.fromApi));
      if (rows.length < pageSize) break;
    }
    return out;
  }

  /// One shipment with its items, who packed each, and its photos.
  /// The box stickers as DATA, for drawing on the phone.
  ///
  /// What a Bluetooth thermal printer needs: it takes raster rows, not a PDF,
  /// so the sticker is drawn here. The server still decides how many stickers
  /// and what is on each, so both printing paths agree on the arithmetic.
  Future<LabelSheet> labelData(String id) async {
    final body = await _send('GET', '/api/shipments/$id/labels',
        query: const {'format': 'json'});
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw ShipmentsException(
          'The server sent something the app could not read.');
    }
    return LabelSheet.fromApi(data);
  }

  /// The box stickers for one shipment, as a PDF.
  ///
  /// The same sheet the website prints, from the same template. Handed to the
  /// platform's print service by the caller rather than drawn in Dart, so there
  /// is one label layout to keep correct instead of two.
  ///
  /// Not routed through [_send]: that decodes JSON, and a PDF fed through it
  /// would fail to parse -- losing the real reason ("not signed in", "nothing
  /// to label") behind a decode error. A FAILING request does answer in JSON,
  /// so that case is decoded here and raised with the server's own wording.
  Future<Uint8List> labels(String id) async {
    final uri = Uri.parse('${_baseUrl()}/api/shipments/$id/labels');
    final token = _token();
    final http.Response response;
    try {
      response = await _http.get(uri, headers: {
        'Accept': 'application/pdf',
        if (token != null) 'Authorization': 'Bearer $token',
      }).timeout(timeout);
    } on TimeoutException {
      throw ShipmentsException('The labels took too long to prepare.');
    } catch (_) {
      throw ShipmentsException('Could not reach the server.');
    }

    final type = response.headers['content-type'] ?? '';
    if (response.statusCode == 200 && !type.contains('json')) {
      return response.bodyBytes;
    }
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ShipmentsException(
          (body['message'] as String?) ?? 'The labels could not be prepared.');
    } on FormatException {
      throw ShipmentsException('The labels could not be prepared.');
    }
  }

  Future<Order> detail(String id) async =>
      _order(await _send('GET', '/api/shipments/$id'));

  /// Take an ordered shipment to pack.
  Future<Order> accept(String id) async =>
      _order(await _send('POST', '/api/shipments/$id/accept'));

  /// Hand back a shipment accepted by mistake, before anything is ticked.
  Future<Order> release(String id) async =>
      _order(await _send('POST', '/api/shipments/$id/release'));

  /// Tick an item into the box, or untick it.
  Future<Order> packLine(String id, String lineId,
          {required bool packed}) async =>
      _order(await _send('POST', '/api/shipments/$id/lines/$lineId/pack',
          body: {'packed': packed}));

  /// Move a shipment on: to `packed`, or to `audited`.
  Future<Order> setStatus(String id, FulfilmentStage stage) async =>
      _order(await _send('POST', '/api/shipments/$id/status',
          body: {'status': stage.apiValue}));

  Order _order(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw ShipmentsException(
          'The server sent something the app could not read.');
    }
    return Order.fromApi(data);
  }

  /// Files a photo against a shipment, as the website files a shipping document.
  ///
  /// Multipart `photo`; the server tags it with the status the shipment is about
  /// to enter, which for a packed one is the audit.
  Future<void> uploadPhoto(String id, String filePath) async {
    final token = _token();
    final request = http.MultipartRequest(
        'POST', Uri.parse('${_baseUrl()}/api/shipments/$id/photo'))
      ..headers['Accept'] = 'application/json'
      ..files.add(await http.MultipartFile.fromPath('photo', filePath));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final http.Response response;
    try {
      // A picture takes longer than a JSON call on a phone plan.
      response = await http.Response.fromStream(
          await _http.send(request).timeout(timeout * 3));
    } on TimeoutException {
      throw ShipmentsException(
          'The upload took too long. Check your internet and try again.');
    } on Exception {
      throw ShipmentsException(
          'Could not reach the server. Check your internet and try again.');
    }
    _decode(response);
  }

  /// Sends one request and returns the body of a `{"success": true}` answer.
  ///
  /// Failures arrive as `{"success": false, "message": ...}` with a real HTTP
  /// status, and the message is already written for the person holding the
  /// phone -- "Already accepted by Sok Dara." -- so it is shown as it comes.
  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, Object?>? body,
  }) async {
    final uri = Uri.parse('${_baseUrl()}$path').replace(queryParameters: query);
    final token = _token();
    final headers = {
      'Accept': 'application/json',
      if (method != 'GET') 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final http.Response response;
    try {
      final request = method == 'GET'
          ? _http.get(uri, headers: headers)
          : _http.post(uri,
              headers: headers, body: jsonEncode(body ?? const {}));
      response = await request.timeout(timeout);
    } on TimeoutException {
      throw ShipmentsException(
          'The server took too long to answer. Pull down to try again.');
    } on Exception {
      throw ShipmentsException(
          'Could not reach the server. Check your internet and try again.');
    }

    return _decode(response);
  }

  /// Reads a `{"success": true}` answer, or throws with the server's own words.
  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? decoded;
    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is Map<String, dynamic>) decoded = value;
    } on FormatException {
      // An HTML page; reported below.
    }
    if (decoded == null) {
      throw ShipmentsException(
        response.statusCode == 404
            // The likeliest cause: a server that has not been given these
            // endpoints yet, or the wrong server address.
            ? 'This server has no shipments API yet. Check the server address.'
            : 'The server sent something the app could not read.',
        status: response.statusCode,
      );
    }
    if (decoded['success'] != true) {
      throw ShipmentsException(
        (decoded['message'] as String?) ?? 'Something went wrong.',
        status: response.statusCode,
        code: decoded['error'] as String?,
      );
    }
    return decoded;
  }
}
