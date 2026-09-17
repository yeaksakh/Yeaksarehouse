import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../state/server_config.dart';
import '../state/session_controller.dart';
import '../theme/app_theme.dart';

/// Username and password of the person's yeaksa.com staff account -- the same
/// one they use on the website, so there is no second login to hand out.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  /// The logo, which three quick taps turn into the server picker.
  static const logoKey = Key('login-logo');

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Taps on the logo needed to reach the server picker.
  static const _tapsToReveal = 3;

  /// How long a tap keeps counting towards the sequence.
  static const _tapWindow = Duration(seconds: 2);

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  int _logoTaps = 0;
  Timer? _tapWindowTimer;

  @override
  void dispose() {
    _tapWindowTimer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = context.read<SessionController>();
    if (session.busy) return;
    await session.signIn(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  /// Deliberately undiscoverable: three quick taps on the logo open the server
  /// picker, so testers can point a build at staging or an on-site server
  /// without a settings screen staff might wander into.
  void _onLogoTap() {
    // Nothing to reveal when this build has only one server it may use, so
    // opening a picker that cannot save would read as broken.
    if (!ServerConfig.canOverride) return;

    _tapWindowTimer?.cancel();
    _logoTaps++;

    if (_logoTaps >= _tapsToReveal) {
      _logoTaps = 0;
      _openServerPicker();
      return;
    }

    _tapWindowTimer = Timer(_tapWindow, () => _logoTaps = 0);
  }

  Future<void> _openServerPicker() async {
    // Resolved before the dialog: after it closes this context may be gone,
    // and looking it up then is the classic async-gap bug.
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<String>(
      context: context,
      builder: (_) => const _ServerDialog(),
    );
    if (saved == null) return;
    messenger.showSnackBar(SnackBar(content: Text('Server set to $saved')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<SessionController>();
    final server = context.watch<ServerConfig>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        // The logo's blue, top to bottom, with the form on a white sheet.
        decoration: BoxDecoration(gradient: heroGradient(AppTheme.seed)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      key: LoginScreen.logoKey,
                      onTap: _onLogoTap,
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55000000),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            semanticLabel: 'Yeaksarehouse',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Yeaksarehouse',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.signInWithStaffAccount,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withAlpha(215)),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _usernameController,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        labelText: l10n.username,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip:
                              _showPassword ? l10n.hidePassword : l10n.showPassword,
                          icon: Icon(_showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                    if (session.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          session.error!,
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: session.busy ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.seed,
                        minimumSize: const Size.fromHeight(56),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: session.busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.signIn),
                    ),
                    // Only worth the space once someone has moved off
                    // yeaksa.com, where signing in to the wrong server is easy
                    // to forget.
                    if (!server.isDefault) ...[
                      const SizedBox(height: 12),
                      Text(
                        server.baseUrl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Picks the server. Pops the saved URL, or null if nothing changed.
class _ServerDialog extends StatefulWidget {
  const _ServerDialog();

  @override
  State<_ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<_ServerDialog> {
  /// The preset that is ticked, or null while a typed address is in play.
  String? _choice;

  late final TextEditingController _url;
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = context.read<ServerConfig>().baseUrl;
    _choice = ServerConfig.isPreset(current) ? current : null;
    // Seeded with the live address either way, so choosing "Other" starts from
    // something that already works rather than an empty field.
    _url = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  /// Null selects "Other" and hands the choice to the text field.
  void _select(String? url) {
    setState(() {
      _choice = url;
      _error = null;
      if (url != null) _url.text = url;
    });
  }

  Future<void> _save() async {
    final config = context.read<ServerConfig>();
    final problem = await config.setBaseUrl(_choice ?? _url.text);
    if (!mounted) return;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    Navigator.of(context).pop(config.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.server),
      // maxFinite, not a fixed width: the rows want the dialog's full width,
      // and a hard number would overflow the narrowest handsets.
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final preset in ServerConfig.presets)
                _ServerTile(
                  title: preset.name,
                  subtitle: preset.url == ServerConfig.defaultUrl
                      ? '${preset.url}  \u00b7  Default'
                      : preset.url,
                  selected: _choice == preset.url,
                  onTap: () => _select(preset.url),
                ),
              // Free-form entry is a development tool; a release build offers
              // the shops above and nothing else. See ServerConfig.
              if (ServerConfig.canEnterCustomHost) ...[
                _ServerTile(
                  title: l10n.other,
                  selected: _choice == null,
                  onTap: () => _select(null),
                ),
                if (_choice == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      controller: _url,
                      autofocus: true,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: l10n.serverAddress,
                        errorText: _error,
                        prefixIcon: const Icon(Icons.dns_outlined),
                      ),
                    ),
                  ),
              ],
              // A preset can still be refused (a release build that no longer
              // lists it), and there is no field to hang the reason on.
              if (_error != null && _choice != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 12, color: scheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// One row of the picker. A tick rather than a radio: `Radio.groupValue` is
/// deprecated on this Flutter, and the list is short enough that a check mark
/// reads the same.
class _ServerTile extends StatelessWidget {
  const _ServerTile({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      selected: selected,
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(fontSize: 12)),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? scheme.primary : scheme.outlineVariant,
      ),
    );
  }
}
