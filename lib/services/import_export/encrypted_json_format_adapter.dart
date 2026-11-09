import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:math' as dart_math;
import '../../models/credential_entry.dart';
import 'credential_format_adapter.dart';
import 'json_format_adapter.dart';

class EncryptedJsonFormatAdapter implements CredentialFormatAdapter {
  final JsonFormatAdapter _jsonAdapter = JsonFormatAdapter();

  @override
  bool canHandle(String extension) {
    return extension == '.cjson' || extension == '.json.enc';
  }

  @override
  Future<List<CredentialEntry>> importFile(File file, {String? password}) async {
    if (password == null || password.isEmpty) {
      throw const FormatException('Se requiere una contraseña para descifrar este archivo.');
    }

    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    if (!data.containsKey('salt') || !data.containsKey('nonce') || !data.containsKey('ciphertext') || !data.containsKey('mac')) {
      throw const FormatException('Formato de archivo cifrado inválido.');
    }

    final salt = base64Decode(data['salt']);
    final nonce = base64Decode(data['nonce']);
    final ciphertext = base64Decode(data['ciphertext']);
    final macBytes = base64Decode(data['mac']);

    // Descifrado en isolate
    final String decryptedJson = await compute(_decryptData, {
      'password': password,
      'salt': salt,
      'nonce': nonce,
      'ciphertext': ciphertext,
      'mac': macBytes,
    });

    // Reutilizar el parser del adaptador JSON normal
    // Creamos un archivo temporal virtual o usamos compute sobre el string (el JsonAdapter puede hacerlo indirectamente, 
    // pero como el método parse es privado, podemos duplicar la lógica o reusar el método privado si lo hacemos accesible.
    // Para simplificar, crearemos un archivo temporal).
    final tempDir = await Directory.systemTemp.createTemp('cerberus_import');
    final tempFile = File('${tempDir.path}/temp.json');
    await tempFile.writeAsString(decryptedJson);

    try {
      final entries = await _jsonAdapter.importFile(tempFile);
      return entries;
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  @override
  Future<File> exportFile(List<CredentialEntry> entries, String outputPath, {String? password}) async {
    if (password == null || password.isEmpty) {
      throw const FormatException('Se requiere una contraseña para exportar un archivo cifrado.');
    }

    // Exportar a JSON normal en un archivo temporal
    final tempDir = await Directory.systemTemp.createTemp('cerberus_export');
    final tempFile = await _jsonAdapter.exportFile(entries, '${tempDir.path}/temp.json');
    final jsonContent = await tempFile.readAsString();
    await tempFile.delete();

    // Cifrar en isolate
    final encryptedData = await compute(_encryptData, {
      'password': password,
      'content': jsonContent,
    });

    final file = File(outputPath);
    await file.writeAsString(jsonEncode(encryptedData));
    return file;
  }
}

Future<String> _decryptData(Map<String, dynamic> args) async {
  final password = args['password'] as String;
  final salt = args['salt'] as Uint8List;
  final nonce = args['nonce'] as Uint8List;
  final ciphertext = args['ciphertext'] as Uint8List;
  final macBytes = args['mac'] as Uint8List;

  final algorithm = Argon2id(
    memory: 65536,
    iterations: 3,
    parallelism: 4,
    hashLength: 32,
  );

  final secretKey = await algorithm.deriveKeyFromPassword(
    password: password,
    nonce: salt,
  );

  final cipher = AesGcm.with256bits();
  final secretBox = SecretBox(
    ciphertext,
    nonce: nonce,
    mac: Mac(macBytes),
  );

  try {
    final decryptedBytes = await cipher.decrypt(
      secretBox,
      secretKey: secretKey,
    );
    return utf8.decode(decryptedBytes);
  } catch (e) {
    throw const FormatException('Contraseña incorrecta o archivo dañado.');
  }
}

Future<Map<String, dynamic>> _encryptData(Map<String, dynamic> args) async {
  final password = args['password'] as String;
  final content = args['content'] as String;

  // Generar salt de 16 bytes
  final salt = _generateRandomBytes(16);
  // Generar nonce de 12 bytes
  final nonce = _generateRandomBytes(12);

  final algorithm = Argon2id(
    memory: 65536,
    iterations: 3,
    parallelism: 4,
    hashLength: 32,
  );

  final secretKey = await algorithm.deriveKeyFromPassword(
    password: password,
    nonce: salt,
  );

  final cipher = AesGcm.with256bits();
  final contentBytes = utf8.encode(content);
  
  final secretBox = await cipher.encrypt(
    contentBytes,
    secretKey: secretKey,
    nonce: nonce,
  );

  return {
    'salt': base64Encode(salt),
    'nonce': base64Encode(nonce),
    'ciphertext': base64Encode(secretBox.cipherText),
    'mac': base64Encode(secretBox.mac.bytes),
  };
}

Uint8List _generateRandomBytes(int length) {
  final secureRandom = DartRandom.secure();
  final bytes = Uint8List(length);
  for (int i = 0; i < length; i++) {
    bytes[i] = secureRandom.nextInt(256);
  }
  return bytes;
}

/// Helper para generar bytes aleatorios, ya que cryptography requiere un Random explícito o usamos el nativo
class DartRandom {
  static final _random = dart_math.Random.secure();
  static dart_math.Random secure() => _random;
}
