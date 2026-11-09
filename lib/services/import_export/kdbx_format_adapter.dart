import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:kdbx/kdbx.dart';
import '../../models/credential_entry.dart' as ce;
import 'credential_format_adapter.dart';

class KdbxFormatAdapter implements CredentialFormatAdapter {
  @override
  bool canHandle(String extension) {
    return extension == '.kdbx';
  }

  @override
  Future<List<ce.CredentialEntry>> importFile(File file, {String? password}) async {
    if (password == null || password.isEmpty) {
      throw ArgumentError('KDBX import requires a password');
    }

    final bytes = await file.readAsBytes();
    final creds = Credentials(ProtectedValue.fromString(password));
    final kdbxFile = await KdbxFormat().read(bytes, creds);

    final entries = <ce.CredentialEntry>[];

    void processGroup(KdbxGroup group, String currentCategory) {
      final gName = group.name.get() ?? '';
      final categoryName = gName != 'Root' && gName.isNotEmpty ? gName : currentCategory;
      
      for (final entry in group.entries) {
        final titleNode = entry.getString(KdbxKeyCommon.TITLE);
        final String title = titleNode?.getText() ?? '';
        
        final usernameNode = entry.getString(KdbxKeyCommon.USER_NAME);
        final String username = usernameNode?.getText() ?? '';
        
        final pwNode = entry.getString(KdbxKeyCommon.PASSWORD);
        List<int>? passwordBytes;
        if (pwNode != null) {
          final pwText = pwNode.getText() ?? '';
          passwordBytes = utf8.encode(pwText);
        }
        
        final urlNode = entry.getString(KdbxKeyCommon.URL);
        final String url = urlNode?.getText() ?? '';
        
        final notesNode = entry.getString(KdbxKey('Notes'));
        final String notes = notesNode?.getText() ?? '';
        
        if (title.isEmpty && username.isEmpty && (passwordBytes == null || passwordBytes.isEmpty)) {
          continue;
        }

        final newEntry = ce.CredentialEntry(
          id: '',
          title: title.isEmpty ? 'KeePass Import' : title,
          username: username,
          password: passwordBytes != null ? Uint8List.fromList(passwordBytes) : null,
          urls: url.isNotEmpty ? [url] : [],
          notes: notes,
          categories: categoryName != 'General' ? [categoryName] : [],
        );
        entries.add(newEntry);
      }
      
      for (final childGroup in group.groups) {
        processGroup(childGroup, categoryName);
      }
    }

    processGroup(kdbxFile.body.rootGroup, 'General');

    return entries;
  }

  @override
  Future<File> exportFile(List<ce.CredentialEntry> entries, String outputPath, {String? password}) async {
    if (password == null || password.isEmpty) {
      throw ArgumentError('KDBX format requires a password');
    }

    final creds = Credentials(ProtectedValue.fromString(password));
    final kdbxFormat = KdbxFormat();
    final kdbxFile = kdbxFormat.create(creds, 'Cerberus Export');

    for (var e in entries) {
      final entry = KdbxEntry.create(kdbxFile, kdbxFile.body.rootGroup);
      
      entry.setString(KdbxKeyCommon.TITLE, PlainValue(e.title));
      if (e.username.isNotEmpty) {
        entry.setString(KdbxKeyCommon.USER_NAME, PlainValue(e.username));
      }
      if (e.password != null && e.password!.isNotEmpty) {
        try {
          final pwStr = utf8.decode(e.password!);
          entry.setString(KdbxKeyCommon.PASSWORD, ProtectedValue.fromString(pwStr));
        } catch (_) {}
      }
      if (e.urls.isNotEmpty) {
        entry.setString(KdbxKeyCommon.URL, PlainValue(e.urls.first));
      }
      if (e.notes != null && e.notes!.isNotEmpty) {
        entry.setString(KdbxKey('Notes'), PlainValue(e.notes!));
      }
      
      kdbxFile.body.rootGroup.addEntry(entry);
    }

    final bytes = await kdbxFile.save();
    final file = File(outputPath);
    await file.writeAsBytes(bytes);

    return file;
  }
}
