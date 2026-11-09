import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;
import '../models/attachment_model.dart';
import 'database_helper.dart';

class AttachmentService {
  static const int maxFileSize = 20 * 1024 * 1024; // 20 MB

  /// Valida y procesa un archivo para convertirlo en un AttachmentModel.
  /// Lanza excepciones si el archivo supera el límite de 20MB.
  static Future<AttachmentModel> processFile(String entryId, File file) async {
    final int length = await file.length();
    if (length > maxFileSize) {
      throw Exception('El archivo supera el límite máximo de 20 MB.');
    }

    final String fileName = file.path.split(Platform.pathSeparator).last;
    String mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    
    Uint8List fileBytes;

    if (mimeType.startsWith('image/') && length > 1024 * 1024) {
      // Compress image if it's over 1MB
      fileBytes = await compute(_compressImage, await file.readAsBytes());
      if (mimeType != 'image/png') {
        mimeType = 'image/jpeg';
      }
    } else {
      fileBytes = await file.readAsBytes();
    }

    return AttachmentModel(
      entryId: entryId,
      fileName: fileName,
      mimeType: mimeType,
      fileBytes: fileBytes,
    );
  }

  /// Isolate function to compress image
  static Uint8List _compressImage(Uint8List bytes) {
    try {
      final img.Image? original = img.decodeImage(bytes);
      if (original == null) return bytes;

      img.Image resized = original;
      // If width is very large, resize to 50%
      if (original.width > 2000 || original.height > 2000) {
        resized = img.copyResize(original, width: original.width ~/ 2);
      }

      // Encode as JPEG with 80% quality
      return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
    } catch (e) {
      return bytes;
    }
  }

  /// Escribe el archivo en un directorio temporal y lo abre con la app por defecto.
  static Future<void> viewAttachment(AttachmentModel attachment) async {
    AttachmentModel? fullAttachment = attachment;
    if (fullAttachment.fileBytes == null && fullAttachment.id != null) {
      fullAttachment = await DatabaseHelper().getAttachmentData(fullAttachment.id!);
    }

    if (fullAttachment == null || fullAttachment.fileBytes == null) {
      throw Exception('No se encontraron los datos del archivo.');
    }
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${fullAttachment.id}_${fullAttachment.fileName}');
    
    await tempFile.writeAsBytes(fullAttachment.fileBytes!);
    
    final result = await OpenFilex.open(tempFile.path, type: fullAttachment.mimeType);
    if (result.type != ResultType.done) {
      throw Exception('No se pudo abrir el archivo: ${result.message}');
    }
  }
}
