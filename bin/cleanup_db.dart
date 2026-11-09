import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path/path.dart';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  final dbPath = join(Directory.current.path, '.dart_tool', 'sqflite_common_ffi', 'databases', 'aurapass.db'); // Note: This isn't accurate for android, let's just make a flutter app that does this.
}
