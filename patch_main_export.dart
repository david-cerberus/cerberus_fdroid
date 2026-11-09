import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  String code = file.readAsStringSync();

  // 1. Change _handleExportUnified signature and remove _askForImportPassword for KDBX/CJSON inside since password is passed
  final oldHandleExport = '''  Future<void> _handleExportUnified(String format) async {
    final auth = LocalAuthentication();
    bool authenticated = false;
    try {
      final canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.biometricRequiredExport), backgroundColor: Colors.redAccent),
          );
        }
        return;
      }
      authenticated = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.biometricReasonExport,
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.authError(e.toString())), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.authFailed), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    String? password;
    if (['kdbx', 'cjson'].contains(format)) {
      password = await _askForImportPassword();
      if (password == null || password.isEmpty) return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exportando...'),
        content: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Generando archivo...'),
          ],
        ),
      ),
    );''';

  final newHandleExport = '''  Future<void> _handleExportUnified(String format, {String? password}) async {
    final auth = LocalAuthentication();
    bool authenticated = false;
    try {
      final canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.biometricRequiredExport), backgroundColor: Colors.redAccent),
          );
        }
        return;
      }
      authenticated = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.biometricReasonExport,
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.authError(e.toString())), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.authFailed), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exportando...'),
        content: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Generando archivo...'),
          ],
        ),
      ),
    );''';

  code = code.replaceFirst(oldHandleExport, newHandleExport);
  file.writeAsStringSync(code);
  print('main.dart export flow patched.');
}
