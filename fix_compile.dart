import 'dart:io';

void main() {
  // Fix home_screen.dart
  final homeFile = File('lib/screens/home_screen.dart');
  String homeCode = homeFile.readAsStringSync();
  
  // Replace leftover csv_actions check if it exists
  final leftoverCsvCheck = '''if (value == 'csv_actions') {
                        if (!isPremiumNotifier.value) {
                          showDialog(
                            context: context,
                            builder: (context) => const PremiumPurchaseDialog(),
                          );
                          return;
                        }
                        _showCsvActionsDialog();
                      }''';
  if (homeCode.contains(leftoverCsvCheck)) {
    homeCode = homeCode.replaceFirst(leftoverCsvCheck, '');
  } else {
    // Just replace any _showCsvActionsDialog calls with _showExportDialog or _showImportDialog.
    // Actually, I already replaced the PopupMenuItem for csv_actions with import_actions and export_actions.
    // So if the value check for 'csv_actions' was still there, it's dead code but causes compilation error.
    homeCode = homeCode.replaceAll('_showCsvActionsDialog();', '_showExportDialog();');
  }
  
  homeFile.writeAsStringSync(homeCode);

  // Fix main.dart
  final mainFile = File('lib/main.dart');
  String mainCode = mainFile.readAsStringSync();
  
  if (!mainCode.contains('dart:typed_data')) {
    mainCode = mainCode.replaceFirst("import 'dart:convert';", "import 'dart:convert';\\nimport 'dart:typed_data';");
  }
  if (!mainCode.contains('models/credential_entry.dart')) {
    mainCode = mainCode.replaceFirst("import 'services/database_helper.dart';", "import 'services/database_helper.dart';\\nimport 'models/credential_entry.dart';");
  }

  mainCode = mainCode.replaceAll('_dbHelper.getAllEntries()', '_dbHelper.getEntries()');
  mainCode = mainCode.replaceAll('isProtected: isProtected', 'isSecure: isProtected');

  mainFile.writeAsStringSync(mainCode);
}
