import '../models/entry_model.dart';
import 'dart:math';

class SecurityHealthReport {
  final double score;
  final double baseScore;
  final bool isCapped;
  final String? capReason;
  final List<EntryModel> weakEntries;
  final Map<String, List<EntryModel>> reusedEntriesGroups; // Map of password -> entries sharing it
  final List<EntryModel> secureEntries;
  final Map<String, double> entryScores; // Map of entry ID -> individual score P_i

  SecurityHealthReport({
    required this.score,
    required this.baseScore,
    required this.isCapped,
    this.capReason,
    required this.weakEntries,
    required this.reusedEntriesGroups,
    required this.secureEntries,
    required this.entryScores,
  });
}

class SecurityHealthService {
  // List of very common simple passwords
  static const Set<String> _commonPasswords = {
    '123456',
    'password',
    '12345678',
    'qwerty',
    '12345',
    '123456789',
    '1234',
    '111111',
    '1234567',
    'hola',
    'admin',
  };

  /// Calculates individual password score P_i (0 to 100)
  static double calculatePasswordScore(String password, {required bool isReused}) {
    if (password.isEmpty) return 0.0;

    final isCommon = _commonPasswords.contains(password.toLowerCase().trim());

    // Calculate character sets count (1 to 4)
    int characterSetsCount = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) characterSetsCount++;
    if (RegExp(r'[A-Z]').hasMatch(password)) characterSetsCount++;
    if (RegExp(r'[0-9]').hasMatch(password)) characterSetsCount++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) characterSetsCount++;

    double baseScore;

    // Escenario A: Débil (30 pts)
    // length < 8 OR common password OR characterSetsCount <= 1
    if (password.length < 8 || isCommon || characterSetsCount <= 1) {
      baseScore = 30.0;
    }
    // Escenario C: Fuerte (100 pts)
    // length >= 12 AND characterSetsCount >= 3
    else if (password.length >= 12 && characterSetsCount >= 3) {
      baseScore = 100.0;
    }
    // Escenario B: Media (70 pts)
    // Cómputo por defecto para combinaciones intermedias (ej. 8-11 con >= 2 tipos, o >= 12 con solo 2 tipos)
    else {
      baseScore = 70.0;
    }

    if (isReused) {
      // Reused password penalty: max 30 points allowed
      baseScore = min(baseScore - 40.0, 30.0);
      if (baseScore < 0.0) baseScore = 0.0;
    }

    return baseScore;
  }

  static SecurityHealthReport analyze(List<EntryModel> entries) {
    if (entries.isEmpty) {
      return SecurityHealthReport(
        score: 100.0,
        baseScore: 100.0,
        isCapped: false,
        weakEntries: [],
        reusedEntriesGroups: {},
        secureEntries: [],
        entryScores: {},
      );
    }

    final Map<String, List<EntryModel>> passwordGrouping = {};
    for (final entry in entries) {
      final pwd = entry.password;
      if (pwd.isNotEmpty) {
        passwordGrouping.putIfAbsent(pwd, () => []).add(entry);
      }
    }

    // Find reused passwords
    final Map<String, List<EntryModel>> reusedEntriesGroups = {};
    final Set<String> reusedPasswords = {};
    passwordGrouping.forEach((password, group) {
      if (group.length > 1) {
        reusedEntriesGroups[password] = group;
        reusedPasswords.add(password);
      }
    });

    final List<EntryModel> weakEntries = [];
    final List<EntryModel> secureEntries = [];
    final Map<String, double> entryScores = {};

    for (final entry in entries) {
      final pwd = entry.password;
      final isReused = reusedPasswords.contains(pwd);
      final isCommon = _commonPasswords.contains(pwd.toLowerCase().trim());
      final isWeak = pwd.length < 8 || isCommon;

      if (isWeak) {
        weakEntries.add(entry);
      }

      final score = calculatePasswordScore(pwd, isReused: isReused);
      entryScores[entry.id] = score;

      if (score >= 80.0 && !isReused) {
        secureEntries.add(entry);
      }
    }

    // 1. Calculate Base Score: Sum(P_i) / N
    final double totalPoints = entryScores.values.fold(0.0, (sum, val) => sum + val);
    final double baseScore = totalPoints / entries.length;

    // 2. Apply Caps for Critical Risk Rules
    double finalScore = baseScore;
    bool isCapped = false;
    final List<String> capReasons = [];

    // Rule A: If there is at least 1 critical weak password (P_i <= 40), max score is 50%
    final bool hasCriticalWeak = entryScores.values.any((s) => s <= 40.0);
    if (hasCriticalWeak && finalScore > 50.0) {
      finalScore = 50.0;
      isCapped = true;
      capReasons.add('critical_weak');
    }

    // Rule B: If password reuse rate > 30%, max score is 60%
    final int reusedEntriesCount = entries.where((e) => reusedPasswords.contains(e.password)).length;
    final double reuseRate = reusedEntriesCount / entries.length;
    if (reuseRate > 0.30 && finalScore > 60.0) {
      finalScore = 60.0;
      isCapped = true;
      capReasons.add('high_reuse');
    }

    return SecurityHealthReport(
      score: finalScore,
      baseScore: baseScore,
      isCapped: isCapped,
      capReason: capReasons.isNotEmpty ? capReasons.join(', ') : null,
      weakEntries: weakEntries,
      reusedEntriesGroups: reusedEntriesGroups,
      secureEntries: secureEntries,
      entryScores: entryScores,
    );
  }
}

