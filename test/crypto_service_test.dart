import 'package:flutter_test/flutter_test.dart';
import 'package:secure_password_manager/services/crypto_service.dart';

void main() {
  group('CryptoService Tests', () {
    test('Salt generation generates 32 bytes CSPRNG salts', () {
      final salt1 = CryptoService.generateSalt();
      final salt2 = CryptoService.generateSalt();

      expect(salt1.length, 32);
      expect(salt2.length, 32);
      expect(salt1, isNot(equals(salt2)), reason: 'Salts should be unique');
    });

    test('PBKDF2 derives consistent keys from the same password and salt', () async {
      final password = 'SuperSecretMasterPassword123!';
      final salt = List<int>.generate(32, (i) => i * 3);

      final key1 = await CryptoService.deriveKey(password, salt);
      final key2 = await CryptoService.deriveKey(password, salt);

      expect(key1, isNotEmpty);
      expect(key1.length, 64, reason: '32 bytes derived key should produce 64 characters hex string');
      expect(key1, equals(key2), reason: 'Identical inputs should yield identical derived keys');
    });

    test('PBKDF2 derives different keys for different passwords or salts', () async {
      final password1 = 'PasswordOne';
      final password2 = 'PasswordTwo';
      final salt = List<int>.generate(32, (i) => i);

      final key1 = await CryptoService.deriveKey(password1, salt);
      final key2 = await CryptoService.deriveKey(password2, salt);

      expect(key1, isNot(equals(key2)));
    });
  });
}
