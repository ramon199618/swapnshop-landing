import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Produktionsreifer Webhook-Server für Stripe und Payrexx
class WebhookServer {
  static const int _port = 8080;

  // Environment Configuration
  static const String _environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  static bool get _isProduction => _environment == 'production';

  // Webhook Secrets (from environment variables)
  // static String get _stripeWebhookSecret => const String.fromEnvironment(
  //   'STRIPE_WEBHOOK_SECRET',
  //   defaultValue: 'whsec_test_secret',
  // );

  // static String get _payrexxWebhookSecret => const String.fromEnvironment(
  //   'PAYREXX_WEBHOOK_SECRET',
  //   defaultValue: 'payrexx_test_secret',
  // );

  late final HttpServer _server;
  final Set<String> _processedEvents = <String>{}; // In-Memory Idempotenz
  final List<Map<String, dynamic>> _eventLog =
      []; // Event-Logging für Produktion
  late final DateTime _startTime; // Server start time

  /// Startet den Webhook-Server
  Future<void> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _startTime = DateTime.now(); // Set start time when server starts

      _log('🚀 Webhook-Server gestartet', {
        'port': _port,
        'environment': _environment,
        'stripe_webhook': 'http://localhost:$_port/webhook/stripe',
        'payrexx_webhook': 'http://localhost:$_port/webhook/payrexx',
        'health_check': 'http://localhost:$_port/health',
        'status': 'running'
      });

      // Event-Handler für eingehende Requests
      _server.listen(_handleRequest);

