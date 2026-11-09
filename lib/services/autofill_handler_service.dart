import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/entry_model.dart';
import 'database_helper.dart';

class AutofillHandlerService {
  static const MethodChannel _channel = MethodChannel('com.cerberus.autofill/channel');
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Inicializa el listener para peticiones desde el código nativo (Android AutofillService)
  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getCredentialsForPackage':
        final String? packageName = call.arguments['packageName'] as String?;
        final String? webDomain = call.arguments['webDomain'] as String?;
        if ((packageName == null || packageName.isEmpty) && (webDomain == null || webDomain.isEmpty)) {
          return '[]';
        }
        return await getCredentialsForPackage(packageName ?? '', webDomain: webDomain);
      default:
        throw MissingPluginException('Método ${call.method} no implementado');
    }
  }

  /// Busca las credenciales que coincidan con un paquete de Android o dominio web.
  /// 1. Usa el dominio web directamente si está disponible o el nombre del paquete.
  /// 2. Busca en la base de datos de Cerberus coincidencias.
  /// 3. Retorna un JSON String con los resultados para el servicio nativo.
  static Future<String> getCredentialsForPackage(String packageName, {String? webDomain}) async {
    String searchKeyword = '';
    if (webDomain != null && webDomain.isNotEmpty) {
      // Limpiar prefijos de esquema si vienen en el webDomain
      searchKeyword = webDomain.replaceAll(RegExp(r'https?://'), '').split('/')[0];
    } else {
      searchKeyword = packageName.split('.').last;
    }

    // 2. Buscar en Vault
    List<EntryModel> matches = await _searchInVault(searchKeyword);

    // 3. Formatear para el canal nativo
    List<Map<String, dynamic>> results = matches.map((e) => {
      'id': e.id,
      'title': e.title,
      'username': e.username,
      'password': e.password,
    }).toList();

    return json.encode(results);
  }

  static Future<List<EntryModel>> _searchInVault(String keyword) async {
    final db = _dbHelper.database;
    final String lowerKeyword = keyword.toLowerCase();

    // Consulta SQL a SQLCipher para buscar en titulo, website o notas
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: 'deleted = 0 AND (LOWER(title) LIKE ? OR LOWER(website) LIKE ? OR LOWER(notes) LIKE ?)',
      whereArgs: ['%\$lowerKeyword%', '%\$lowerKeyword%', '%\$lowerKeyword%'],
    );

    return List.generate(maps.length, (i) {
      return EntryModel.fromMap(maps[i]);
    });
  }
}
