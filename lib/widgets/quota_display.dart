import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/monetization_service.dart';

class QuotaDisplay extends StatefulWidget {
  final String userId;

  const QuotaDisplay({
    super.key,
    required this.userId,
  });

  @override
  State<QuotaDisplay> createState() => _QuotaDisplayState();
}

class _QuotaDisplayState extends State<QuotaDisplay> {
  Map<String, dynamic>? _quotaData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotaData();
  }

  Future<void> _loadQuotaData() async {
    try {
      final quota = await MonetizationService.getUserQuota(widget.userId);
      final isPremium = await MonetizationService.isUserPremium(widget.userId);
      final daysUntilReset = MonetizationService.getDaysUntilReset();

      if (mounted) {
        setState(() {
          _quotaData = {
            'quota': quota,
            'isPremium': isPremium,
            'daysUntilReset': daysUntilReset,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading quota data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_quotaData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Fehler beim Laden der Quota-Daten'),
        ),
      );
    }

    final quota = _quotaData!['quota'] as Map<String, dynamic>;
    final isPremium = _quotaData!['isPremium'] as bool;
    final daysUntilReset = _quotaData!['daysUntilReset'] as int;

    final swapRemaining = quota['swap_remaining'] ?? 0;
    final sellRemaining = quota['sell_remaining'] ?? 0;
    final swapBonus = quota['swap_bonus'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Monatliche Limits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (isPremium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Swap Quota
            _buildQuotaRow(
              'Swap',
              swapRemaining,
              (8 + swapBonus).toInt(),
              Icons.swap_horiz,
              Colors.blue,
              '8 gratis + $swapBonus Bonus',
            ),

            const SizedBox(height: 12),

            // Sell Quota
            _buildQuotaRow(
              'Sell',
              isPremium ? -1 : sellRemaining,
              isPremium ? -1 : 4,
              Icons.sell,
              Colors.green,
              isPremium ? 'Unbegrenzt (Premium)' : '4 gratis',
            ),

            const SizedBox(height: 12),

            // Giveaway (immer unbegrenzt)
            _buildQuotaRow(
              'Giveaway',
              -1,
              -1,
              Icons.card_giftcard,
              Colors.purple,
              'Unbegrenzt',
            ),

            const SizedBox(height: 16),

            // Reset Countdown
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Reset ${_getResetText(daysUntilReset)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaRow(
    String label,
    int remaining,
    int total,
    IconData icon,
    Color color,
    String description,
  ) {
    final isUnlimited = total == -1;
    final remainingText = isUnlimited ? '∞' : remaining.toString();
    final totalText = isUnlimited ? '∞' : total.toString();

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            isUnlimited ? '∞' : '$remainingText/$totalText',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _getResetText(int days) {
    if (days == 0) return 'heute';
    if (days == 1) return 'morgen';
    return 'in $days Tagen';
  }
}
