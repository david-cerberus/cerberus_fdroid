import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class AssetLinkService {
  static const String _dalApiBaseUrl = 'https://digitalassetlinks.googleapis.com/v1/statements:list';

  /// Resuelve el dominio asociado a un packageName.
  /// Si está en caché local, lo devuelve inmediatamente.
  /// Si no, hace la petición HTTP a la API de Digital Asset Links, lo cachea y lo devuelve.
  static Future<String?> resolveDomain(String packageName) async {
    if (packageName.trim().isEmpty) return null;

    final dbHelper = DatabaseHelper();
    
    // 1. Check local cache
    final cachedDomain = await dbHelper.getCachedDomain(packageName);
    if (cachedDomain != null && cachedDomain.isNotEmpty) {
      return cachedDomain;
    }

    // 2. Fetch from network
    try {
      // Configuramos la petición para buscar qué dominio confía en este paquete
      final uri = Uri.parse(
        '\$_dalApiBaseUrl?source.androidApp.packageName=$packageName&relation=delegate_permission/common.handle_all_urls'
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('statements') && data['statements'] != null) {
          final List statements = data['statements'];
          
          for (var statement in statements) {
            final target = statement['target'];
            if (target != null && target['web'] != null && target['web']['site'] != null) {
              String siteUrl = target['web']['site']; // ej. "https://netflix.com"
              
              // Extraemos solo el dominio
              try {
                final parsedUri = Uri.parse(siteUrl);
                final domain = parsedUri.host.replaceFirst(RegExp(r'^www\.'), '');
                
                if (domain.isNotEmpty) {
                  // Guardamos en caché
                  await dbHelper.cacheAssetLink(packageName, domain);
                  return domain;
                }
              } catch (e) {
                // Ignore parse error and check next statement
              }
            }
          }
        }
      }
    } catch (e) {
      // Timeouts, network errors, etc. We just return null so we don't break autofill.
    }

    return null;
  }
}
