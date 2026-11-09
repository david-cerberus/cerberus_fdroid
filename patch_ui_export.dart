import 'dart:io';

void main() {
  final file = File('lib/screens/home_screen.dart');
  String code = file.readAsStringSync();

  // 1. Change onExportUnified signature
  code = code.replaceFirst(
    'final Future<void> Function(String)? onExportUnified;',
    'final Future<void> Function(String, {String? password})? onExportUnified;'
  );

  // 2. Change _showExportDialog content
  final oldExportDialog = '''  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportData),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.data_object_rounded, color: Colors.purpleAccent),
                title: Text(AppLocalizations.of(context)!.exportToKdbx),
                onTap: () { Navigator.pop(context); if (widget.onExportUnified != null) widget.onExportUnified!('kdbx'); },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.key_rounded, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.exportTo1pux),
                onTap: () { Navigator.pop(context); if (widget.onExportUnified != null) widget.onExportUnified!('1pux'); },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.code_rounded, color: Colors.orange),
                title: Text(AppLocalizations.of(context)!.exportToJsonEncrypted),
                onTap: () { Navigator.pop(context); if (widget.onExportUnified != null) widget.onExportUnified!('cjson'); },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.description_rounded, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.exportXml),
                onTap: () { Navigator.pop(context); _handleExportXml(); },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded, color: Colors.green),
                title: Text(AppLocalizations.of(context)!.exportCsv),
                onTap: () { Navigator.pop(context); _handleExportCsv(); },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }''';

  final newExportDialog = '''  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportData),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.data_object_rounded, color: Colors.purpleAccent),
                title: Text(AppLocalizations.of(context)!.exportToKdbx),
                onTap: () { 
                  Navigator.pop(context); 
                  _showKdbxPasswordDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.code_rounded, color: Colors.orange),
                title: Text(AppLocalizations.of(context)!.exportToJson),
                onTap: () { 
                  Navigator.pop(context); 
                  _showJsonExportDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.description_rounded, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.exportXml),
                onTap: () { Navigator.pop(context); _handleExportXml(); },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded, color: Colors.green),
                title: Text(AppLocalizations.of(context)!.exportCsv),
                onTap: () { Navigator.pop(context); _handleExportCsv(); },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showJsonExportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportToJson),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.exportJsonRecommended),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordForFile,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onExportUnified != null) {
                widget.onExportUnified!('json', password: null);
              }
            },
            child: Text(AppLocalizations.of(context)!.exportJsonPlainBtn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              if (widget.onExportUnified != null) {
                widget.onExportUnified!('cjson', password: controller.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.exportJsonSecureBtn),
          ),
        ],
      ),
    );
  }

  void _showKdbxPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.exportToKdbx),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.exportKdbxDesc),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordForFile,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              if (widget.onExportUnified != null) {
                widget.onExportUnified!('kdbx', password: controller.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.exportToKdbx),
          ),
        ],
      ),
    );
  }''';

  code = code.replaceFirst(oldExportDialog, newExportDialog);
  file.writeAsStringSync(code);
  print('home_screen.dart export flow patched.');
}
