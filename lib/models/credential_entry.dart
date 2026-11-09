import 'dart:typed_data';

class CredentialEntry {
  final String? id;
  final String title;
  final String username;
  
  /// Usamos Uint8List para poder limpiar la memoria de la contraseña con ceros 
  /// tras su uso, evitando que se quede en memoria antes de que actúe el Garbage Collector.
  final Uint8List? password; 
  
  final List<String> urls;
  final String? notes;
  final String? totpSecret;
  
  /// Categorías, carpetas o etiquetas asignadas al item.
  /// Si la categoría no existe, el ImportExportService la creará.
  final List<String> categories;
  
  final List<CustomField> customFields;
  final DateTime? createdAt;
  final DateTime? modifiedAt;

  CredentialEntry({
    this.id,
    required this.title,
    this.username = '',
    this.password,
    this.urls = const [],
    this.notes,
    this.totpSecret,
    this.categories = const [],
    this.customFields = const [],
    this.createdAt,
    this.modifiedAt,
  });

  /// Método de conveniencia para limpiar la memoria de la contraseña de forma segura.
  void clearMemory() {
    if (password != null) {
      for (int i = 0; i < password!.length; i++) {
        password![i] = 0;
      }
    }
  }
}

class CustomField {
  final String name;
  final String value;
  final bool isProtected;

  CustomField({
    required this.name, 
    required this.value, 
    this.isProtected = false
  });
}
