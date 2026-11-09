import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

import '../models/credential_entry.dart';
import '../models/entry_model.dart' as em;
import 'database_helper.dart';
import 'import_export/credential_format_adapter.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class ImportExportService {
  final List<CredentialFormatAdapter> _adapters = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  ImportExportService() {
    // Aquí registraremos los adaptadores (se irán añadiendo conforme se implementen)
    // _adapters.add(JsonFormatAdapter());
    // _adapters.add(EncryptedJsonFormatAdapter());
    // _adapters.add(KdbxFormatAdapter());
    // _adapters.add(OnePuxFormatAdapter());
  }

  void registerAdapter(CredentialFormatAdapter adapter) {
    _adapters.add(adapter);
  }

  /// Importa un archivo utilizando el adaptador adecuado.
  Future<int> importFile(File file, {String? password}) async {
    final extension = p.extension(file.path).toLowerCase();
    
    CredentialFormatAdapter? selectedAdapter;
    for (var adapter in _adapters) {
      if (adapter.canHandle(extension)) {
        selectedAdapter = adapter;
        break;
      }
    }

    if (selectedAdapter == null) {
      throw UnsupportedError('No hay un adaptador disponible para el formato: $extension');
    }

    List<CredentialEntry> entries = await selectedAdapter.importFile(file, password: password);
    int importCount = 0;

    final db = _dbHelper.database;
    await db.transaction((txn) async {
      for (var cred in entries) {
        // Mapear CredentialEntry a EntryModel
        // Aplanar categorías: Si hay varias, tomamos la primera, o "General"
        String category = 'General';
        if (cred.categories.isNotEmpty) {
          category = cred.categories.join(' / ');
        }

        // Convertir password de Uint8List a String (asumiendo UTF-8)
        String passwordStr = '';
        if (cred.password != null) {
          try {
             passwordStr = utf8.decode(cred.password!);
          } catch (e) {
             // Fallback
             passwordStr = String.fromCharCodes(cred.password!);
          }
        }

        // Combinar URLs en notes o usar la primera como website
        String website = '';
        String notes = cred.notes ?? '';
        if (cred.urls.isNotEmpty) {
          website = cred.urls.first;
          if (cred.urls.length > 1) {
            notes += '\nOtras URLs:\n${cred.urls.skip(1).join('\n')}';
          }
        }

        final entryModel = em.EntryModel(
          title: cred.title.isNotEmpty ? cred.title : 'Sin título',
          username: cred.username,
          password: passwordStr,
          website: website,
          notes: notes,
          category: category,
          updatedAt: cred.modifiedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          customFields: cred.customFields.map((cf) => em.CustomField(
            name: cf.name,
            value: cf.value,
            isSecure: cf.isProtected,
          )).toList(),
        );

        // Guardar en BD (insert or replace)
        await txn.insert(
          'entries',
          entryModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        importCount++;

        // Limpieza segura en memoria
        cred.clearMemory();
      }
    });

    return importCount;
  }
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
      throw UnsupportedError('No hay un adaptador disponible para el formato: $extension');
    }

    return await selectedAdapter.exportFile(entries, outputPath, password: password);
  }
}