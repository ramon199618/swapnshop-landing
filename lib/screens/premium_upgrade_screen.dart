import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/payment_ids.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/monetization_service.dart';
import '../constants/premium_limits.dart';
import '../config/payment_config.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  bool _isLoading = false;
  @pragma('vm:never-inline')
  // ignore: unused_field
  bool _isPremium = false;
  Map<String, dynamic> _quota = {};
  @pragma('vm:never-inline')
  // ignore: unused_field
  int _daysUntilReset = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser != null) {
        final isPremium =
            await MonetizationService.isUserPremium(currentUser.id);
        final quota = await MonetizationService.getUserQuota(currentUser.id);
        final daysUntilReset = MonetizationService.getDaysUntilReset();

        if (mounted) {
          setState(() {
            _isPremium = isPremium;
            _quota = quota;
            _daysUntilReset = daysUntilReset;
          });
        }
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der User-Daten: $e');
    }
  }

  Future<void> _upgradeToPremium(SubscriptionType type) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Benutzer nicht angemeldet');
      }

      // Starte Payment Flow mit Stripe
      final result = await PaymentService.createPremiumSubscription(
        userId: currentUser.id,
        type: type,
        paymentMethodId:
            PaymentIds.testPaymentMethodId, // TODO: Echte Payment Method ID
      );

      if (result.success) {
        // Aktualisiere UI nach erfolgreicher Zahlung
        await _loadUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          // Kehre mit Erfolg zurück
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Premium-Upgrade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPremiumFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(Icons.swap_horiz, 'Unbegrenzte Swaps pro Monat'),
        _buildFeatureItem(Icons.sell, 'Unbegrenzte Verkäufe'),
        _buildFeatureItem(Icons.store, 'Eigenen Store mit Design'),
        _buildFeatureItem(Icons.campaign, 'Banner-Werbung schalten'),
        _buildFeatureItem(Icons.radar, 'Erweiterte Radius-Features'),
        _buildFeatureItem(Icons.analytics, 'Detaillierte Statistiken'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageLimits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktueller Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildLimitItem(
          'Swap-Inserate',
          _quota['swap_remaining'] ?? 0,
          PremiumLimits.maxFreeSwaps,
          Icons.swap_horiz,
          Colors.blue,
        ),
        _buildLimitItem(
          'Verkäufe',
          _quota['sell_remaining'] ?? 0,
          PremiumLimits.maxFreeSells,
          Icons.sell,
          Colors.green,
        ),
        if (_quota['swap_bonus'] != null && _quota['swap_bonus']! > 0)
          _buildLimitItem(
            'Swap-Bonus',
            _quota['swap_bonus']!,
            -1,
            Icons.star,
            Colors.amber,
          ),
      ],
    );
  }

  Widget _buildLimitItem(
      String label, int current, int max, IconData icon, Color color) {
    final isUnlimited = max == -1;
    final displayText =
        isUnlimited ? '$current (unbegrenzt)' : '$current / $max';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            displayText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium-Abos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: 'Monatsabo',
          price: 'CHF 5.00',
          period: 'pro Monat',
          features: [
            'Unbegrenzte Swaps & Verkäufe',
            'Eigener Store',
            'Banner-Werbung',
            'Erweiterte Features',
          ],
          onTap: () => _upgradeToPremium(SubscriptionType.monthly),
          isPopular: false,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: 'Jahresabo',
          price: 'CHF 54.00',
          period: 'pro Jahr',
          features: [
            'Alle Monatsabo-Features',
            '2 Monate gratis',
            'Beste Preis-Leistung',
            'Früher Zugang zu neuen Features',
          ],
          onTap: () => _upgradeToPremium(SubscriptionType.yearly),
          isPopular: true,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required VoidCallback onTap,
    required bool isPopular,
  }) {
    return Card(
      elevation: isPopular ? 4 : 2,
      color: isPopular ? AppColors.primary.withValues(alpha: 0.05) : null,
      child: Container(
        decoration: isPopular
            ? BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPopular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Empfohlen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isPopular) const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPopular ? AppColors.primary : null,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    period,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? AppColors.primary : null,
                    foregroundColor: isPopular ? Colors.white : null,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Jetzt upgraden',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Upgrade'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUsageLimits(),
                  const SizedBox(height: 32),
                  _buildPremiumFeatures(),
                  const SizedBox(height: 32),
                  _buildSubscriptionPlans(),
                  const SizedBox(height: 32),
                  _buildInfoSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wichtige Informationen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'Kündigung jederzeit möglich',
            Icons.cancel_outlined,
          ),
          _buildInfoItem(
            'Zahlung über sichere Stripe-Infrastruktur',
            Icons.security,
          ),
          _buildInfoItem(
            'Sofortige Aktivierung nach Zahlung',
            Icons.flash_on,
          ),
          _buildInfoItem(
            'Support bei Fragen',
            Icons.support_agent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
