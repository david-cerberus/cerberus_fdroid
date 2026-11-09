import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/purchase_service.dart';
import '../l10n/app_localizations.dart';

// Global notifier for premium status (defaults to true while free / in-app products disabled)
final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(true);

class PremiumGate extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PremiumGate({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPremiumNotifier,
      builder: (context, isPremium, _) {
        if (isPremium) {
          return InkWell(
            onTap: onTap,
            child: AbsorbPointer(
              child: child,
            ),
          );
        } else {
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const PremiumPurchaseDialog(),
              );
            },
            child: AbsorbPointer(
              child: child,
            ),
          );
        }
      },
    );
  }
}

class PremiumPurchaseDialog extends StatefulWidget {
  const PremiumPurchaseDialog({super.key});

  @override
  State<PremiumPurchaseDialog> createState() => _PremiumPurchaseDialogState();
}

class _PremiumPurchaseDialogState extends State<PremiumPurchaseDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _showRestoreButton = false;

  @override
  void initState() {
    super.initState();
    _checkRestoreStatus();
  }

  Future<void> _checkRestoreStatus() async {
    const storage = FlutterSecureStorage();
    final hadPremium = await storage.read(key: 'had_premium_before') == 'true';
    final hasSync = await storage.read(key: 'google_drive_enabled') == 'true';
    if (hadPremium || hasSync) {
      setState(() {
        _showRestoreButton = true;
      });
    }
  }

  Future<void> _handleBuy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await PurchaseService().buyPremium();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await PurchaseService().restorePurchases();
      // Give a tiny delay for billing streams to update and trigger persistence check
      await Future.delayed(const Duration(seconds: 1));
      await PurchaseService().checkPremiumStatus();
      if (mounted) {
        // Here we don't have isPremiumNotifier, so we must check FlutterSecureStorage or assume checkPremiumStatus would have called the callback which updates some state.
        // Actually, let's just check the storage right here.
        final storage = const FlutterSecureStorage();
        final status = await storage.read(key: 'premium_purchased');
        if (status == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.premiumSuccessMessage),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(AppLocalizations.of(context)!.noPreviousPurchases),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/premium_shield.png',
                width: 36,
                height: 36,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.premiumTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.premiumSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(context, Icons.cloud_done_rounded, l10n.premiumFeatureDriveTitle, l10n.premiumFeatureDriveSubtitle),
          _buildFeatureRow(context, Icons.import_export_rounded, l10n.premiumFeatureCsvTitle, l10n.premiumFeatureCsvSubtitle),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _handleBuy,
              child: Text(l10n.premiumBuyButton, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _handleRestore,
              child: Text(l10n.premiumRestoreButton),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
