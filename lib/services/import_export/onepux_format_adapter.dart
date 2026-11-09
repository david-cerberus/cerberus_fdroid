import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import '../../models/credential_entry.dart';
import 'credential_format_adapter.dart';

class OnePuxFormatAdapter implements CredentialFormatAdapter {
  @override
  bool canHandle(String extension) {
    return extension == '.1pux';
  }

  @override
  Future<List<CredentialEntry>> importFile(File file, {String? password}) async {
    // 1PUX es un archivo ZIP que contiene data/default/1password.json
    final bytes = await file.readAsBytes();
    
    final List<CredentialEntry> entries = await compute(_parse1Pux, bytes);
    return entries;
  }

  @override
  Future<File> exportFile(List<CredentialEntry> entries, String outputPath, {String? password}) async {
    final Map<String, dynamic> jsonRoot = {
      'items': entries.map((e) {
        String passStr = '';
        if (e.password != null) {
          try {
            passStr = utf8.decode(e.password!);
          } catch (_) {
            passStr = String.fromCharCodes(e.password!);
          }
        }
        
        final List<Map<String, dynamic>> fields = [];
        if (e.username.isNotEmpty) {
          fields.add({'type': 'STRING', 'name': 'username', 'value': e.username});
        }
        if (passStr.isNotEmpty) {
          fields.add({'type': 'CONCEALED', 'name': 'password', 'value': passStr});
        }
        for (final cf in e.customFields) {
          fields.add({
            'type': cf.isProtected ? 'CONCEALED' : 'STRING',
            'name': cf.name,
            'value': cf.value,
          });
        }
        
        return {
          'title': e.title,
          'category': e.categories.isNotEmpty ? e.categories.first : 'Login',
          'urls': e.urls.map((u) => {'href': u}).toList(),
          'details': {
            'notesPlain': e.notes,
            'fields': fields,
          }
        };
      }).toList(),
    };

    final jsonString = jsonEncode(jsonRoot);
    final jsonBytes = utf8.encode(jsonString);

    final archive = Archive();
    final jsonArchiveFile = ArchiveFile('data/default/1password.json', jsonBytes.length, jsonBytes);
    archive.addFile(jsonArchiveFile);

    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);
    
    if (zipBytes == null) {
      throw const FormatException('Error al crear el archivo 1PUX.');
    }

    final file = File(outputPath);
    await file.writeAsBytes(zipBytes);
    return file;
  }
}

List<CredentialEntry> _parse1Pux(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  
  ArchiveFile? jsonFile;
  for (final file in archive) {
    if (file.isFile && file.name.endsWith('1password.json')) {
      jsonFile = file;
      break;
    }
  }

  if (jsonFile == null) {
    throw const FormatException('El archivo 1PUX no contiene 1password.json.');
  }

  final content = utf8.decode(jsonFile.content as List<int>);
  final dynamic decoded = jsonDecode(content);

  List<dynamic> list = [];
  if (decoded is Map && decoded.containsKey('items')) {
    list = decoded['items'];
  } else if (decoded is List) {
    list = decoded;
  } else {
    throw const FormatException('Formato interno de 1password.json inválido.');
  }

  return list.map((item) {
    if (item is! Map<String, dynamic>) return null;

    final details = item['details'] as Map<String, dynamic>? ?? {};
    final fields = details['fields'] as List<dynamic>? ?? [];

    String title = item['title']?.toString() ?? '';
    String username = '';
    String passwordStr = '';
    String notes = details['notesPlain']?.toString() ?? '';
    List<String> urls = [];

    if (item['urls'] is List) {
      for (var u in item['urls']) {
        if (u is Map && u['href'] != null) {
          urls.add(u['href'].toString());
        }
      }
    }

    List<CustomField> customFields = [];

    for (var f in fields) {
      if (f is! Map<String, dynamic>) continue;
      final type = f['type']?.toString().toUpperCase();
      final name = f['name']?.toString() ?? f['t']?.toString() ?? ''; // t is often label
      final value = f['value']?.toString() ?? f['v']?.toString() ?? '';

      if (value.isEmpty) continue;

      if (name.toLowerCase() == 'username') {
        username = value;
      } else if (name.toLowerCase() == 'password' || type == 'CONCEALED') {
        if (passwordStr.isEmpty) {
          passwordStr = value;
        } else {
          customFields.add(CustomField(name: name.isNotEmpty ? name : 'Password', value: value, isProtected: true));
        }
      } else {
        customFields.add(CustomField(name: name, value: value, isProtected: type == 'CONCEALED'));
      }
    }

    List<String> categories = [];
    if (item['category'] != null) {
      categories.add(item['category'].toString());
    }

    return CredentialEntry(
      title: title,
      username: username,
      password: Uint8List.fromList(utf8.encode(passwordStr)),
      urls: urls,
      notes: notes,
      categories: categories,
      customFields: customFields,
    );
  }).whereType<CredentialEntry>().toList();
}
