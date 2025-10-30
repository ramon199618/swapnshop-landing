import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/payment_config.dart';

class PaymentService {
  // Singleton-Instanz
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Convenience-Methode für statische Aufrufe
  static PaymentService get instance => _instance;
  static const String _stripeBaseUrl = 'https://api.stripe.com/v1';
  static const String _payrexxBaseUrl = 'https://api.payrexx.com/v1.0';

  // API Keys aus Environment-Variablen (für Produktion)
  static String get _stripePublishableKey =>
      const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
          defaultValue: 'pk_test_placeholder');
  static String get _stripeSecretKey =>
      const String.fromEnvironment('STRIPE_SECRET_KEY',
          defaultValue: 'sk_test_placeholder');
  static String get _payrexxApiKey =>
      const String.fromEnvironment('PAYREXX_API_KEY',
          defaultValue: 'payrexx_test_key');

  // Dynamische Key-Auswahl basierend auf Environment
  static String get stripePublishableKey => _stripePublishableKey;
  static String get stripeSecretKey => _stripeSecretKey;

  /// Initialisiert Stripe (Placeholder für zukünftige Integration)
  static Future<void> initializeStripe() async {
    try {
      // TODO: Implementiere Stripe-Initialisierung
      debugPrint('Stripe-Initialisierung (Placeholder)');
    } catch (e) {
      debugPrint('Fehler bei Stripe-Initialisierung: $e');
      rethrow;
    }
  }

  /// Erstellt eine Premium-Subscription
  static Future<PaymentResult> createPremiumSubscription({
    required String userId,
    required SubscriptionType type,
    required String paymentMethodId,
  }) async {
    try {
      // Im Debug-Modus: Simuliere erfolgreiche Zahlung
      if (kDebugMode) {
        // Simuliere Stripe-API-Call
        await Future.delayed(const Duration(seconds: 2));

        // Aktualisiere Premium-Status in Supabase (placeholder)
        // final success = await SupabaseService().updateUserPremiumStatus(
        //   userId,
        //   true,
        //   expiresAt: _calculateExpiryDateStatic(type),
        // );
        final success = true; // Placeholder

        if (success) {
          return PaymentResult(
            success: true,
            transactionId: 'test_${DateTime.now().millisecondsSinceEpoch}',
            message: 'Premium-Upgrade erfolgreich (Test-Modus)',
          );
        // else {
        //   throw Exception('Fehler beim Aktualisieren des Premium-Status');
        // }
      }

      // TODO: Implementiere echte Stripe-Integration für Production
      throw UnimplementedError(
          'Echte Stripe-Integration noch nicht implementiert');
    } catch (e) {
      debugPrint('Fehler bei Premium-Subscription: $e');
      return PaymentResult(
        success: false,
        message: 'Fehler beim Premium-Upgrade: $e',
      );
    }
  }

  /// Erstellt eine Spende für zusätzliche Swap-Inserate
  static Future<PaymentResult> createDonation({
    required String userId,
    required double amount,
    required String paymentMethodId,
  }) async {
    try {
      // 1. Erstelle Customer bei Stripe
      final customerId = await instance._createOrGetCustomer(userId);

      // 2. Erstelle Payment Intent
      final paymentIntent = await instance._createPaymentIntent(
        customerId: customerId,
        amount: (amount * 100).round(), // Stripe erwartet Cents
        currency: 'chf',
        paymentMethodId: paymentMethodId,
      );

      // 3. Bestätige Payment
      final confirmedPayment =
          await instance._confirmPayment(paymentIntent['id']);

      if (confirmedPayment['status'] == 'succeeded') {
        // 4. Füge Swap-Bonus hinzu (placeholder)
        // await SupabaseService().addSwapBonus(userId: userId, amount: 5);

        // 5. Speichere Donation
        await instance._saveDonationToSupabase(
          userId: userId,
          amount: amount,
          stripePaymentIntentId: confirmedPayment['id'],
          status: 'completed',
        );

        return PaymentResult(
          success: true,
          transactionId: confirmedPayment['id'],
          message: 'Spende erfolgreich - 5 zusätzliche Swaps freigeschaltet',
        );
      } else {
        throw Exception(
            'Payment fehlgeschlagen: ${confirmedPayment['status']}');
      }
    } catch (e) {
      debugPrint('Fehler bei Donation: $e');
      return PaymentResult(
        success: false,
        message: 'Fehler bei der Spende: $e',
      );
    }
  }

  /// Erstellt eine Twint-Zahlung über Payrexx
  static Future<PaymentResult> createTwintPayment({
    required String userId,
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_payrexxBaseUrl/Transaction'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_payrexxApiKey',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency.toUpperCase(),
          'description': description,
          'payment_method': 'twint',
          'success_url': '${PaymentConfig.baseUrl}/payment/success',
          'cancel_url': '${PaymentConfig.baseUrl}/payment/cancel',
          'webhook_url': '${PaymentConfig.baseUrl}/webhook/payrexx',
          'metadata': {
            'user_id': userId,
            'type': 'donation',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentResult(
          success: true,
          transactionId: data['id'],
          message: 'Twint-Zahlung initiiert',
          redirectUrl: data['redirect_url'],
        );
      } else {
        throw Exception('Payrexx API Fehler: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Fehler bei Twint-Zahlung: $e');
      return PaymentResult(
        success: false,
        message: 'Fehler bei Twint-Zahlung: $e',
      );
    }
  }

  /// Verarbeitet Stripe Webhooks
  static Future<void> handleStripeWebhook({
    required String payload,
    required String signature,
    required String webhookSecret,
  }) async {
    try {
      // 1. Validiere Webhook-Signatur
      if (!instance._verifyStripeSignature(payload, signature, webhookSecret)) {
        throw Exception('Ungültige Webhook-Signatur');
      }

      final event = jsonDecode(payload);
      final eventType = event['type'];

      switch (eventType) {
        case 'payment_intent.succeeded':
          await instance._handlePaymentSuccess(event['data']['object']);
          break;
        case 'payment_intent.payment_failed':
          await instance._handlePaymentFailure(event['data']['object']);
          break;
        case 'invoice.payment_succeeded':
          await instance._handleSubscriptionPayment(event['data']['object']);
          break;
        case 'invoice.payment_failed':
          await instance._handleSubscriptionFailure(event['data']['object']);
          break;
        case 'customer.subscription.deleted':
          await instance._handleSubscriptionCancelled(event['data']['object']);
          break;
        default:
          debugPrint('Unbehandelter Webhook-Event: $eventType');
      }
    } catch (e) {
      debugPrint('Fehler bei Webhook-Verarbeitung: $e');
      rethrow;
    }
  }

  /// Verarbeitet Payrexx Webhooks
  static Future<void> handlePayrexxWebhook({
    required String payload,
    required String signature,
  }) async {
    try {
      // 1. Validiere Payrexx-Signatur
      if (!instance._verifyPayrexxSignature(payload, signature)) {
        throw Exception('Ungültige Payrexx-Signatur');
      }

      final event = jsonDecode(payload);
      final status = event['status'];

      if (status == 'confirmed') {
        await instance._handlePayrexxPaymentSuccess(event);
      } else if (status == 'cancelled' || status == 'failed') {
        await instance._handlePayrexxPaymentFailure(event);
      }
    } catch (e) {
      debugPrint('Fehler bei Payrexx-Webhook: $e');
      rethrow;
    }
  }

  // Private Helper-Methoden

  bool _verifyStripeSignature(
      String payload, String signature, String webhookSecret) {
    // TODO: Implementiere echte Stripe-Signatur-Validierung
    return true; // Placeholder
  }

  static Future<String?> _findCustomerByUserId(String userId) async {
    final response = await http.get(
      Uri.parse('$_stripeBaseUrl/customers?metadata[user_id]=$userId'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
      },
    );

    if (response.statusCode == 200) {
      final customers = jsonDecode(response.body);
      if (customers['data'].isNotEmpty) {
        return customers['data'][0]['id'];
      }
    }
    return null;
  }

  // Unused method - keeping for future implementation
  // static Future<Map<String, dynamic>> _createStripeSubscription({
  //   required String customerId,
  //   required SubscriptionType type,
  //   required String paymentMethodId,
  // }) async {
  //   final priceId = _getPriceIdForType(type);
  //
  //   final response = await http.post(
  //     Uri.parse('$_stripeBaseUrl/subscriptions'),
  //     headers: {
  //       'Authorization': 'Bearer $stripeSecretKey',
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'customer': customerId,
  //       'items[0][price]': priceId,
  //       'default_payment_method': paymentMethodId,
  //       'payment_behavior': 'default_incomplete',
  //       'payment_settings[payment_method_types][]': 'card',
  //       'expand[]': 'latest_invoice.payment_intent',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Fehler beim Erstellen der Stripe-Subscription');
  //   }
  // }

  String _getPriceIdForType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.monthly:
        return PaymentConfig.currentPremiumMonthlyPriceId;
      case SubscriptionType.yearly:
        return PaymentConfig.currentPremiumYearlyPriceId;
    }
  }

  /// Berechnet das Ablaufdatum basierend auf dem Subscription-Typ (statisch)
  static DateTime _calculateExpiryDateStatic(SubscriptionType type) {
    final now = DateTime.now();
    switch (type) {
      case SubscriptionType.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case SubscriptionType.yearly:
        return DateTime(now.year + 1, now.month, now.day);
    }
  }

  /// Berechnet das Ablaufdatum basierend auf dem Subscription-Typ (Instanz)
  DateTime _calculateExpiryDate(SubscriptionType type) {
    return _calculateExpiryDateStatic(type);
  }

  Future<String> _createOrGetCustomer(String userId) async {
    // TODO: Implementiere echte Stripe Customer-Erstellung
    return 'cus_test_$userId';
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required String customerId,
    required int amount,
    required String currency,
    required String paymentMethodId,
  }) async {
    final response = await http.post(
      Uri.parse('$_stripeBaseUrl/payment_intents'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': currency,
        'customer': customerId,
        'payment_method': paymentMethodId,
        'confirmation_method': 'manual',
        'confirm': 'true',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Erstellen des Payment Intents');
    }
  }

  Future<Map<String, dynamic>> _confirmPayment(String paymentIntentId) async {
    final response = await http.post(
      Uri.parse('$_stripeBaseUrl/payment_intents/$paymentIntentId/confirm'),
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler bei der Payment-Bestätigung');
    }
  }

  // Entfernt - doppelte Deklaration

  bool _verifyPayrexxSignature(String payload, String signature) {
    // TODO: Implementiere Payrexx-Signatur-Validierung
    return true; // Placeholder
  }

  Future<void> _handlePaymentSuccess(Map<String, dynamic> paymentIntent) async {
    // TODO: Implementiere Payment-Success-Logik
    debugPrint('Payment erfolgreich: ${paymentIntent['id']}');
  }

  Future<void> _handlePaymentFailure(Map<String, dynamic> paymentIntent) async {
    // TODO: Implementiere Payment-Failure-Logik
    debugPrint('Payment fehlgeschlagen: ${paymentIntent['id']}');
  }

  Future<void> _handleSubscriptionPayment(Map<String, dynamic> invoice) async {
    // TODO: Implementiere Subscription-Payment-Logik
    debugPrint('Subscription-Payment erfolgreich: ${invoice['id']}');
  }

  Future<void> _handleSubscriptionFailure(Map<String, dynamic> invoice) async {
    // TODO: Implementiere Subscription-Failure-Logik
    debugPrint('Subscription-Payment fehlgeschlagen: ${invoice['id']}');
  }

  Future<void> _handleSubscriptionCancelled(
      Map<String, dynamic> subscription) async {
    // TODO: Implementiere Subscription-Cancellation-Logik
    debugPrint('Subscription gekündigt: ${subscription['id']}');
  }

  Future<void> _handlePayrexxPaymentSuccess(Map<String, dynamic> event) async {
    // TODO: Implementiere Payrexx-Payment-Success-Logik
    debugPrint('Payrexx-Payment erfolgreich: ${event['id']}');
  }

  Future<void> _handlePayrexxPaymentFailure(Map<String, dynamic> event) async {
    // TODO: Implementiere Payrexx-Payment-Failure-Logik
    debugPrint('Payrexx-Payment fehlgeschlagen: ${event['id']}');
  }

  // Unused method - keeping for future implementation
  // static Future<void> _saveSubscriptionToSupabase({
  //   required String userId,
  //   required String stripeSubscriptionId,
  //   required SubscriptionType type,
  //   required String status,
  // }) async {
  //   // TODO: Implementiere Supabase-Speicherung
  //   debugPrint('Speichere Subscription in Supabase: $stripeSubscriptionId');
  // }

  Future<void> _saveDonationToSupabase({
    required String userId,
    required double amount,
    required String stripePaymentIntentId,
    required String status,
  }) async {
    // TODO: Implementiere Supabase-Speicherung
    debugPrint('Speichere Donation in Supabase: $stripePaymentIntentId');
  }
}

/// Ergebnis einer Zahlung
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String message;
  final String? redirectUrl;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
    this.redirectUrl,
  });
}

/// Typ der Subscription
enum SubscriptionType {
  monthly,
  yearly,
}
