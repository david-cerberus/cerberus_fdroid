import 'dart:math';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  /// Generate a cryptographically secure random salt of 32 bytes.
  static List<int> generateSalt() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }

  /// Derive a 32-byte key from the master password and salt using PBKDF2
  /// with HMAC-SHA256 and 600,000 iterations. Returns a hex string representation.
  static Future<String> deriveKey(String masterPassword, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac(Sha256()),
      iterations: 600000,
      bits: 256,
    );

    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: masterPassword,
      nonce: salt,
    );

    final keyBytes = await secretKey.extractBytes();
    
    // Convert derived key bytes to a Hexadecimal string
    return keyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
