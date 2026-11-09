import 'dart:io';
import '../../models/credential_entry.dart';

abstract class CredentialFormatAdapter {
  /// Devuelve true si este adaptador puede manejar el archivo basado en su extensión o contenido.
  bool canHandle(String extension);

  /// Lee un archivo físico y lo transforma en una lista de [CredentialEntry].
  /// Usa [password] si el formato requiere descifrado (KDBX, JSON cifrado).
  /// Todo el procesamiento pesado debe hacerse en un Isolate (usando `compute`).
  Future<List<CredentialEntry>> importFile(File file, {String? password});

  /// Toma una lista de [CredentialEntry] y genera un archivo físico.
  /// Usa [password] si el formato a exportar requiere cifrado.
  Future<File> exportFile(List<CredentialEntry> entries, String outputPath, {String? password});
}
