import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warehouse/data/shipments_api.dart';

ShipmentsApi apiThatAnswers(http.Response Function(http.Request) answer) =>
    ShipmentsApi(
      baseUrl: () => 'https://yeaksa.test',
      token: () => 'tok',
      httpClient: MockClient((request) async => answer(request)),
    );

final _pdf = Uint8List.fromList(utf8.encode('%PDF-1.7 fake'));

void main() {
  group('fetching the label sheet', () {
    test('returns the bytes when the server sends a PDF', () async {
      final api = apiThatAnswers((_) => http.Response.bytes(
          _pdf, 200, headers: {'content-type': 'application/pdf'}));

      final bytes = await api.labels('118');

      expect(bytes, _pdf);
    });

    test('asks the right endpoint, with the token', () async {
      late http.Request seen;
      final api = apiThatAnswers((r) {
        seen = r;
        return http.Response.bytes(_pdf, 200,
            headers: {'content-type': 'application/pdf'});
      });

      await api.labels('118');

      expect(seen.url.path, '/api/shipments/118/labels');
      expect(seen.headers['Authorization'], 'Bearer tok');
    });

    test('a JSON refusal is raised with the server wording, not a parse error',
        () async {
      // The whole reason this does not go through _send: a PDF cannot be
      // decoded as JSON, and the real reason would be lost behind that.
      final api = apiThatAnswers((_) => http.Response(
          jsonEncode({
            'success': false,
            'status': 409,
            'code': 'nothing_to_label',
            'message': 'This shipment has nothing to label.'
          }),
          409,
          headers: {'content-type': 'application/json'}));

      expect(
        () => api.labels('118'),
        throwsA(isA<ShipmentsException>().having(
            (e) => e.toString(), 'message', contains('nothing to label'))),
      );
    });

    test('a 200 that is secretly JSON is still treated as a failure', () async {
      // This API answers some failures with HTTP 200 and the real status in the
      // envelope, so the content type decides, not the status code.
      final api = apiThatAnswers((_) => http.Response(
          jsonEncode({'success': false, 'message': 'Sign in to continue.'}), 200,
          headers: {'content-type': 'application/json'}));

      expect(() => api.labels('118'), throwsA(isA<ShipmentsException>()));
    });

    test('an unreachable server is reported plainly', () async {
      final api = ShipmentsApi(
        baseUrl: () => 'https://yeaksa.test',
        token: () => 'tok',
        httpClient: MockClient(
            (_) async => throw http.ClientException('Failed host lookup')),
      );

      expect(
        () => api.labels('118'),
        throwsA(isA<ShipmentsException>()
            .having((e) => e.toString(), 'message', contains('reach'))),
      );
    });

    test('a body that is neither PDF nor JSON does not crash the screen',
        () async {
      final api = apiThatAnswers((_) =>
          http.Response('<html>502</html>', 502, headers: {'content-type': 'text/html'}));

      expect(() => api.labels('118'), throwsA(isA<ShipmentsException>()));
    });
  });
}
