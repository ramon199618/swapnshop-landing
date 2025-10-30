import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/payment_ids.dart';

class LimitDialog extends StatefulWidget {
  final String category;
  final int remaining;
  final int maxFree;
  final Function(String priceId)? onRequestPurchase; // Callback für Payment-Requests

  const LimitDialog({
    super.key,
    required this.category,
    required this.remaining,
    required this.maxFree,
    this.onRequestPurchase,
  });

  @override
  State<LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<LimitDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isSwap = widget.category.toLowerCase() == 'swap';
    final isSell = widget.category.toLowerCase() == 'sell';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Icon(
              isSwap ? Icons.swap_horiz : Icons.sell,
              size: 48,
              color: isSwap ? Colors.blue : Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Limit erreicht!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Du hast dein ${isSwap ? 'Swap' : 'Verkaufs'}-Limit für diesen Monat erreicht.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Current Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Aktueller Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Verwendet:'),
                      Text(
                        '${widget.maxFree - widget.remaining} / ${widget.maxFree}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Verbleibend:'),
                      Text(
                        '${widget.remaining}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Solutions
            if (isSwap) ...[
              // Swap: Spende für zusätzliche Inserate
              _buildSolutionCard(
                title: 'Spende für zusätzliche Swaps',
                description: 'CHF 1 für 5 zusätzliche Swap-Inserate',
                icon: Icons.favorite,
                color: AppColors.primary,
                onTap: () => _handleDonation(),
              ),
              const SizedBox(height: 16),
            ],

            if (isSell) ...[
              // Sell: Premium-Upgrade
              _buildSolutionCard(
                title: 'Premium-Upgrade',
                description: 'Unbegrenzte Verkäufe und mehr Features',
                icon: Icons.star,
                color: AppColors.primary,
                onTap: () => _handlePremiumUpgrade(),
              ),
            ],

            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text('Schließen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDonation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Implementiere echte Payment-Integration
      if (widget.onRequestPurchase != null) {
        // Verwende den Callback für Payment-Requests
        widget.onRequestPurchase!(PaymentIds.donationSmall);
      } else {
        // Fallback: Simuliere erfolgreiche Spende
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Spende erfolgreich! 5 zusätzliche Swaps freigeschaltet.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Spende: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePremiumUpgrade() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Implementiere echte Payment-Integration
      if (widget.onRequestPurchase != null) {
        // Verwende den Callback für Payment-Requests
        widget.onRequestPurchase!(PaymentIds.premiumMonthly);
      } else {
        // Fallback: Simuliere erfolgreichen Upgrade
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premium-Upgrade erfolgreich!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Premium-Upgrade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
