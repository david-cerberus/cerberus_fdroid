import 'dart:typed_data';

class AttachmentModel {
  final int? id;
  final String entryId;
  final String fileName;
  final String mimeType;
  final Uint8List? fileBytes;

  AttachmentModel({
    this.id,
    required this.entryId,
    required this.fileName,
    required this.mimeType,
    this.fileBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'entry_id': entryId,
      'file_name': fileName,
      'mime_type': mimeType,
      if (fileBytes != null) 'file_bytes': fileBytes,
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      id: map['id'],
      entryId: map['entry_id'] as String,
      fileName: map['file_name'] as String,
      mimeType: map['mime_type'] as String,
      fileBytes: map['file_bytes'] as Uint8List?,
    );
  }

  AttachmentModel copyWith({
    int? id,
    String? entryId,
    String? fileName,
    String? mimeType,
    Uint8List? fileBytes,
  }) {
    return AttachmentModel(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileBytes: fileBytes ?? this.fileBytes,
    );
  }
}
