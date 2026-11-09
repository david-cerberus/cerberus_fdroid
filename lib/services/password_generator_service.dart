import 'dart:math';

class PasswordRecipe {
  final int length;

  PasswordRecipe({
    required this.length,
  });

  Map<String, dynamic> toJson() => {
        'length': length,
      };

  factory PasswordRecipe.fromJson(Map<String, dynamic> json) {
    return PasswordRecipe(
      length: json['length'] ?? 16,
    );
  }

  static PasswordRecipe get defaultRecipe => PasswordRecipe(
        length: 16,
      );
}

class PasswordGeneratorService {
  static final Random _random = Random.secure();

  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  /// Generates a strong password of the specified length.
  /// It always includes at least one uppercase, one lowercase, one number, and one symbol.
  static String generate(String title, {PasswordRecipe? recipe}) {
    final activeRecipe = recipe ?? PasswordRecipe.defaultRecipe;
    int length = activeRecipe.length;
    
    if (length < 4) {
      length = 4; // Minimum length to satisfy requirements
    }

    // Ensure at least one of each required type
    List<String> passwordChars = [
      _lowercase[_random.nextInt(_lowercase.length)],
      _uppercase[_random.nextInt(_uppercase.length)],
      _numbers[_random.nextInt(_numbers.length)],
      _symbols[_random.nextInt(_symbols.length)],
    ];

    final String allChars = _lowercase + _uppercase + _numbers + _symbols;

    // Fill the rest randomly
    for (int i = 4; i < length; i++) {
      passwordChars.add(allChars[_random.nextInt(allChars.length)]);
    }

    // Shuffle the characters so the required ones aren't always at the beginning
    passwordChars.shuffle(_random);

    return passwordChars.join('');
  }
}

