import 'dart:convert';
import 'package:uuid/uuid.dart';

class PasswordHistoryItem {
  final String value;
  final String fieldName; // e.g. "Contraseña Principal" or the custom field name
  final DateTime changedAt;

  PasswordHistoryItem({
    required this.value,
    required this.fieldName,
    required this.changedAt,
  });

  factory PasswordHistoryItem.fromMap(Map<String, dynamic> map) {
    return PasswordHistoryItem(
      value: map['value'] as String? ?? '',
      fieldName: map['fieldName'] as String? ?? 'Contraseña Principal',
      changedAt: DateTime.tryParse(map['changedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'fieldName': fieldName,
      'changedAt': changedAt.toIso8601String(),
    };
  }
}

class CustomField {
  final String name;
  final String value;
  final bool isSecure;

  CustomField({required this.name, required this.value, this.isSecure = false});

  factory CustomField.fromMap(Map<String, dynamic> map) {
    return CustomField(
      name: map['name'] as String? ?? '',
      value: map['value'] as String? ?? '',
      isSecure: map['isSecure'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'isSecure': isSecure,
    };
  }
}

class EntryModel {
  String id;
  String title;
  String username;
  String password;
  String website;
  String notes;
  String updatedAt;
  bool deleted;
  bool isFavorite;
  String category;
  List<CustomField> customFields;
  List<PasswordHistoryItem> passwordHistory;
  String? totpSecret;

  EntryModel({
    String? id,
    required this.title,
    required this.username,
    required this.password,
    required this.website,
    required this.notes,
    String? updatedAt,
    this.deleted = false,
    this.isFavorite = false,
    this.category = 'General',
    this.customFields = const [],
    this.passwordHistory = const [],
    this.totpSecret,
  })  : id = id ?? const Uuid().v4(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    List<CustomField> parsedCustomFields = [];
    if (map['custom_fields'] != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(map['custom_fields'] as String);
        parsedCustomFields = jsonList.map((e) => CustomField.fromMap(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    
    List<PasswordHistoryItem> parsedHistory = [];
    if (map['password_history'] != null) {
      try {
        final List<dynamic> historyList = jsonDecode(map['password_history'] as String);
        parsedHistory = historyList.map((e) => PasswordHistoryItem.fromMap(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    return EntryModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      website: map['website'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      deleted: (map['deleted'] as int? ?? 0) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      category: map['category'] as String? ?? 'General',
      customFields: parsedCustomFields,
      passwordHistory: parsedHistory,
      totpSecret: map['totp_secret'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'updated_at': updatedAt,
      'deleted': deleted ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'category': category,
      'custom_fields': jsonEncode(customFields.map((e) => e.toMap()).toList()),
      'password_history': jsonEncode(passwordHistory.map((e) => e.toMap()).toList()),
      'totp_secret': totpSecret,
    };
  }

  /// Copy helper to create modified instances of the model.
  EntryModel copyWith({
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    String? updatedAt,
    bool? deleted,
    bool? isFavorite,
    String? category,
    List<CustomField>? customFields,
    List<PasswordHistoryItem>? passwordHistory,
  }) {
    return EntryModel(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      customFields: customFields ?? this.customFields,
      passwordHistory: passwordHistory ?? this.passwordHistory,
    );
  }
}
