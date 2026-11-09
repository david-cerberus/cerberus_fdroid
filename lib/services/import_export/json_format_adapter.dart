import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/credential_entry.dart';
import 'credential_format_adapter.dart';

class JsonFormatAdapter implements CredentialFormatAdapter {
  @override
  bool canHandle(String extension) {
    return extension == '.json';
  }

  @override
  Future<List<CredentialEntry>> importFile(File file, {String? password}) async {
    // Leemos el archivo como string
    final content = await file.readAsString();
    
    // Parseamos en un Isolate para no bloquear el hilo principal
    final List<CredentialEntry> entries = await compute(_parseJson, content);
    return entries;
  }

  @override
  Future<File> exportFile(List<CredentialEntry> entries, String outputPath, {String? password}) async {
    final List<Map<String, dynamic>> maps = entries.map((e) {
      String passStr = '';
      if (e.password != null) {
        try {
          passStr = utf8.decode(e.password!);
        } catch (_) {
          passStr = String.fromCharCodes(e.password!);
        }
      }
      return {
        'title': e.title,
        'username': e.username,
        'password': passStr,
        'website': e.urls.isNotEmpty ? e.urls.first : '',
        'notes': e.notes,
        'categories': e.categories,
        'customFields': e.customFields.map((cf) => {
          'name': cf.name,
          'value': cf.value,
          'isProtected': cf.isProtected,
        }).toList(),
      };
    }).toList();

    final jsonString = jsonEncode(maps);
    final file = File(outputPath);
    await file.writeAsString(jsonString);
    return file;
  }
}

/// Función top-level para parsear JSON en un Isolate
List<CredentialEntry> _parseJson(String jsonString) {
  final dynamic decoded = jsonDecode(jsonString);
  List<dynamic> list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map && decoded.containsKey('entries')) {
    list = decoded['entries'];
  } else {
    throw const FormatException('El archivo JSON no tiene un formato válido o soportado.');
  }

  return list.map((item) {
    if (item is! Map<String, dynamic>) return null;

    final String title = item['title']?.toString() ?? '';
    final String username = item['username']?.toString() ?? '';
    final String passwordStr = item['password']?.toString() ?? '';
    final String website = item['website']?.toString() ?? item['url']?.toString() ?? '';
    final String notes = item['notes']?.toString() ?? '';
    
    List<String> categories = [];
    if (item['category'] != null) {
      categories.add(item['category'].toString());
    } else if (item['categories'] is List) {
      categories = (item['categories'] as List).map((e) => e.toString()).toList();
    } else if (item['folder'] != null) {
      categories.add(item['folder'].toString());
    }

    List<CustomField> customFields = [];
    if (item['customFields'] is List) {
      for (var cf in item['customFields']) {
        if (cf is Map) {
          customFields.add(CustomField(
            name: cf['name']?.toString() ?? '',
            value: cf['value']?.toString() ?? '',
            isProtected: cf['isProtected'] == true || cf['isSecure'] == true,
          ));
        }
      }
    }

    List<String> urls = [];
    if (website.isNotEmpty) {
      urls.add(website);
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
