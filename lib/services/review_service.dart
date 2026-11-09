import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final InAppReview _inAppReview = InAppReview.instance;

  /// Records the first open date if not already recorded.
  Future<void> recordFirstOpenDate() async {
    final firstOpenStr = await _secureStorage.read(key: 'first_open_date');
    if (firstOpenStr == null) {
      await _secureStorage.write(
        key: 'first_open_date',
        value: DateTime.now().toIso8601String(),
      );
    }
  }

  /// Evaluates all conditions and requests a store review if eligible.
  Future<void> checkAndRequestReview(int passwordCount) async {
    try {
      // 1. Record/ensure first open date exists
      await recordFirstOpenDate();

      // 2. Check password count condition (5 or more)
      if (passwordCount < 5) {
        return;
      }

      // 3. Check days since first open condition (10 or more days)
      final firstOpenStr = await _secureStorage.read(key: 'first_open_date');
      if (firstOpenStr == null) return;
      final firstOpenDate = DateTime.tryParse(firstOpenStr);
      if (firstOpenDate == null) return;

      final daysSinceFirstOpen = DateTime.now().difference(firstOpenDate).inDays;
      if (daysSinceFirstOpen < 10) {
        return;
      }

      // 4. Check request history conditions
      final wasRequestedStr = await _secureStorage.read(key: 'review_requested');
      final wasRequested = wasRequestedStr == 'true';

      if (wasRequested) {
        final lastRequestStr = await _secureStorage.read(key: 'last_review_request_date');
        if (lastRequestStr != null) {
          final lastRequestDate = DateTime.tryParse(lastRequestStr);
          if (lastRequestDate != null) {
            final daysSinceLastRequest = DateTime.now().difference(lastRequestDate).inDays;
            // 6 months is approximately 180 days
            if (daysSinceLastRequest < 180) {
              return;
            }
          }
        }
      }

      // 5. Check if in-app reviews are supported by the platform/device
      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) {
        return;
      }

      // 6. Request the native review dialog
      await _inAppReview.requestReview();

      // 7. Update storage flags
      final nowStr = DateTime.now().toIso8601String();
      await _secureStorage.write(key: 'review_requested', value: 'true');
      await _secureStorage.write(key: 'last_review_request_date', value: nowStr);
    } catch (_) {
      // Fail silently to avoid breaking the user experience
    }
  }
}
