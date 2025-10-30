# 🚀 Deployment Instructions - Swap&Shop Go-Live

## 📋 **Pre-Deployment Checklist**

### **1. Supabase Setup**
```sql
-- In Supabase Dashboard → SQL Editor ausführen:

-- 1. Payment Schema
-- Kopiere und führe supabase_schema_payments.sql aus

-- 2. Stores Schema  
-- Kopiere und führe supabase_schema_stores.sql aus

-- 3. Verifiziere Tabellen
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_monthly_limits', 'payments', 'stores');
```

### **2. Payment Provider Setup**

#### **Stripe Account**
1. **Account erstellen:** https://dashboard.stripe.com
2. **Live Keys generieren:**
   ```bash
   # Publishable Key
   pk_live_...
   
   # Secret Key  
   sk_live_...
   ```
3. **Webhook konfigurieren:**
   ```
   URL: https://swapshop.ch/api/stripe-webhook
   Events: payment_intent.succeeded, payment_intent.payment_failed
   ```

#### **Payrexx Account**
1. **Account erstellen:** https://payrexx.com
2. **API Key generieren:**
   ```bash
   # Live API Key
   live_api_key_...
   ```
3. **Twint aktivieren** in Payrexx Dashboard
4. **Webhook konfigurieren:**
   ```
   URL: https://swapshop.ch/api/payrexx-webhook
   Events: payment.completed, payment.failed
   ```

### **3. App Configuration Update**

#### **Payment Config (lib/config/payment_config.dart)**
```dart
class PaymentConfig {
  // Live Keys (nicht Test Keys)
  static const String stripePublishableKey = 'pk_live_...';
  static const String stripeSecretKey = 'sk_live_...';
  static const String payrexxApiKey = 'live_api_key_...';
  
  // Production URLs
  static const String appUrl = 'https://swapshop.ch';
  static const bool isTestMode = false;
}
```

#### **Supabase Config (lib/config/supabase_config.dart)**
```dart
class SupabaseConfig {
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';
  
  // Table Names
  static const String profilesTable = 'profiles';
  static const String listingsTable = 'listings';
  static const String storesTable = 'stores';
  static const String userMonthlyLimitsTable = 'user_monthly_limits';
  static const String paymentsTable = 'payments';
}
```

### **4. Backend Webhook Endpoints**

#### **Stripe Webhook (Node.js/Express)**
```javascript
// /api/stripe-webhook
app.post('/api/stripe-webhook', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  
  if (event.type === 'payment_intent.succeeded') {
    const paymentIntent = event.data.object;
    // Update user limits/premium status in Supabase
    await updateUserPaymentStatus(paymentIntent.metadata.userId, paymentIntent.metadata.type);
  }
  
  res.json({received: true});
});
```

#### **Payrexx Webhook (Node.js/Express)**
```javascript
// /api/payrexx-webhook
app.post('/api/payrexx-webhook', async (req, res) => {
  const { transaction_id, status, metadata } = req.body;
  
  if (status === 'completed') {
    // Update user limits/premium status in Supabase
    await updateUserPaymentStatus(metadata.userId, metadata.type);
  }
  
  res.json({success: true});
});
```

---

## 🔧 **Deployment Steps**

### **Step 1: Supabase Schema Deployen**
1. Öffne Supabase Dashboard
2. Gehe zu SQL Editor
3. Führe `supabase_schema_payments.sql` aus
4. Führe `supabase_schema_stores.sql` aus
5. Verifiziere Tabellen in Database → Tables

### **Step 2: Payment Provider Konfigurieren**
1. **Stripe:**
   - Live Keys in `payment_config.dart` einsetzen
   - Webhook URL konfigurieren
   - Apple Pay Domain verifizieren

2. **Payrexx:**
   - Live API Key in `payment_config.dart` einsetzen
   - Twint Integration aktivieren
   - Webhook URL konfigurieren

### **Step 3: App Build & Deploy**
```bash
# 1. Clean Build
flutter clean
flutter pub get

# 2. iOS Build
flutter build ios --release

# 3. Android Build  
flutter build appbundle --release

# 4. Deploy to App Store/Play Store
# (über Xcode/Android Studio)
```

### **Step 4: Backend Deployen**
1. **Webhook Endpoints** auf Server deployen
2. **Environment Variables** setzen
3. **SSL Certificates** für HTTPS
4. **Domain** konfigurieren (swapshop.ch)

---

## 🧪 **Testing Checklist**

### **Payment Flow Tests**
- [ ] Stripe Kreditkarte (Live)
- [ ] Stripe Apple Pay (Live)
- [ ] Payrexx Twint (Live)
- [ ] Premium Upgrade Flow
- [ ] Add-on Purchase Flow
- [ ] Limit Dialog Tests

### **Store Flow Tests**
- [ ] Store erstellen → sofort in "Meine Stores" sichtbar
- [ ] Store bearbeiten
- [ ] Store löschen
- [ ] Store Discovery mit Filtern

### **App Functionality Tests**
- [ ] Login/Logout
- [ ] Profile Bearbeitung
- [ ] Listing erstellen (mit Limits)
- [ ] Swipe-Funktion
- [ ] Chat-Navigation
- [ ] Settings

---

## 📊 **Monitoring Setup**

### **Payment Analytics**
- **Stripe Dashboard:** Revenue, Conversion Rates
- **Payrexx Dashboard:** Transaction Success Rates
- **Supabase:** User Payment History

### **App Analytics**
- **Firebase Analytics:** User Engagement
- **Crashlytics:** Error Monitoring
- **Performance Monitoring:** App Performance

### **Alerts**
- **Payment Failures:** Email/Slack Alerts
- **High Error Rates:** Crashlytics Alerts
- **Server Issues:** Uptime Monitoring

---

## 🚨 **Rollback Plan**

### **Emergency Rollback**
1. **Payment Provider:** Test Mode aktivieren
2. **App:** Previous Version deployen
3. **Database:** Backup wiederherstellen
4. **Communication:** Users informieren

### **Gradual Rollback**
1. **Feature Flags:** Payment Features deaktivieren
2. **A/B Testing:** Neue Features nur für Test-Users
3. **Monitoring:** Intensive Überwachung

---

## ✅ **Go-Live Checklist**

### **Pre-Launch (24h vorher)**
- [ ] Alle Payment Provider Accounts aktiviert
- [ ] Live API Keys konfiguriert
- [ ] Webhook Endpoints funktionieren
- [ ] Supabase Schema deployed
- [ ] Test Payments erfolgreich
- [ ] Team informiert

### **Launch Day**
- [ ] Payment Flow live geschaltet
- [ ] Monitoring aktiviert
- [ ] Support Team bereit
- [ ] Backup Payment Methods verfügbar
- [ ] Social Media Posts geplant

### **Post-Launch (1. Woche)**
- [ ] Payment Analytics überwachen
- [ ] User Feedback sammeln
- [ ] Performance optimieren
- [ ] Support Tickets bearbeiten
- [ ] Bug Fixes deployen

---

## 📞 **Support Contacts**

### **Technical Support**
- **Payment Issues:** Stripe/Payrexx Support
- **App Issues:** Development Team
- **Server Issues:** Hosting Provider

### **User Support**
- **Email:** support@swapshop.ch
- **Phone:** +41 XX XXX XX XX
- **Hours:** Mo-Fr 9:00-18:00 CET

**Die App ist bereit für Go-Live! 🚀** 