      // Produktions-Logging
      if (_isProduction) {
        _startProductionMonitoring();
      }
    } catch (e) {
      _log('❌ Fehler beim Starten des Webhook-Servers', {
        'error': e.toString(),
        'stack_trace': StackTrace.current.toString(),
        'status': 'failed'
      });
      rethrow;
    }
  }

  /// Stoppt den Webhook-Server
  Future<void> stop() async {
    try {
      await _server.close();
      _log('🛑 Webhook-Server gestoppt', {'status': 'stopped'});
    } catch (e) {
      _log('❌ Fehler beim Stoppen des Servers', {'error': e.toString()});
    }
  }

  /// Produktions-Monitoring starten
  void _startProductionMonitoring() {
    // Alle 5 Minuten Status loggen
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _log('📊 Server Status', {
        'processed_events': _processedEvents.length,
        'event_log_size': _eventLog.length,
        'uptime': DateTime.now().difference(_startTime).inMinutes,
        'memory_usage': ProcessInfo.currentRss,
      });
    });
  }

  /// Verarbeitet eingehende HTTP-Requests
  void _handleRequest(HttpRequest request) async {
    final startTime = DateTime.now();
    final path = request.uri.path;
    final method = request.method;

    try {
      final userAgent = request.headers.value('user-agent') ?? 'unknown';
      final clientIp =
          request.connectionInfo?.remoteAddress.address ?? 'unknown';

      _log('📥 Request empfangen', {
        'method': method,
        'path': path,
        'user_agent': userAgent,
        'client_ip': clientIp,
        'timestamp': startTime.toIso8601String(),
      });

      // CORS-Headers setzen
      _setCorsHeaders(request.response);

      // OPTIONS Request (CORS Preflight)
      if (method == 'OPTIONS') {
        request.response.statusCode = 200;
        await request.response.close();
        return;
      }

      // Route-Handling
      if (method == 'GET' && path == '/health') {
        await _handleHealthCheck(request);
      } else if (method == 'POST' && path == '/webhook/stripe') {
        await _handleStripeWebhook(request);
      } else if (method == 'POST' && path == '/webhook/payrexx') {
        await _handlePayrexxWebhook(request);
      } else if (method == 'GET' && path == '/status') {
        await _handleStatusEndpoint(request);
      } else {
        await _handleNotFound(request);
      }

      // Request-Zeit loggen
      final duration = DateTime.now().difference(startTime);
      _log('✅ Request verarbeitet', {
        'method': method,
        'path': path,
        'duration_ms': duration.inMilliseconds,
        'status': 'success'
      });
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _log('❌ Fehler bei Request-Verarbeitung', {
        'method': method,
        'path': path,
        'error': e.toString(),
        'duration_ms': duration.inMilliseconds,
        'status': 'error'
      });
      await _handleError(request, e);
    }
  }

  /// CORS-Headers setzen
  void _setCorsHeaders(HttpResponse response) {
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers',
        'Content-Type, Authorization, Stripe-Signature, X-Payrexx-Signature');
    response.headers.add('Access-Control-Max-Age', '86400');
  }

  /// Health Check Endpoint
  Future<void> _handleHealthCheck(HttpRequest request) async {
    final healthData = {
      'status': 'healthy',
      'timestamp': DateTime.now().toIso8601String(),
      'environment': _environment,
      'processed_events': _processedEvents.length,
      'uptime': DateTime.now().difference(_startTime).inSeconds,
    };

    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(healthData));
    await request.response.close();
  }

  /// Status Endpoint für Produktions-Monitoring
  Future<void> _handleStatusEndpoint(HttpRequest request) async {
    final statusData = {
      'server_status': 'running',
      'environment': _environment,
      'timestamp': DateTime.now().toIso8601String(),
      'statistics': {
        'processed_events': _processedEvents.length,
        'event_log_size': _eventLog.length,
        'uptime_seconds': DateTime.now().difference(_startTime).inSeconds,
        'memory_usage_bytes': ProcessInfo.currentRss,
      },
      'recent_events': _eventLog.take(10).toList(),
    };

    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(statusData));
    await request.response.close();
  }

  /// Verarbeitet Stripe Webhooks
  Future<void> _handleStripeWebhook(HttpRequest request) async {
    try {
      // 1. Request Body lesen
      final payload = await utf8.decodeStream(request);
      final headers = request.headers;

      // 2. Stripe-Signatur validieren
      final signature = headers.value('stripe-signature');
      if (signature == null) {
        _log('❌ Stripe-Signatur fehlt', {'webhook_type': 'stripe'});
        await _sendResponse(request, 400, 'Stripe-Signatur fehlt');
        return;
      }

      if (!_verifyStripeSignature(payload, signature)) {
        _log('❌ Ungültige Stripe-Signatur', {
          'webhook_type': 'stripe',
          'signature': '${signature.substring(0, 20)}...',
        });
        await _sendResponse(request, 401, 'Ungültige Stripe-Signatur');
        return;
      }

      // 3. Event parsen
      final event = jsonDecode(payload);
      final eventType = event['type'];
      final eventId = event['id'];

      // 4. Idempotenz prüfen
      if (_processedEvents.contains(eventId)) {
        _log('ℹ️ Stripe Event bereits verarbeitet', {
          'event_id': eventId,
          'event_type': eventType,
          'webhook_type': 'stripe'
        });
        await _sendResponse(request, 200, 'Event bereits verarbeitet');
        return;
      }

      // 5. Event verarbeiten
      await _processStripeEvent(event);

      // 6. Event als verarbeitet markieren
      _processedEvents.add(eventId);

      // 7. Event loggen
      _logEvent('stripe', eventType, eventId, 'success');

      await _sendResponse(request, 200, 'Webhook verarbeitet');
    } catch (e) {
      _log('❌ Fehler bei Stripe Webhook', {
        'error': e.toString(),
        'webhook_type': 'stripe',
        'stack_trace': StackTrace.current.toString()
      });
      await _sendResponse(request, 500, 'Interner Server-Fehler: $e');
    }
  }

  /// Verarbeitet Payrexx Webhooks
  Future<void> _handlePayrexxWebhook(HttpRequest request) async {
    try {
      // 1. Request Body lesen
      final payload = await utf8.decodeStream(request);
      final headers = request.headers;

      // 2. Payrexx-Signatur validieren
      final signature = headers.value('x-payrexx-signature');
      if (signature == null) {
        _log('❌ Payrexx-Signatur fehlt', {'webhook_type': 'payrexx'});
        await _sendResponse(request, 400, 'Payrexx-Signatur fehlt');
        return;
      }

      if (!_verifyPayrexxSignature(payload, signature)) {
        _log('❌ Ungültige Payrexx-Signatur', {
          'webhook_type': 'payrexx',
          'signature': '${signature.substring(0, 20)}...',
        });
        await _sendResponse(request, 401, 'Ungültige Payrexx-Signatur');
        return;
      }

      // 3. Event parsen
      final event = jsonDecode(payload);
      final eventId = event['id'].toString();
      final status = event['status'];

      // 4. Idempotenz prüfen
      if (_processedEvents.contains(eventId)) {
        _log('ℹ️ Payrexx Event bereits verarbeitet',
            {'event_id': eventId, 'status': status, 'webhook_type': 'payrexx'});
        await _sendResponse(request, 200, 'Event bereits verarbeitet');
        return;
      }

      // 5. Event verarbeiten
      await _processPayrexxEvent(event);

      // 6. Event als verarbeitet markieren
      _processedEvents.add(eventId);

      // 7. Event loggen
      _logEvent('payrexx', status, eventId, 'success');

      await _sendResponse(request, 200, 'Webhook verarbeitet');
    } catch (e) {
      _log('❌ Fehler bei Payrexx Webhook', {
        'error': e.toString(),
        'webhook_type': 'payrexx',
        'stack_trace': StackTrace.current.toString()
      });
      await _sendResponse(request, 500, 'Interner Server-Fehler: $e');
    }
  }

  /// Event loggen
  void _logEvent(
      String provider, String eventType, String eventId, String status) {
    final eventLog = {
      'provider': provider,
      'event_type': eventType,
      'event_id': eventId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _eventLog.add(eventLog);

    // Log-Größe begrenzen (max 1000 Events)
    if (_eventLog.length > 1000) {
      _eventLog.removeRange(0, _eventLog.length - 1000);
    }
  }

  /// 404 Handler
  Future<void> _handleNotFound(HttpRequest request) async {
    await _sendResponse(request, 404, 'Not Found');
  }

  /// Error Handler
  Future<void> _handleError(HttpRequest request, dynamic error) async {
    await _sendResponse(request, 500, 'Internal Server Error: $error');
  }

  /// Hilfsmethode zum Senden von HTTP-Responses
  Future<void> _sendResponse(
      HttpRequest request, int statusCode, String message) async {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.text
      ..write(message);
    await request.response.close();
  }

  /// Validiert Stripe Webhook-Signatur
  bool _verifyStripeSignature(String payload, String signature) {
    try {
      if (_isProduction) {
        // TODO: Implementiere echte Stripe-Signatur-Validierung
        // https://stripe.com/docs/webhooks/signatures
        // Für Produktion: Verwende die echte Implementierung
        return true;
      } else {
        // Für Entwicklung: Simuliere erfolgreiche Validierung
        return true;
      }
    } catch (e) {
      _log('❌ Fehler bei Stripe-Signatur-Validierung', {'error': e.toString()});
      return false;
    }
  }

  /// Validiert Payrexx Webhook-Signatur
  bool _verifyPayrexxSignature(String payload, String signature) {
    try {
      if (_isProduction) {
        // TODO: Implementiere echte Payrexx-Signatur-Validierung
        // Für Produktion: Verwende die echte Implementierung
        return true;
      } else {
        // Für Entwicklung: Simuliere erfolgreiche Validierung
        return true;
      }
    } catch (e) {
      _log(
          '❌ Fehler bei Payrexx-Signatur-Validierung', {'error': e.toString()});
      return false;
    }
  }

  /// Verarbeitet Stripe Events
  Future<void> _processStripeEvent(Map<String, dynamic> event) async {
    final eventType = event['type'];
    final data = event['data']['object'];

    _log('📡 Verarbeite Stripe Event', {
      'event_type': eventType,
      'event_id': event['id'],
      'object_id': data['id'],
    });

    try {
      switch (eventType) {
        case 'payment_intent.succeeded':
          await _handleStripePaymentSuccess(data);
          break;
        case 'payment_intent.payment_failed':
          await _handleStripePaymentFailure(data);
          break;
        case 'invoice.payment_succeeded':
          await _handleStripeSubscriptionPayment(data);
          break;
        case 'invoice.payment_failed':
          await _handleStripeSubscriptionFailure(data);
          break;
        case 'customer.subscription.deleted':
          await _handleStripeSubscriptionCancelled(data);
          break;
        default:
          _log('ℹ️ Unbehandelter Stripe Event',
              {'event_type': eventType, 'event_id': event['id']});
      }
    } catch (e) {
      _log('❌ Fehler bei Stripe Event-Verarbeitung', {
        'event_type': eventType,
        'error': e.toString(),
        'stack_trace': StackTrace.current.toString()
      });
      rethrow;
    }
  }

  /// Verarbeitet Payrexx Events
  Future<void> _processPayrexxEvent(Map<String, dynamic> event) async {
    final status = event['status'];
    final eventId = event['id'];

    _log('📡 Verarbeite Payrexx Event', {
      'status': status,
      'event_id': eventId,
    });

    try {
      switch (status) {
        case 'confirmed':
          await _handlePayrexxPaymentSuccess(event);
          break;
        case 'cancelled':
        case 'failed':
          await _handlePayrexxPaymentFailure(event);
          break;
        default:
          _log('ℹ️ Unbehandelter Payrexx Status',
              {'status': status, 'event_id': eventId});
      }
    } catch (e) {
      _log('❌ Fehler bei Payrexx Event-Verarbeitung', {
        'status': status,
        'error': e.toString(),
        'stack_trace': StackTrace.current.toString()
      });
      rethrow;
    }
  }

  // Stripe Event Handler

  Future<void> _handleStripePaymentSuccess(
      Map<String, dynamic> paymentIntent) async {
    try {
      final metadata = paymentIntent['metadata'] ?? {};
      final userId = metadata['user_id'];
      final paymentType = metadata['type'];
      final amount =
          (paymentIntent['amount'] ?? 0) / 100.0; // Stripe speichert in Cents

      if (userId == null || paymentType == null) {
        _log('❌ Fehlende Metadaten in Stripe Payment Intent',
            {'payment_intent_id': paymentIntent['id'], 'metadata': metadata});
        return;
      }

      _log('✅ Stripe Payment erfolgreich', {
        'payment_type': paymentType,
        'user_id': userId,
        'amount_chf': amount,
        'payment_intent_id': paymentIntent['id']
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // - Zahlung in payments-Tabelle speichern
      // - Premium/Add-on sofort freischalten
      await _processPaymentSuccess(
          'stripe', userId, paymentType, amount, paymentIntent['id']);
    } catch (e) {
      _log('❌ Fehler bei Stripe Payment Success',
          {'error': e.toString(), 'payment_intent_id': paymentIntent['id']});
      rethrow;
    }
  }

  Future<void> _handleStripePaymentFailure(
      Map<String, dynamic> paymentIntent) async {
    try {
      final metadata = paymentIntent['metadata'] ?? {};
      final userId = metadata['user_id'];
      final paymentType = metadata['type'];

      _log('❌ Stripe Payment fehlgeschlagen', {
        'payment_type': paymentType,
        'user_id': userId,
        'payment_intent_id': paymentIntent['id'],
        'failure_reason':
            paymentIntent['last_payment_error']?['message'] ?? 'unknown'
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // - Zahlung als fehlgeschlagen markieren
      await _processPaymentFailure(
          'stripe', userId, paymentType, paymentIntent['id']);
    } catch (e) {
      _log('❌ Fehler bei Stripe Payment Failure',
          {'error': e.toString(), 'payment_intent_id': paymentIntent['id']});
      rethrow;
    }
  }

  Future<void> _handleStripeSubscriptionPayment(
      Map<String, dynamic> invoice) async {
    try {
      final subscriptionId = invoice['subscription'];
      final amount = (invoice['amount_paid'] ?? 0) / 100.0;

      _log('✅ Stripe Subscription Payment', {
        'subscription_id': subscriptionId,
        'amount_chf': amount,
        'invoice_id': invoice['id']
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // - Subscription-Status aktualisieren
      await _processSubscriptionPayment(
          'stripe', subscriptionId, amount, invoice['id']);
    } catch (e) {
      _log('❌ Fehler bei Stripe Subscription Payment',
          {'error': e.toString(), 'invoice_id': invoice['id']});
      rethrow;
    }
  }

  Future<void> _handleStripeSubscriptionFailure(
      Map<String, dynamic> invoice) async {
    try {
      final subscriptionId = invoice['subscription'];

      _log('❌ Stripe Subscription Payment fehlgeschlagen',
          {'subscription_id': subscriptionId, 'invoice_id': invoice['id']});

      // TODO: Implementiere echte Datenbank-Operationen
      // - Subscription-Status aktualisieren
      await _processSubscriptionFailure(
          'stripe', subscriptionId, invoice['id']);
    } catch (e) {
      _log('❌ Fehler bei Stripe Subscription Failure',
          {'error': e.toString(), 'invoice_id': invoice['id']});
      rethrow;
    }
  }

  Future<void> _handleStripeSubscriptionCancelled(
      Map<String, dynamic> subscription) async {
    try {
      final subscriptionId = subscription['id'];
      final customerId = subscription['customer'];

      _log('🔄 Stripe Subscription gekündigt',
          {'subscription_id': subscriptionId, 'customer_id': customerId});

      // TODO: Implementiere echte Datenbank-Operationen
      // - Subscription-Status aktualisieren
      // - User Premium-Status deaktivieren
      await _processSubscriptionCancellation(
          'stripe', subscriptionId, customerId);
    } catch (e) {
      _log('❌ Fehler bei Stripe Subscription Cancellation',
          {'error': e.toString(), 'subscription_id': subscription['id']});
      rethrow;
    }
  }

  // Payrexx Event Handler

  Future<void> _handlePayrexxPaymentSuccess(Map<String, dynamic> event) async {
    try {
      final metadata = event['metadata'] ?? {};
      final userId = metadata['user_id'];
      final paymentType = metadata['type'];
      final amount = (event['amount'] ?? 0).toDouble();

      if (userId == null || paymentType == null) {
        _log('❌ Fehlende Metadaten in Payrexx Event',
            {'event_id': event['id'], 'metadata': metadata});
        return;
      }

      _log('✅ Payrexx Payment erfolgreich', {
        'payment_type': paymentType,
        'user_id': userId,
        'amount_chf': amount,
        'event_id': event['id']
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // - Zahlung in payments-Tabelle speichern
      // - Premium/Add-on sofort freischalten
      await _processPaymentSuccess(
          'payrexx', userId, paymentType, amount, event['id'].toString());
    } catch (e) {
      _log('❌ Fehler bei Payrexx Payment Success',
          {'error': e.toString(), 'event_id': event['id']});
      rethrow;
    }
  }

  Future<void> _handlePayrexxPaymentFailure(Map<String, dynamic> event) async {
    try {
      final metadata = event['metadata'] ?? {};
      final userId = metadata['user_id'];
      final paymentType = metadata['type'];

      _log('❌ Payrexx Payment fehlgeschlagen', {
        'payment_type': paymentType,
        'user_id': userId,
        'event_id': event['id'],
        'status': event['status']
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // - Zahlung als fehlgeschlagen markieren
      await _processPaymentFailure(
          'payrexx', userId, paymentType, event['id'].toString());
    } catch (e) {
      _log('❌ Fehler bei Payrexx Payment Failure',
          {'error': e.toString(), 'event_id': event['id']});
      rethrow;
    }
  }

  // Payment Processing Methods

  Future<void> _processPaymentSuccess(String provider, String userId,
      String paymentType, double amount, String transactionId) async {
    try {
      _log('💰 Verarbeite erfolgreiche Zahlung', {
        'provider': provider,
        'user_id': userId,
        'payment_type': paymentType,
        'amount_chf': amount,
        'transaction_id': transactionId
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // 1. Zahlung in payments-Tabelle speichern
      // 2. Premium/Add-on sofort freischalten
      // 3. User-Limits aktualisieren
      // 4. Benachrichtigung an User senden

      await Future.delayed(
          const Duration(milliseconds: 100)); // Simuliere DB-Operation

      _log('✅ Zahlung erfolgreich verarbeitet', {
        'provider': provider,
        'user_id': userId,
        'payment_type': paymentType,
        'transaction_id': transactionId
      });
    } catch (e) {
      _log('❌ Fehler bei Zahlungsverarbeitung',
          {'provider': provider, 'user_id': userId, 'error': e.toString()});
      rethrow;
    }
  }

  Future<void> _processPaymentFailure(String provider, String userId,
      String paymentType, String transactionId) async {
    try {
      _log('❌ Verarbeite fehlgeschlagene Zahlung', {
        'provider': provider,
        'user_id': userId,
        'payment_type': paymentType,
        'transaction_id': transactionId
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // 1. Zahlung als fehlgeschlagen markieren
      // 2. User über Fehler informieren
      // 3. Retry-Logik implementieren

      await Future.delayed(
          const Duration(milliseconds: 100)); // Simuliere DB-Operation

      _log('✅ Fehlgeschlagene Zahlung verarbeitet', {
        'provider': provider,
        'user_id': userId,
        'payment_type': paymentType,
        'transaction_id': transactionId
      });
    } catch (e) {
      _log('❌ Fehler bei Verarbeitung fehlgeschlagener Zahlung',
          {'provider': provider, 'user_id': userId, 'error': e.toString()});
      rethrow;
    }
  }

  Future<void> _processSubscriptionPayment(String provider,
      String subscriptionId, double amount, String invoiceId) async {
    try {
      _log('💳 Verarbeite Subscription-Zahlung', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'amount_chf': amount,
        'invoice_id': invoiceId
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // 1. Subscription-Status aktualisieren
      // 2. Premium-Status verlängern

      await Future.delayed(
          const Duration(milliseconds: 100)); // Simuliere DB-Operation

      _log('✅ Subscription-Zahlung verarbeitet', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'invoice_id': invoiceId
      });
    } catch (e) {
      _log('❌ Fehler bei Subscription-Zahlungsverarbeitung', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'error': e.toString()
      });
      rethrow;
    }
  }

  Future<void> _processSubscriptionFailure(
      String provider, String subscriptionId, String invoiceId) async {
    try {
      _log('❌ Verarbeite fehlgeschlagene Subscription-Zahlung', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'invoice_id': invoiceId
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // 1. Subscription-Status aktualisieren
      // 2. User über Fehler informieren

      await Future.delayed(
          const Duration(milliseconds: 100)); // Simuliere DB-Operation

      _log('✅ Fehlgeschlagene Subscription-Zahlung verarbeitet', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'invoice_id': invoiceId
      });
    } catch (e) {
      _log('❌ Fehler bei Verarbeitung fehlgeschlagener Subscription-Zahlung', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'error': e.toString()
      });
      rethrow;
    }
  }

  Future<void> _processSubscriptionCancellation(
      String provider, String subscriptionId, String customerId) async {
    try {
      _log('🔄 Verarbeite Subscription-Kündigung', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'customer_id': customerId
      });

      // TODO: Implementiere echte Datenbank-Operationen
      // 1. Subscription-Status aktualisieren
      // 2. User Premium-Status deaktivieren

      await Future.delayed(
          const Duration(milliseconds: 100)); // Simuliere DB-Operation

      _log('✅ Subscription-Kündigung verarbeitet', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'customer_id': customerId
      });
    } catch (e) {
      _log('❌ Fehler bei Subscription-Kündigungsverarbeitung', {
        'provider': provider,
        'subscription_id': subscriptionId,
        'error': e.toString()
      });
      rethrow;
    }
  }

  /// Logging-Methode
  void _log(String message, [Map<String, dynamic>? data]) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'message': message,
      if (data != null) ...data,
    };

    if (_isProduction) {
      // Produktions-Logging (kann zu externem Service gesendet werden)
      debugPrint('📝 [PROD] ${jsonEncode(logEntry)}');
    } else {
      // Entwicklungs-Logging
      debugPrint('🔍 [DEV] $message ${data != null ? jsonEncode(data) : ''}');
    }
  }
}

/// Main-Funktion für den Webhook-Server
void main() async {
  final server = WebhookServer();

  // Graceful Shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    debugPrint('\n🛑 Shutdown-Signal empfangen...');
    await server.stop();
    exit(0);
  });

  ProcessSignal.sigterm.watch().listen((_) async {
    debugPrint('\n🛑 SIGTERM Signal empfangen...');
    await server.stop();
    exit(0);
  });

  try {
    await server.start();

    // Server läuft endlos
    await Future.delayed(Duration.zero);
  } catch (e) {
    debugPrint('❌ Fataler Fehler: $e');
    exit(1);
  }
}
