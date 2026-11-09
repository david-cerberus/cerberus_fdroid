import 'package:flutter_test/flutter_test.dart';
import 'package:secure_password_manager/models/entry_model.dart';
import 'package:secure_password_manager/services/security_health_service.dart';

void main() {
  group('SecurityHealthService Tests', () {
    test('Empty entries returns 100% score', () {
      final report = SecurityHealthService.analyze([]);
      expect(report.score, 100.0);
      expect(report.weakEntries, isEmpty);
      expect(report.reusedEntriesGroups, isEmpty);
      expect(report.secureEntries, isEmpty);
    });

    test('Identifies weak passwords correctly', () {
      final entries = [
        EntryModel(id: '1', title: 'Google', username: 'u', password: '123', website: '', notes: ''),
        EntryModel(id: '2', title: 'Facebook', username: 'u', password: 'password', website: '', notes: ''),
        EntryModel(id: '3', title: 'Secure', username: 'u', password: 'MySuperSecurePassword123!', website: '', notes: ''),
      ];

      final report = SecurityHealthService.analyze(entries);
      expect(report.weakEntries.length, 2);
      expect(report.weakEntries.any((e) => e.title == 'Google'), isTrue);
      expect(report.weakEntries.any((e) => e.title == 'Facebook'), isTrue);
      expect(report.secureEntries.length, 1);
      expect(report.secureEntries.first.title, 'Secure');
      // Score: 1 / 3 = 33.33%
      expect(report.score, closeTo(33.33, 0.05));
    });

    test('Identifies reused passwords correctly', () {
      final entries = [
        EntryModel(id: '1', title: 'Netflix', username: 'u', password: 'SamePassword123!', website: '', notes: ''),
        EntryModel(id: '2', title: 'Spotify', username: 'u', password: 'SamePassword123!', website: '', notes: ''),
        EntryModel(id: '3', title: 'Bank', username: 'u', password: 'VerySecureUniquePassword99!', website: '', notes: ''),
      ];

      final report = SecurityHealthService.analyze(entries);
      expect(report.reusedEntriesGroups.length, 1);
      expect(report.reusedEntriesGroups['SamePassword123!']!.length, 2);
      expect(report.secureEntries.length, 1);
      expect(report.secureEntries.first.title, 'Bank');
      // Score: 1 / 3 = 33.33%
      expect(report.score, closeTo(33.33, 0.05));
    });
  });
}
