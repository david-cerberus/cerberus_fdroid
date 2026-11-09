import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:secure_password_manager/services/database_helper.dart';
import 'package:secure_password_manager/models/entry_model.dart';

void main() {
  // Initialize Sqflite for tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests (FFI with Injectable Password Check)', () {
    const masterPassword = 'MySuperSafeMasterPassword!99';
    late DatabaseHelper dbHelper;
    String? correctDerivedKey;

    // A mock openDatabase implementation that checks the password key
    Future<Database> testOpenDatabase(
      String path, {
      int? version,
      OnDatabaseCreateFn? onCreate,
      OnDatabaseVersionChangeFn? onUpgrade,
      String? password,
    }) async {
      // Capture the correct key on the first invocation
      if (correctDerivedKey == null && password != null) {
        correctDerivedKey = password;
      }

      if (password != correctDerivedKey) {
        throw Exception('sqlite_error: file is not a database');
      }

      // Delegate the actual database creation/loading to FFI (ignoring the password since FFI is unencrypted)
      return await openDatabase(
        path,
        version: version,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      );
    }

    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      dbHelper = DatabaseHelper();
      correctDerivedKey = null;
    });

    tearDown(() async {
      await dbHelper.closeDatabase();
      // Clean up local test database file
      try {
        final path = await databaseFactory.getDatabasesPath();
        final dbFile = p.join(path, 'secure_entries.db');
        await databaseFactory.deleteDatabase(dbFile);
      } catch (_) {}
    });

    test('Initializes database successfully and creates tables', () async {
      await dbHelper.initDatabase(masterPassword, openDatabaseFn: testOpenDatabase);
      
      final db = dbHelper.database;
      expect(db.isOpen, isTrue);

      // Verify table 'entries' exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='entries';"
      );
      expect(tables.length, 1);
    });

    test('Performs CRUD operations on entries successfully', () async {
      await dbHelper.initDatabase(masterPassword, openDatabaseFn: testOpenDatabase);

      final entry = EntryModel(
        title: 'Google Account',
        username: 'user@gmail.com',
        password: 'GooglePassword123',
        website: 'example.com',
        notes: 'Personal email',
      );

      // Create (Insert)
      final id = await dbHelper.insertEntry(entry);
      expect(id, greaterThan(0));

      // Read
      final entries = await dbHelper.getEntries();
      expect(entries.length, 1);
      expect(entries.first.title, 'Google Account');
      expect(entries.first.username, 'user@gmail.com');
      expect(entries.first.deleted, isFalse);

      // Update
      final updatedEntry = entries.first.copyWith(
        title: 'Google Account (Updated)',
        notes: 'Updated notes',
      );
      final updateCount = await dbHelper.updateEntry(updatedEntry);
      expect(updateCount, 1);

      final entriesAfterUpdate = await dbHelper.getEntries();
      expect(entriesAfterUpdate.first.title, 'Google Account (Updated)');

      // Soft Delete
      final deleteCount = await dbHelper.deleteEntry(entry.id);
      expect(deleteCount, 1);

      // Verify it is not returned in standard getEntries()
      final activeEntries = await dbHelper.getEntries();
      expect(activeEntries.isEmpty, isTrue);

      // Verify it is still present in sync retrieve with deleted=true
      final allEntries = await dbHelper.getAllEntriesForSync();
      expect(allEntries.length, 1);
      expect(allEntries.first.deleted, isTrue);
    });

    test('Throws SecureDatabaseException when opened with incorrect password', () async {
      // 1. Initialize with correct password to establish correctPassword
      await dbHelper.initDatabase(masterPassword, openDatabaseFn: testOpenDatabase);
      await dbHelper.closeDatabase();

      // 2. Try to initialize with a wrong password and expect it to fail
      final wrongDbHelper = DatabaseHelper();
      expect(
        () async => await wrongDbHelper.initDatabase('wrong_password', openDatabaseFn: testOpenDatabase),
        throwsA(isA<SecureDatabaseException>()),
      );
    });
  });
}
