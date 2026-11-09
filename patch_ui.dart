import 'dart:io';

void main() {
  final homeScreenFile = File('lib/screens/home_screen.dart');
  String homeScreenCode = homeScreenFile.readAsStringSync();

  // 1. Add onExportUnified to HomeScreen
  homeScreenCode = homeScreenCode.replaceFirst(
    '  final VoidCallback onCsvImport;',
    '  final VoidCallback onCsvImport;\n  final Future<void> Function(String)? onExportUnified;'
  );
  
  homeScreenCode = homeScreenCode.replaceFirst(
    '    required this.onCsvImport,',
    '    required this.onCsvImport,\n    this.onExportUnified,'
  );

  // 2. Replace _showCsvActionsDialog
  final dialogToReplace = '''  void _showCsvActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.csvActionsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_open_rounded, color: Colors.blueAccent),
              title: Text(AppLocalizations.of(context)!.importCsv),
              onTap: () {
                Navigator.pop(context);
                widget.onCsvImport();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_upload_rounded, color: Colors.green),
              title: Text(AppLocalizations.of(context)!.exportCsv),
              onTap: () {
                Navigator.pop(context);
                _handleExportCsv();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.data_object_rounded, color: Colors.purpleAccent),
              title: Text(AppLocalizations.of(context)!.exportXml),
              onTap: () {
                Navigator.pop(context);
                _handleExportXml();
              },
            ),
          ],
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

  final newDialogs = '''  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.importData),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_open_rounded, color: Colors.blueAccent),
              title: Text(AppLocalizations.of(context)!.importDataSubtitle),
              onTap: () {
                Navigator.pop(context);
                widget.onCsvImport();
              },
            ),
          ],
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

  void _showExportDialog() {
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

  homeScreenCode = homeScreenCode.replaceFirst(dialogToReplace, newDialogs);

  // 3. Replace popup menu items inside onSelected
  homeScreenCode = homeScreenCode.replaceFirst(
    "if (value == 'csv_actions') {",
    "if (value == 'import_actions') {\n" +
    "                        if (!isPremiumNotifier.value) {\n" +
    "                          showDialog(context: context, builder: (context) => const PremiumPurchaseDialog());\n" +
    "                          return;\n" +
    "                        }\n" +
    "                        _showImportDialog();\n" +
    "                      } else if (value == 'export_actions') {\n" +
    "                        if (!isPremiumNotifier.value) {\n" +
    "                          showDialog(context: context, builder: (context) => const PremiumPurchaseDialog());\n" +
    "                          return;\n" +
    "                        }\n" +
    "                        _showExportDialog();\n" +
    "                      } else if (value == 'csv_actions') {"
  );

  // 4. Replace PopupMenuItem
  final popupItemToReplace = '''                        PopupMenuItem(
                          value: 'csv_actions',
                          child: Row(
                            children: [
                              const Icon(Icons.import_export_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.csvActionsTitle),
                              ),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<bool>(
                                valueListenable: isPremiumNotifier,
                                builder: (context, isPremium, child) {
                                  if (isPremium) return const SizedBox.shrink();
                                  return Image.asset(
                                    'assets/icon/premium_shield.png',
                                    width: 18,
                                    height: 18,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),''';

  final newPopupItems = '''                        PopupMenuItem(
                          value: 'import_actions',
                          child: Row(
                            children: [
                              const Icon(Icons.file_download_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.importData),
                              ),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<bool>(
                                valueListenable: isPremiumNotifier,
                                builder: (context, isPremium, child) {
                                  if (isPremium) return const SizedBox.shrink();
                                  return Image.asset(
                                    'assets/icon/premium_shield.png',
                                    width: 18,
                                    height: 18,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'export_actions',
                          child: Row(
                            children: [
                              const Icon(Icons.file_upload_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.exportData),
                              ),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<bool>(
                                valueListenable: isPremiumNotifier,
                                builder: (context, isPremium, child) {
                                  if (isPremium) return const SizedBox.shrink();
                                  return Image.asset(
                                    'assets/icon/premium_shield.png',
                                    width: 18,
                                    height: 18,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),''';

  homeScreenCode = homeScreenCode.replaceFirst(popupItemToReplace, newPopupItems);

  homeScreenFile.writeAsStringSync(homeScreenCode);
  print('home_screen.dart patched successfully.');
}
