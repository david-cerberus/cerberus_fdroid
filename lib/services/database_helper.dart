import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:csv/csv.dart';
import 'package:xml/xml.dart';
import '../models/entry_model.dart';
import '../models/attachment_model.dart';
import 'crypto_service.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final _secureStorage = const FlutterSecureStorage();
  static const String _saltKey = 'master_password_salt';
  static const String _dbName = 'secure_entries.db';

  /// Getter for the active database. Throws an exception if not initialized.
  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized. Call initDatabase first.');
    }
    return _database!;
  }

  /// Initialize the database by deriving the encryption key.
  /// [openDatabaseFn] can be provided for unit testing to override the native sqflite openDatabase call.
  Future<void> initDatabase(
    String userPasswordInput, {
    Future<Database> Function(
      String path, {
      int? version,
      OnDatabaseCreateFn? onCreate,
      OnDatabaseVersionChangeFn? onUpgrade,
      String? password,
    })? openDatabaseFn,
  }) async {
    // 1. Get or generate the installation-specific salt
    List<int> salt = await _getOrCreateSalt();

    // 2. Derive the 32-byte (256-bit) key as a Hex String (600,000 PBKDF2 iterations)
    String derivedHexKey = await CryptoService.deriveKey(userPasswordInput, salt);

    // 3. Get the path to the database
    String databasesPath;
    try {
      databasesPath = await databaseFactory.getDatabasesPath();
    } catch (_) {
      databasesPath = '.';
    }
    String path = join(databasesPath, _dbName);

    // 4. Open the SQLCipher database with the derived key
    Database db;
    try {
      if (openDatabaseFn != null) {
        db = await openDatabaseFn(
          path,
          version: 7,
          password: derivedHexKey,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE entries (
                id TEXT PRIMARY KEY,
                title TEXT,
                username TEXT,
                password TEXT,
                website TEXT,
                notes TEXT,
                updated_at TEXT,
                deleted INTEGER,
                is_favorite INTEGER DEFAULT 0,
                category TEXT DEFAULT 'General',
                custom_fields TEXT DEFAULT '[]',
                password_history TEXT DEFAULT '[]',
                totp_secret TEXT
              )
            ''');
            await db.execute('''
              CREATE TABLE attachments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                entry_id TEXT,
                file_name TEXT,
                mime_type TEXT,
                file_bytes BLOB,
                FOREIGN KEY(entry_id) REFERENCES entries(id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE cache_asset_links (
                package_name TEXT PRIMARY KEY,
                domain TEXT NOT NULL,
                resolved_at INTEGER
              )
            ''');
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            if (oldVersion < 2) {
              await db.execute('ALTER TABLE entries ADD COLUMN is_favorite INTEGER DEFAULT 0;');
              await db.execute('ALTER TABLE entries ADD COLUMN category TEXT DEFAULT \'General\';');
            }
            if (oldVersion < 3) {
              await db.execute('ALTER TABLE entries ADD COLUMN custom_fields TEXT DEFAULT \'[]\';');
            }
            if (oldVersion < 4) {
              await db.execute('ALTER TABLE entries ADD COLUMN password_history TEXT DEFAULT \'[]\';');
            }
            if (oldVersion < 5) {
              await db.execute('''
                CREATE TABLE attachments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  entry_id TEXT,
                  file_name TEXT,
                  mime_type TEXT,
                  file_bytes BLOB,
                  FOREIGN KEY(entry_id) REFERENCES entries(id) ON DELETE CASCADE
                )
              ''');
            }
            if (oldVersion < 6) {
              await db.execute('ALTER TABLE entries ADD COLUMN totp_secret TEXT;');
            }
            if (oldVersion < 7) {
              await db.execute('''
                CREATE TABLE cache_asset_links (
                  package_name TEXT PRIMARY KEY,
                  domain TEXT NOT NULL,
                  resolved_at INTEGER
                )
              ''');
            }
          },
        );
      } else {
        db = await openDatabase(
          path,
          version: 7,
          password: derivedHexKey,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE entries (
                id TEXT PRIMARY KEY,
                title TEXT,
                username TEXT,
                password TEXT,
                website TEXT,
                notes TEXT,
                updated_at TEXT,
                deleted INTEGER,
                is_favorite INTEGER DEFAULT 0,
                category TEXT DEFAULT 'General',
                custom_fields TEXT DEFAULT '[]',
                password_history TEXT DEFAULT '[]',
                totp_secret TEXT
              )
            ''');
            await db.execute('''
              CREATE TABLE attachments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                entry_id TEXT,
                file_name TEXT,
                mime_type TEXT,
                file_bytes BLOB,
                FOREIGN KEY(entry_id) REFERENCES entries(id) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE cache_asset_links (
                package_name TEXT PRIMARY KEY,
                domain TEXT NOT NULL,
                resolved_at INTEGER
              )
            ''');
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            if (oldVersion < 2) {
              await db.execute('ALTER TABLE entries ADD COLUMN is_favorite INTEGER DEFAULT 0;');
              await db.execute('ALTER TABLE entries ADD COLUMN category TEXT DEFAULT \'General\';');
            }
            if (oldVersion < 3) {
              await db.execute('ALTER TABLE entries ADD COLUMN custom_fields TEXT DEFAULT \'[]\';');
            }
            if (oldVersion < 4) {
              await db.execute('ALTER TABLE entries ADD COLUMN password_history TEXT DEFAULT \'[]\';');
            }
            if (oldVersion < 5) {
              await db.execute('''
                CREATE TABLE attachments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  entry_id TEXT,
                  file_name TEXT,
                  mime_type TEXT,
                  file_bytes BLOB,
                  FOREIGN KEY(entry_id) REFERENCES entries(id) ON DELETE CASCADE
                )
              ''');
            }
            if (oldVersion < 6) {
              await db.execute('ALTER TABLE entries ADD COLUMN totp_secret TEXT;');
            }
            if (oldVersion < 7) {
              await db.execute('''
                CREATE TABLE cache_asset_links (
                  package_name TEXT PRIMARY KEY,
                  domain TEXT NOT NULL,
                  resolved_at INTEGER
                )
              ''');
            }
          },
        );
      }

      // Verify the key is correct by executing a lightweight query.
      // If the password is wrong, SQLCipher operations will throw an exception.
      await db.rawQuery('PRAGMA user_version;');
    } catch (e) {
      throw SecureDatabaseException('Incorrect master password or database corruption. Decryption failed.');
    }

    _database = db;
  }

  /// Close the database connection and clear the reference
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Get the local database File path
  Future<String> getDatabasePath() async {
    String databasesPath;
    try {
      databasesPath = await databaseFactory.getDatabasesPath();
    } catch (_) {
      databasesPath = '.';
    }
    return join(databasesPath, _dbName);
  }


  /// Helper to get salt from secure storage or generate a new one if not present
  Future<List<int>> _getOrCreateSalt() async {
    String? storedSaltBase64 = await _secureStorage.read(key: _saltKey);
    if (storedSaltBase64 != null) {
      return base64Decode(storedSaltBase64);
    }

    // Generate new salt
    List<int> newSalt = CryptoService.generateSalt();
    String newSaltBase64 = base64Encode(newSalt);
    await _secureStorage.write(key: _saltKey, value: newSaltBase64);
    return newSalt;
  }

  /// Check if a master password has already been set (i.e., salt exists in storage)
  Future<bool> hasMasterPassword() async {
    final storedSalt = await _secureStorage.read(key: _saltKey);
    return storedSalt != null;
  }


  // ==========================================
  // CRUD OPERATIONS FOR ENTRIES
  // ==========================================

  /// Insert a new password entry
  Future<int> insertEntry(EntryModel entry) async {
    final db = database;
    return await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all non-deleted password entries
  Future<List<EntryModel>> getEntries() async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: 'deleted = ?',
      whereArgs: [0],
      orderBy: 'LOWER(title) ASC',
    );
    return maps.map((map) => EntryModel.fromMap(map)).toList();
  }

  /// Retrieve all entries including soft-deleted ones (useful for synchronization)
  Future<List<EntryModel>> getAllEntriesForSync() async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query('entries');
    return maps.map((map) => EntryModel.fromMap(map)).toList();
  }

  /// Update an existing entry
  Future<int> updateEntry(EntryModel entry) async {
    final db = database;
    final updatedEntry = entry.copyWith(updatedAt: DateTime.now().toIso8601String());
    return await db.update(
      'entries',
      updatedEntry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Soft delete an entry by setting 'deleted' to 1
  Future<int> deleteEntry(String id) async {
    final db = database;
    return await db.update(
      'entries',
      {
        'deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard delete an entry (permanent removal)
  Future<int> hardDeleteEntry(String id) async {
    final db = database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Bulk import SafeInCloud CSV format data in a single transaction.
  Future<int> importSafeInCloudCsv(String csvContent) async {
    final db = database;
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) return 0;

    final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();

    int titleIdx = headers.indexOf('title');
    int usernameIdx = headers.indexOf('username');
    int passwordIdx = headers.indexOf('password');
    int websiteIdx = headers.indexOf('website');
    int notesIdx = headers.indexOf('notes');

    // Fallbacks if headers are not exact
    if (titleIdx == -1) titleIdx = headers.indexWhere((h) => h.contains('title') || h.contains('name') || h.contains('nombre') || h.contains('título'));
    if (usernameIdx == -1) usernameIdx = headers.indexWhere((h) => h.contains('user') || h.contains('login') || h.contains('usuario'));
    if (passwordIdx == -1) passwordIdx = headers.indexWhere((h) => h.contains('pass') || h.contains('contraseña'));
    if (websiteIdx == -1) websiteIdx = headers.indexWhere((h) => h.contains('web') || h.contains('url') || h.contains('link') || h.contains('sitio'));
    if (notesIdx == -1) notesIdx = headers.indexWhere((h) => h.contains('note') || h.contains('desc') || h.contains('nota'));

    int customFieldsIdx = headers.indexWhere((h) => h == 'campos personalizados');

    int importCount = 0;

    await db.transaction((txn) async {
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        String title = '';
        String username = '';
        String password = '';
        String website = '';
        String notes = '';

        if (titleIdx != -1 && titleIdx < row.length) title = row[titleIdx]?.toString() ?? '';
        if (usernameIdx != -1 && usernameIdx < row.length) username = row[usernameIdx]?.toString() ?? '';
        if (passwordIdx != -1 && passwordIdx < row.length) password = row[passwordIdx]?.toString() ?? '';
        if (websiteIdx != -1 && websiteIdx < row.length) website = row[websiteIdx]?.toString() ?? '';
        if (notesIdx != -1 && notesIdx < row.length) notes = row[notesIdx]?.toString() ?? '';

        // Capture extra columns
        List<String> extraInfo = [];
        List<CustomField> parsedCustomFields = [];

        for (int j = 0; j < row.length; j++) {
          if (j == titleIdx || j == usernameIdx || j == passwordIdx || j == websiteIdx || j == notesIdx) {
            continue;
          }

          final val = row[j]?.toString() ?? '';
          if (val.trim().isEmpty) continue;

          if (j == customFieldsIdx) {
            try {
              final List<dynamic> decoded = jsonDecode(val);
              parsedCustomFields = decoded.map((e) => CustomField.fromMap(e as Map<String, dynamic>)).toList();
            } catch (_) {}
            continue;
          }

          final headerName = rows.first[j]?.toString() ?? 'Campo $j';
          extraInfo.add('$headerName: $val');
        }

        if (extraInfo.isNotEmpty) {
          final extraStr = extraInfo.join('\n');
          if (notes.isEmpty) {
            notes = extraStr;
          } else {
            notes = '$notes\n\n-- Campos adicionales --\n$extraStr';
          }
        }

        // Only import if there's at least some identifier
        if (title.trim().isEmpty && username.trim().isEmpty && website.trim().isEmpty) {
          continue;
        }

        final entry = EntryModel(
          title: title,
          username: username,
          password: password,
          website: website,
          notes: notes,
          deleted: false,
          customFields: parsedCustomFields,
        );

        await txn.insert(
          'entries',
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        importCount++;
      }
    });

    return importCount;
  }
  Future<int> importSafeInCloudXml(String xmlContent) async {
    final db = database;
    int importCount = 0;
    try {
      final document = XmlDocument.parse(xmlContent);
      final cards = document.findAllElements('card');

      await db.transaction((txn) async {
        for (final card in cards) {
          String title = card.getAttribute('title') ?? '';
          String notes = card.getAttribute('notes') ?? '';
          String username = '';
          String password = '';
          String website = '';
          List<CustomField> parsedCustomFields = [];

          final fields = card.findAllElements('field');
          for (final field in fields) {
            final type = field.getAttribute('type') ?? '';
            final name = field.getAttribute('name') ?? '';
            final text = field.innerText.trim();
            if (text.isEmpty) continue;

            final nameLower = name.toLowerCase();
            final isPasswordLikely = type == 'password' || nameLower.contains('password') || nameLower.contains('contraseñ');

            if (type == 'login' && username.isEmpty) {
              username = text;
            } else if (isPasswordLikely && password.isEmpty) {
              password = text;
            } else if (type == 'website' && website.isEmpty) {
              website = text;
            } else {
              parsedCustomFields.add(
                CustomField(
                  name: name.isNotEmpty ? name : 'Campo extra',
                  value: text,
                  isSecure: type == 'password' || type == 'pin' || type == 'secret' || isPasswordLikely,
                ),
              );
            }
          }

          if (title.isEmpty && username.isEmpty && website.isEmpty && parsedCustomFields.isEmpty && notes.isEmpty) {
            continue;
          }

          if (title.isEmpty) {
            if (website.isNotEmpty) {
              title = website;
            } else if (username.isNotEmpty) {
              title = username;
            } else if (parsedCustomFields.isNotEmpty) {
              title = parsedCustomFields.first.value;
            } else if (notes.isNotEmpty) {
              title = notes.length > 20 ? '${notes.substring(0, 20)}...' : notes;
            } else {
              title = 'Sin título';
            }
          }

          final entry = EntryModel(
            title: title,
            username: username,
            password: password,
            website: website,
            notes: notes,
            deleted: false,
            customFields: parsedCustomFields,
          );

          await txn.insert(
            'entries',
            entry.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          importCount++;
        }
      });
    } catch (e) {
      throw Exception('Error parseando XML: $e');
    }
    return importCount;
  }

  // ==========================================
  // CRUD OPERATIONS FOR ATTACHMENTS
  // ==========================================

  Future<int> insertAttachment(AttachmentModel attachment) async {
    final db = database;
    return await db.insert('attachments', attachment.toMap());
  }

  /// Get attachments for an entry WITHOUT loading the blob to save memory
  Future<List<AttachmentModel>> getAttachmentsForEntry(String entryId) async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attachments',
      columns: ['id', 'entry_id', 'file_name', 'mime_type'],
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
    return maps.map((map) => AttachmentModel.fromMap(map)).toList();
  }

  /// Get the full attachment including the BLOB data for viewing
  Future<AttachmentModel?> getAttachmentData(int id) async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attachments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AttachmentModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteAttachment(int id) async {
    final db = database;
    return await db.delete(
      'attachments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- DAL Autofill Caching Methods ---

  Future<void> cacheAssetLink(String packageName, String domain) async {
    final db = database;
    await db.insert(
      'cache_asset_links',
      {
        'package_name': packageName,
        'domain': domain,
        'resolved_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCachedDomain(String packageName) async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cache_asset_links',
      columns: ['domain'],
      where: 'package_name = ?',
      whereArgs: [packageName],
    );

    if (maps.isNotEmpty) {
      return maps.first['domain'] as String;
    }
    return null;
  }
}


/// Custom Exception class for Database decryption failure
class SecureDatabaseException implements Exception {
  final String message;
  SecureDatabaseException(this.message);

  @override
  String toString() => 'SecureDatabaseException: $message';
}
