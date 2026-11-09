import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final _secureStorage = const FlutterSecureStorage();
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  void Function(bool isPremium)? onPremiumStatusChanged;

  void initialize(void Function(bool isPremium) callback) {
    onPremiumStatusChanged = callback;
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onError: (error) {
        // Handle error silently or pass to a logger
      },
    );
    checkPremiumStatus();
  }

  Future<void> checkPremiumStatus() async {
    final status = await _secureStorage.read(key: 'premium_purchased');
    if (status == 'true') {
      onPremiumStatusChanged?.call(true);
    } else {
      onPremiumStatusChanged?.call(false);
    }
  }

  Future<void> buyPremium() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Billing service unavailable. Please check your internet connection and Google Play Services.');
    }

    const Set<String> kIds = <String>{'cerberus_premium_lifetime'};
    final ProductDetailsResponse response = await _iap.queryProductDetails(kIds);
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception(
        'Product ID "cerberus_premium_lifetime" not found on Google Play.\n\n'
        'Troubleshooting Checklist:\n'
        '1. Ensure the package name in android/app/build.gradle matches your Google Play Console configuration exactly.\n'
        '2. Verify that the product ID "cerberus_premium_lifetime" is created, set as "Active" in the Play Console under In-App Products.\n'
        '3. Make sure the signed app (APK/AAB) has been uploaded to a testing track (Internal or Closed Testing) and has been approved.\n'
        '4. Confirm the email logged into Google Play Store on this device is added to the List of Testers for that active track.\n'
        '5. Verify that your Google Play Console Merchant Account is fully setup and active.'
      );
    }

    if (response.productDetails.isEmpty) {
      throw Exception('Failed to load purchase details from Google Play.');
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('alreadyowned') || errStr.contains('billingresponsecode: 7') || errStr.contains('responsecode: 7') || errStr.contains('already owned')) {
        // Automatically deliver premium if already owned!
        await _deliverProduct(PurchaseDetails(
          purchaseID: 'restored_on_buy_attempt',
          productID: 'cerberus_premium_lifetime',
          status: PurchaseStatus.restored,
          transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
          verificationData: PurchaseVerificationData(
            localVerificationData: '',
            serverVerificationData: '',
            source: '',
          ),
        ));
        return;
      }
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Billing service unavailable. Please check your internet connection.');
    }
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        // Pending purchase
      } else if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        _deliverProduct(purchase);
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    if (purchase.productID == 'cerberus_premium_lifetime') {
      await _secureStorage.write(key: 'premium_purchased', value: 'true');
      await _secureStorage.write(key: 'had_premium_before', value: 'true');
      onPremiumStatusChanged?.call(true);
    }
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
