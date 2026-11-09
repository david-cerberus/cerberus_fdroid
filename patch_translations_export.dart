import 'dart:io';
import 'dart:convert';

void main() {
  final dir = Directory('lib/l10n');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb'));

  for (final file in files) {
    final isEs = file.path.endsWith('app_es.arb');
    final content = file.readAsStringSync();
    Map<String, dynamic> json;
    try {
      json = jsonDecode(content);
    } catch (e) {
      continue;
    }

    json['exportToJson'] = isEs ? "Exportar a JSON" : "Export to JSON";
    json['exportJsonRecommended'] = isEs 
      ? "Por seguridad, te recomendamos proteger este archivo con una contraseña." 
      : "For security, we recommend protecting this file with a password.";
    json['exportJsonSecureBtn'] = isEs ? "Exportar seguro" : "Export secure";
    json['exportJsonPlainBtn'] = isEs ? "Exportar sin cifrar (No recomendado)" : "Export without encryption (Not recommended)";
    json['exportKdbxDesc'] = isEs 
      ? "Introduce la contraseña maestra para tu nueva base de datos KeePass.\\n\\nEsta contraseña bloqueará el archivo .kdbx y no tiene que ser la misma que la de Cerberus." 
      : "Enter the master password for your new KeePass database.\\n\\nThis password will lock the .kdbx file and doesn't need to be the same as Cerberus'.";
    json['passwordForFile'] = isEs ? "Contraseña para el archivo" : "Password for file";

    // remove exportTo1pux if exists
    json.remove('exportTo1pux');
    json.remove('exportToJsonEncrypted');

    final encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(json));
  }
  print('Translations patched successfully.');
}
