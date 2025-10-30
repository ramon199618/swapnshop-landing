class PaymentConfig {
  // TODO(Ramon): Insert LIVE_xxx here
  // Für Produktion: --dart-define=APP_ENV=prod

  // Domain-Konfiguration
  static const String baseUrl = String.fromEnvironment(
    'PAYMENT_BASE_URL',
    defaultValue: 'https://swapnshop.app',
  );

  static const String apiUrl = String.fromEnvironment(
    'PAYMENT_API_URL',
    defaultValue: 'https://api.swapnshop.app',
  );

  // Stripe-Konfiguration
  static const String currentPremiumMonthlyPriceId = String.fromEnvironment(
    'STRIPE_PREMIUM_MONTHLY_PRICE_ID',
    defaultValue: 'price_monthly_placeholder',
  );

  static const String currentPremiumYearlyPriceId = String.fromEnvironment(
    'STRIPE_PREMIUM_YEARLY_PRICE_ID',
    defaultValue: 'price_yearly_placeholder',
  );

  // Payrexx-Konfiguration
  static const String payrexxApiKey = String.fromEnvironment(
    'PAYREXX_API_KEY',
    defaultValue: 'payrexx_live_key_here',
  );

  // Webhook-Endpunkte
  static const String stripeWebhookSecret = String.fromEnvironment(
    'STRIPE_WEBHOOK_SECRET',
    defaultValue: 'whsec_live_webhook_secret_here',
  );

  static const String payrexxWebhookSecret = String.fromEnvironment(
    'PAYREXX_WEBHOOK_SECRET',
    defaultValue: 'payrexx_live_webhook_secret_here',
  );

  // Environment-Switch
  static bool get isProduction =>
      const String.fromEnvironment('APP_ENV') == 'prod';

  // Build-Anweisungen
  static const String buildInstructions = '''
    Für Produktion:
    1. --dart-define=APP_ENV=prod
    2. --dart-define=PAYMENT_BASE_URL=https://swapnshop.app
    3. --dart-define=PAYMENT_API_URL=https://api.swapnshop.app
    4. --dart-define=STRIPE_PREMIUM_MONTHLY_PRICE_ID=price_xxx
    5. --dart-define=STRIPE_PREMIUM_YEARLY_PRICE_ID=price_xxx
    6. --dart-define=STRIPE_WEBHOOK_SECRET=whsec_xxx
    7. --dart-define=PAYREXX_WEBHOOK_SECRET=xxx
  ''';

  // Webhook-Endpunkte für Supabase Edge Functions
  static const String webhookEndpoints = '''
    Supabase Edge Functions:
    - /functions/v1/stripe-webhook
    - /functions/v1/payrexx-webhook
    
    Oder eigene Server:
    - https://api.swapnshop.app/webhooks/stripe
    - https://api.swapnshop.app/webhooks/payrexx
  ''';
}
