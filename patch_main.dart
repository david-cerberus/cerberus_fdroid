import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  String code = file.readAsStringSync();

  // 1. Add import for path_provider if missing
  if (!code.contains('package:path_provider/path_provider.dart')) {
    code = code.replaceFirst(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\nimport 'package:path_provider/path_provider.dart';"
    );
  }

  // 2. Add _handleExportUnified
  final handleExportStr = '''  Future<void> _handleExportUnified(String format) async {
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
    );

    try {
      final entries = await _dbHelper.getAllEntries();
      final credEntries = entries.map((e) => CredentialEntry(
        id: e.id,
        title: e.title,
        username: e.username,
        password: e.password.isNotEmpty ? Uint8List.fromList(utf8.encode(e.password)) : null,
        urls: e.url.isNotEmpty ? [e.url] : [],
        notes: e.notes,
        categories: e.folder.isNotEmpty ? [e.folder] : [],
        customFields: e.customFields.map((cf) {
          final isProtected = cf['isProtected'] == true || cf['isSecure'] == true;
          return CustomField(name: cf['name']?.toString() ?? '', value: cf['value']?.toString() ?? '', isProtected: isProtected);
        }).toList(),
        createdAt: e.createdAt,
        modifiedAt: e.updatedAt,
      )).toList();

      final tempDir = await getTemporaryDirectory();
      final tempPath = '\${tempDir.path}/export_temp.\$format';
      
      final File exportedFile = await _importExportService.exportFile(credEntries, tempPath, password: password);
      final bytes = await exportedFile.readAsBytes();

      if (mounted) Navigator.pop(context); // close waiting dialog

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Exportar a \$format',
        fileName: 'cerberus_export.\$format',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: [format],
      );

      if (path != null) {
        if (!Platform.isAndroid && !Platform.isIOS) {
          final destFile = File(path);
          await destFile.writeAsBytes(bytes);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exportación completada con éxito'), backgroundColor: Colors.green),
          );
        }
      }
      
      if (await exportedFile.exists()) {
        await exportedFile.delete();
      }

    } catch (e) {
      if (mounted) Navigator.pop(context); // close waiting dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: \$e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _handleCsvImport() async {''';

  code = code.replaceFirst('  Future<void> _handleCsvImport() async {', handleExportStr);

  // 3. Add to HomeScreen instantiation
  code = code.replaceFirst(
    '        onCsvImport: _handleCsvImport,',
    '        onCsvImport: _handleCsvImport,\n        onExportUnified: _handleExportUnified,'
  );

  file.writeAsStringSync(code);
  print('main.dart patched successfully.');
}
