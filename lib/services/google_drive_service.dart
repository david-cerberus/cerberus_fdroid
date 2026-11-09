import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  static const String _dbFileName = 'secure_entries.db';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '288535937298-83mkuhg21gcn5oppvmgpc3c6ofk06o1u.apps.googleusercontent.com',
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Check if the user is already signed in to Google
  Future<GoogleSignInAccount?> checkCurrentUser() async {
    _currentUser = await _googleSignIn.signInSilently();
    return _currentUser;
  }

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out of Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  /// Get authenticated Drive API client
  Future<drive.DriveApi> _getDriveApi() async {
    final user = _currentUser ?? await _googleSignIn.signInSilently();
    if (user == null) {
      throw Exception('El usuario no ha iniciado sesión en Google.');
    }

    final headers = await user.authHeaders;
    final client = GoogleAuthClient(headers);
    return drive.DriveApi(client);
  }

  /// Upload the encrypted database file to the user's appDataFolder in Google Drive
  Future<void> uploadDatabase(File localFile) async {
    final driveApi = await _getDriveApi();

    // Read salt from secure storage to backup in metadata properties
    const storage = FlutterSecureStorage();
    final saltBase64 = await storage.read(key: 'master_password_salt');

    // 1. Search for existing file in the appDataFolder
    final fileList = await driveApi.files.list(
      q: "name = '$_dbFileName' and 'appDataFolder' in parents and trashed = false",
      spaces: 'appDataFolder',
      $fields: 'files(id, name)',
    );

    final files = fileList.files;
    final mediaStream = localFile.openRead();
    final media = drive.Media(mediaStream, await localFile.length());

    if (files != null && files.isNotEmpty) {
      // 2. File exists: update it
      final existingFileId = files.first.id!;
      final updatedFile = drive.File()
        ..properties = saltBase64 != null ? {'salt': saltBase64} : null;
      await driveApi.files.update(
        updatedFile,
        existingFileId,
        uploadMedia: media,
      );
    } else {
      // 3. File doesn't exist: create it
      final newFile = drive.File()
        ..name = _dbFileName
        ..parents = ['appDataFolder']
        ..properties = saltBase64 != null ? {'salt': saltBase64} : null;

      await driveApi.files.create(
        newFile,
        uploadMedia: media,
      );
    }
  }

  /// Download the encrypted database file from the user's appDataFolder in Google Drive
  /// and overwrite the local file at the specified path.
  Future<File?> downloadDatabase(String localPath) async {
    final driveApi = await _getDriveApi();

    // 1. Search for existing file in the appDataFolder
    final fileList = await driveApi.files.list(
      q: "name = '$_dbFileName' and 'appDataFolder' in parents and trashed = false",
      spaces: 'appDataFolder',
      $fields: 'files(id, name, properties)',
    );

    final files = fileList.files;
    if (files == null || files.isEmpty) {
      return null; // File not found in Google Drive appDataFolder
    }

    final file = files.first;
    final fileId = file.id!;

    // Retrieve and restore salt in secure storage if present
    final saltBase64 = file.properties?['salt'];
    if (saltBase64 != null) {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'master_password_salt', value: saltBase64);
    }

    // 2. Download the file media
    final drive.Media response = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    // 3. Write response stream to the local file
    final localFile = File(localPath);
    
    // Ensure parent directory exists
    if (!await localFile.parent.exists()) {
      await localFile.parent.create(recursive: true);
    }

    final iosink = localFile.openWrite();
    await response.stream.pipe(iosink);
    
    return localFile;
  }

  /// Delete the encrypted database file from the user's appDataFolder in Google Drive
  Future<void> deleteDatabase() async {
    final driveApi = await _getDriveApi();

    // 1. Search for existing file in the appDataFolder
    final fileList = await driveApi.files.list(
      q: "name = '$_dbFileName' and 'appDataFolder' in parents and trashed = false",
      spaces: 'appDataFolder',
      $fields: 'files(id, name)',
    );

    final files = fileList.files;
    if (files == null || files.isEmpty) {
      return; // File not found, nothing to delete
    }

    final fileId = files.first.id!;

    // 2. Delete the file
    await driveApi.files.delete(fileId);
  }
}

/// Helper class to automatically supply authorization headers for googleapis.
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
