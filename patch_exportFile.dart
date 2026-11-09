import 'dart:io';

void main() {
  final serviceFile = File('lib/services/import_export_service.dart');
  String serviceCode = serviceFile.readAsStringSync();
  
  if (!serviceCode.contains('exportFile(List<CredentialEntry> entries, String outputPath')) {
    final methodStr = '''
  Future<File> exportFile(List<CredentialEntry> entries, String outputPath, {String? password}) async {
    final extension = p.extension(outputPath).toLowerCase();
    
    CredentialFormatAdapter? selectedAdapter;
    for (var adapter in _adapters) {
      if (adapter.canHandle(extension)) {
        selectedAdapter = adapter;
        break;
      }
    }

    if (selectedAdapter == null) {
      throw UnsupportedError('No hay un adaptador disponible para el formato: \$extension');
    }

    return await selectedAdapter.exportFile(entries, outputPath, password: password);
  }
}''';
    serviceCode = serviceCode.replaceFirst(RegExp(r'\}\s*$'), methodStr);
    serviceFile.writeAsStringSync(serviceCode);
  }

  final kdbxFile = File('lib/services/import_export/kdbx_format_adapter.dart');
  String kdbxCode = kdbxFile.readAsStringSync();
  kdbxCode = kdbxCode.replaceAll('KdbxFile.create(creds)', 'KdbxFile(creds)');
  kdbxCode = kdbxCode.replaceAll('if (e.notes.isNotEmpty)', 'if (e.notes != null && e.notes!.isNotEmpty)');
  kdbxFile.writeAsStringSync(kdbxCode);
  print('Patched successfully.');
}
