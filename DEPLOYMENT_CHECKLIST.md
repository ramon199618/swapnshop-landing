# 🚀 Deployment Checklist - Zahlungsintegration

## ✅ **Implementiert (Bereit für Test)**

### **Datenmodell**
- [x] Supabase Schema (`supabase_schema_payments.sql`)
- [x] `user_monthly_limits` Tabelle
- [x] `payments` Tabelle
- [x] RLS Policies
- [x] Automatische Reset-Funktion

### **Payment Service**
- [x] Stripe Integration (Test Mode)
- [x] Payrexx Integration (Test Mode)
- [x] Payment Flow mit Provider-Auswahl
- [x] Error Handling

### **UI Integration**
- [x] Premium Upgrade Screen
- [x] Limit Dialog
- [x] Profile Screen mit Limits
- [x] Spendenhinweis bei Add-ons

---

## 🔧 **Nächste Schritte für Live-Deployment**

### **1. Payment Provider Accounts**

#### **Stripe Setup**
- [ ] Stripe Account erstellen (https://dashboard.stripe.com)
- [ ] Live API Keys generieren
- [ ] Webhook Endpoint konfigurieren
- [ ] Apple Pay Domain verifizieren
- [ ] Test mit echten Testkarten

#### **Payrexx Setup**
- [ ] Payrexx Account erstellen (https://payrexx.com)
- [ ] Live API Key generieren
- [ ] Twint Integration aktivieren
- [ ] Webhook URL konfigurieren
- [ ] Test mit Twint Test-Modus

### **2. Supabase Production Setup**

#### **Database Schema**
```sql
-- In Supabase Dashboard ausführen:
-- 1. SQL Editor öffnen
-- 2. supabase_schema_payments.sql ausführen
-- 3. RLS Policies prüfen
-- 4. Test-Daten einfügen
```

#### **Environment Variables**
```bash
# In Supabase Dashboard → Settings → Environment Variables
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
PAYREXX_API_KEY=live_api_key_...
```

### **3. App Configuration**

#### **Payment Config Update**
```dart
// lib/config/payment_config.dart
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

#### **Webhook Endpoints**
```bash
# Stripe Webhook URL
https://swapshop.ch/api/stripe-webhook

# Payrexx Webhook URL  
https://swapshop.ch/api/payrexx-webhook
```

### **4. Testing Checklist**

#### **Payment Flow Tests**
- [ ] Stripe Kreditkarte (Test)
- [ ] Stripe Apple Pay (Test)
- [ ] Payrexx Twint (Test)
- [ ] Premium Upgrade Flow
- [ ] Add-on Purchase Flow
- [ ] Limit Dialog Tests

#### **Database Tests**
- [ ] Monatlicher Reset
- [ ] Limit Tracking
- [ ] Payment Recording
- [ ] Premium Status Update

#### **UI Tests**
- [ ] Profile Screen Limits
- [ ] Premium Upgrade Screen
- [ ] Limit Dialog
- [ ] Payment Provider Selection

### **5. Security & Compliance**

#### **PCI Compliance**
- [ ] Stripe ist PCI Level 1 compliant
- [ ] Keine Kreditkartendaten in App speichern
- [ ] HTTPS für alle Payment URLs

#### **GDPR Compliance**
- [ ] Payment Data Privacy Policy
- [ ] User Consent für Payment Processing
- [ ] Data Retention Policy

### **6. Monitoring & Analytics**

#### **Payment Analytics**
- [ ] Stripe Dashboard Monitoring
- [ ] Payrexx Dashboard Monitoring
- [ ] Failed Payment Tracking
- [ ] Revenue Analytics

#### **Error Monitoring**
- [ ] Payment Error Logging
- [ ] User Support System
- [ ] Refund Process

---

## 🎯 **Go-Live Checklist**

### **Pre-Launch**
- [ ] Alle Payment Provider Accounts aktiviert
- [ ] Live API Keys konfiguriert
- [ ] Webhook Endpoints funktionieren
- [ ] Supabase Schema deployed
- [ ] Test Payments erfolgreich

### **Launch Day**
- [ ] Payment Flow live geschaltet
- [ ] Monitoring aktiviert
- [ ] Support Team informiert
- [ ] Backup Payment Methods verfügbar

### **Post-Launch**
- [ ] Payment Analytics überwachen
- [ ] User Feedback sammeln
- [ ] Performance optimieren
- [ ] Support Tickets bearbeiten

---

## 📞 **Support & Kontakte**

### **Payment Provider Support**
- **Stripe**: https://support.stripe.com
- **Payrexx**: https://payrexx.com/support

### **Supabase Support**
- **Documentation**: https://supabase.com/docs
- **Community**: https://github.com/supabase/supabase

### **App Support**
- **User Support**: support@swapshop.ch
- **Technical Issues**: dev@swapshop.ch 