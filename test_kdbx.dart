import 'dart:io';
import 'package:kdbx/kdbx.dart';

void main() async {
  final creds = Credentials(ProtectedValue.fromString('1234'));
  final kdbxFormat = KdbxFormat();
  final kdbxFile = kdbxFormat.create(creds, 'Cerberus Export');
  final entry = KdbxEntry.create(kdbxFile, kdbxFile.body.rootGroup);
  entry.setString(KdbxKeyCommon.TITLE, PlainValue('Test Title'));
  kdbxFile.body.rootGroup.addEntry(entry);
  
  final titleNode = entry.getString(KdbxKeyCommon.TITLE);
  print('Title: \${titleNode?.getText()}');
  
  print('Group name: \${kdbxFile.body.rootGroup.name}');
}
