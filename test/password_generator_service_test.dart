import 'package:flutter_test/flutter_test.dart';
import 'package:secure_password_manager/services/password_generator_service.dart';

void main() {
  group('PasswordGeneratorService Tests', () {
    test('Generated password matches expected pattern structural constraints', () {
      final pwd = PasswordGeneratorService.generate('Google');
      
      // Starts with Key
      expect(pwd.startsWith('Key'), isTrue);
      
      // Next 2 digits should be 10, 20 or 30
      final numberPart = pwd.substring(3, 5);
      expect(['10', '20', '30'].contains(numberPart), isTrue);
      
      // Symbol _ is present
      expect(pwd[5], '_');
      
      // Ends with 6 characters
      final ending = pwd.substring(6);
      expect(ending.length, 6);
      
      // Exactly one character in ending is uppercase
      int uppercaseCount = 0;
      for (int i = 0; i < ending.length; i++) {
        if (ending[i] == ending[i].toUpperCase()) {
          uppercaseCount++;
        }
      }
      expect(uppercaseCount, 1);
    });

    test('Pads short titles correctly to reach 12 total characters', () {
      final pwd = PasswordGeneratorService.generate('a');
      expect(pwd.length, 12); // Key (3) + Number (2) + _ (1) + Ending (6) = 12
      
      final ending = pwd.substring(6);
      expect(ending.startsWith('a') || ending.startsWith('A'), isTrue);
      
      // Clean alphabet characters only
      expect(RegExp(r'^[a-zA-Z]+$').hasMatch(ending), isTrue);
    });
  });
}
