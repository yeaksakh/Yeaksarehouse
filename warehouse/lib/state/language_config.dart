import 'package:flutter/material.dart';

import '../data/local_store.dart';

/// Which language the app is in.
///
/// Defaults to **Khmer**, not to the phone's locale. The people using this are
/// packers on a warehouse floor in Cambodia, and the ERP's own data -- product
/// names, customer names, notes -- comes back in Khmer whatever the handset is
/// set to. A shared phone that happens to be in English should still open to
/// something the person holding it can read. English stays available because
/// the shop's own staff and this app's tests use it.
///
/// Mirrors the rider app (`delivery_boy`) deliberately: same key shape, same
/// default, same toggle, so somebody who has read one already knows this.
class LanguageConfig extends ChangeNotifier {
  LanguageConfig({LocalStore? store, Locale? initial})
      : _store = store,
        _locale = initial ?? khmer {
    // An explicit choice wins outright: it is what tests pass to assert against
    // the English source strings, and reading the saved one over it would make
    // them depend on whatever the last run left on disk.
    if (initial == null) _restore();
  }

  static const khmer = Locale('km');
  static const english = Locale('en');

  /// Every locale this app ships strings for.
  static const supported = [khmer, english];

  final LocalStore? _store;

  Locale _locale;
  Locale get locale => _locale;

  bool get isKhmer => _locale.languageCode == khmer.languageCode;

  Future<void> setLocale(Locale value) async {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
    await _store?.saveLanguage(value.languageCode);
  }

  Future<void> toggle() => setLocale(isKhmer ? english : khmer);

  Future<void> _restore() async {
    final saved = await _store?.loadLanguage();
    if (saved == null) return;
    final match = supported.firstWhere(
      (locale) => locale.languageCode == saved,
      // A stored code this build no longer ships strings for falls back to the
      // default rather than leaving the app half-translated.
      orElse: () => khmer,
    );
    if (match == _locale) return;
    _locale = match;
    notifyListeners();
  }
}
