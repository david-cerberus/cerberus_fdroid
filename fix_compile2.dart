import 'dart:io';

void main() {
  final homeFile = File('lib/screens/home_screen.dart');
  String homeCode = homeFile.readAsStringSync();
  homeCode = homeCode.replaceAll("} else  else if (value == 'cloud_sync') {", "} else if (value == 'cloud_sync') {");
  homeFile.writeAsStringSync(homeCode);
  
  final mainFile = File('lib/main.dart');
  String mainCode = mainFile.readAsStringSync();
  
  mainCode = mainCode.replaceAll("import 'dart:convert';\\nimport 'dart:typed_data';", "import 'dart:convert';\nimport 'dart:typed_data';");
  mainCode = mainCode.replaceAll("import 'services/database_helper.dart';\\nimport 'models/credential_entry.dart';", "import 'services/database_helper.dart';\nimport 'models/credential_entry.dart' as ce;");
  
  // Fix the map logic in _handleExportUnified
  final oldMap = '''      final credEntries = entries.map((e) => CredentialEntry(
        id: e.id,
        title: e.title,
        username: e.username,
        password: e.password.isNotEmpty ? Uint8List.fromList(utf8.encode(e.password)) : null,
        urls: e.url.isNotEmpty ? [e.url] : [],
        notes: e.notes,
        categories: e.folder.isNotEmpty ? [e.folder] : [],
        customFields: e.customFields.map((cf) {
          final isProtected = cf['isProtected'] == true || cf['isSecure'] == true;
          return CustomField(name: cf['name']?.toString() ?? '', value: cf['value']?.toString() ?? '', isSecure: isProtected);
        }).toList(),
        createdAt: e.createdAt,
        modifiedAt: e.updatedAt,
      )).toList();''';

  final newMap = '''      final credEntries = entries.map((e) => ce.CredentialEntry(
        id: e.id?.toString(),
        title: e.title,
        username: e.username,
        password: e.password.isNotEmpty ? Uint8List.fromList(utf8.encode(e.password)) : null,
        urls: e.website.isNotEmpty ? [e.website] : [],
        notes: e.notes,
        categories: e.category.isNotEmpty ? [e.category] : [],
        customFields: e.customFields.map((cf) {
          return ce.CustomField(name: cf.name, value: cf.value, isProtected: cf.isSecure);
        }).toList(),
        modifiedAt: e.updatedAt,
      )).toList();''';
      
  mainCode = mainCode.replaceFirst(oldMap, newMap);
  
  mainFile.writeAsStringSync(mainCode);
  
  final kdbxFile = File('lib/services/import_export/kdbx_format_adapter.dart');
  String kdbxCode = kdbxFile.readAsStringSync();
  // fix kdbx "final kdbxFile = KdbxFile(creds);"
  kdbxCode = kdbxCode.replaceAll('final kdbxFile = KdbxFile(creds);', 'final kdbxFile = KdbxFile(creds, KdbxFormat.KDBX4, const DefaultCipher(), const DefaultKdf(), const DefaultInnerStreamCipher());');
  kdbxFile.writeAsStringSync(kdbxCode);
}
