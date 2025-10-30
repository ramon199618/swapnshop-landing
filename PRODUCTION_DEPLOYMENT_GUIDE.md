# 🚀 Swap&Shop - Production Deployment Guide

## 📋 Übersicht

Dieser Guide führt Sie durch den kompletten Produktions-Deployment der Swap&Shop-App, einschließlich:
- Payment-Integration (Stripe + Payrexx)
- Webhook-Server
- Supabase-Produktionsumgebung
- App Store Deployment
- Monitoring & Sicherheit

---

## 🎯 Phase 1: Kritische Infrastruktur

### **1.1 Payment Provider Setup**

#### **Stripe Live Account**
```bash
# 1. Stripe Dashboard öffnen: https://dashboard.stripe.com
# 2. Live Mode aktivieren
# 3. API Keys generieren:
#    - Publishable Key (pk_live_...)
#    - Secret Key (sk_live_...)
#    - Webhook Secret (whsec_...)

# 4. Products & Prices erstellen:
#    - Premium Monthly: CHF 5.00
#    - Premium Yearly: CHF 54.00
#    - Add-on Swaps (5): CHF 1.00
#    - Add-on Sells (5): CHF 1.00

# 5. Webhook Endpoint konfigurieren:
#    URL: https://swapshop.ch/webhook/stripe
#    Events: payment_intent.succeeded, invoice.payment_succeeded, etc.
```

#### **Payrexx Live Account**
```bash
# 1. Payrexx Dashboard öffnen: https://payrexx.com
# 2. Live Mode aktivieren
# 3. API Key generieren
# 4. Twint Integration aktivieren
# 5. Webhook URL konfigurieren:
#    URL: https://swapshop.ch/webhook/payrexx
```

### **1.2 Supabase Production Setup**

#### **Database Schema Deployen**
```sql
-- 1. Supabase Dashboard öffnen
-- 2. SQL Editor öffnen
-- 3. supabase_schema.sql ausführen
-- 4. RLS Policies prüfen
-- 5. Test-Daten einfügen

-- Wichtige Tabellen:
-- - profiles (mit is_premium, premium_expires_at)
-- - usage_quota (monatliche Limits)
-- - payments (Zahlungsverlauf)
-- - stores (Store Management)
-- - store_ads (Banner-Werbung)
```

#### **Environment Variables**
```bash
# In Supabase Dashboard → Settings → Environment Variables
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
PAYREXX_API_KEY=payrexx_live_key
STRIPE_WEBHOOK_SECRET=whsec_live_...
PAYREXX_WEBHOOK_SECRET=payrexx_live_...
```

### **1.3 Webhook Server Deployment**

#### **Server vorbereiten**
```bash
# 1. Server mit Docker ausstatten
# 2. Domain swapshop.ch konfigurieren
# 3. SSL Certificate installieren
# 4. Firewall-Regeln setzen

# Ports öffnen:
# - 80 (HTTP → HTTPS Redirect)
# - 443 (HTTPS)
# - 8080 (Webhook Server)
```

#### **Webhook Server deployen**
```bash
# 1. Code auf Server kopieren
cd /opt/swapshop/webhook-server

# 2. Environment konfigurieren
cp env.production.example .env.production
# .env.production bearbeiten mit echten Werten

# 3. Server deployen
./deploy.sh production

# 4. Status prüfen
curl https://swapshop.ch:8080/health
curl https://swapshop.ch:8080/status
```

#### **SSL/HTTPS konfigurieren**
```bash
# 1. Let's Encrypt Certificate
sudo certbot --nginx -d swapshop.ch -d www.swapshop.ch

# 2. Nginx Reverse Proxy konfigurieren
# /etc/nginx/sites-available/swapshop
server {
    listen 443 ssl;
    server_name swapshop.ch;
    
    ssl_certificate /etc/letsencrypt/live/swapshop.ch/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/swapshop.ch/privkey.pem;
    
    location /webhook/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 🎯 Phase 2: App Store Deployment

### **2.1 iOS App Store**

#### **Code Signing & Provisioning**
```bash
# 1. Apple Developer Account
# 2. App ID erstellen: com.swapshop.app
# 3. Provisioning Profile generieren
# 4. Distribution Certificate installieren

# 5. Xcode konfigurieren:
#    - Bundle Identifier: com.swapshop.app
#    - Team: Ihr Apple Developer Team
#    - Signing: Automatic
```

#### **App Store Connect**
```bash
# 1. App Store Connect öffnen
# 2. Neue App erstellen
# 3. Metadaten eintragen (siehe app_store_metadata.md)
# 4. Screenshots hochladen
# 5. App Review beantragen
```

#### **Build & Upload**
```bash
# 1. Release Build
flutter build ios --release

# 2. Archive in Xcode
# 3. Upload to App Store Connect
# 4. TestFlight für Beta-Testing
```

### **2.2 Google Play Store**

#### **Google Play Console**
```bash
# 1. Google Play Console öffnen
# 2. Neue App erstellen
# 3. Package Name: com.swapshop.app
# 4. Metadaten eintragen
# 5. APK/AAB hochladen
```

#### **Build & Upload**
```bash
# 1. Release Build
flutter build appbundle --release

# 2. Google Play Console
# 3. Production Track
# 4. Rollout starten
```

---

## 🎯 Phase 3: Monitoring & Sicherheit

### **3.1 Application Monitoring**

#### **Error Tracking**
```bash
# 1. Sentry.io Setup
# 2. DSN in App konfigurieren
# 3. Error Alerts einrichten
# 4. Performance Monitoring
```

#### **Logging & Analytics**
```bash
# 1. Centralized Logging (ELK Stack)
# 2. Application Metrics
# 3. User Analytics
# 4. Business KPIs
```

### **3.2 Security Measures**

#### **API Security**
```bash
# 1. Rate Limiting
# 2. API Key Rotation
# 3. Request Validation
# 4. CORS Configuration
```

#### **Data Protection**
```bash
# 1. GDPR Compliance
# 2. Data Encryption
# 3. Backup Strategy
# 4. Disaster Recovery
```

---

## 🎯 Phase 4: Go-Live Checklist

### **4.1 Pre-Launch (24h vorher)**

- [ ] Alle Payment Provider aktiviert
- [ ] Live API Keys konfiguriert
- [ ] Webhook Endpoints funktionieren
- [ ] Supabase Schema deployed
- [ ] Test Payments erfolgreich
- [ ] SSL Certificates aktiv
- [ ] Monitoring aktiviert
- [ ] Support Team informiert
- [ ] Backup System getestet

### **4.2 Launch Day**

- [ ] Payment Flow live geschaltet
- [ ] App Store Release aktiviert
- [ ] Google Play Release aktiviert
- [ ] Webhook Server läuft
- [ ] Real-time Monitoring
- [ ] Support Tickets überwachen
- [ ] Performance überwachen

### **4.3 Post-Launch (24h nachher)**

- [ ] Payment Analytics prüfen
- [ ] Error Rates überwachen
- [ ] User Feedback sammeln
- [ ] Performance optimieren
- [ ] Support Tickets bearbeiten
- [ ] Backup Status prüfen

---

## 🚨 Troubleshooting

### **Häufige Probleme**

#### **Webhook Server startet nicht**
```bash
# 1. Logs prüfen
docker-compose logs webhook-server

# 2. Ports prüfen
netstat -tulpn | grep 8080

# 3. Environment Variables prüfen
docker-compose exec webhook-server env | grep STRIPE
```

#### **Payment Webhooks funktionieren nicht**
```bash
# 1. Webhook URL prüfen
curl -X POST https://swapshop.ch/webhook/stripe

# 2. SSL Certificate prüfen
openssl s_client -connect swapshop.ch:443

# 3. Firewall-Regeln prüfen
sudo ufw status
```

#### **App startet nicht**
```bash
# 1. Build prüfen
flutter build ios --release
flutter build appbundle --release

# 2. Code Signing prüfen
# 3. Provisioning Profile prüfen
# 4. Bundle Identifier prüfen
```

---

## 📞 Support & Kontakte

### **Technical Support**
- **Development Team**: dev@swapshop.ch
- **DevOps**: ops@swapshop.ch
- **Emergency**: +41 XX XXX XX XX

### **Payment Provider Support**
- **Stripe**: https://support.stripe.com
- **Payrexx**: https://payrexx.com/support

### **Platform Support**
- **Apple Developer**: https://developer.apple.com/support
- **Google Play**: https://support.google.com/googleplay

---

## 📚 Nützliche Links

### **Dokumentation**
- [Supabase Docs](https://supabase.com/docs)
- [Flutter Docs](https://flutter.dev/docs)
- [Stripe Docs](https://stripe.com/docs)
- [Payrexx Docs](https://payrexx.com/docs)

### **Tools & Services**
- [Let's Encrypt](https://letsencrypt.org)
- [Sentry.io](https://sentry.io)
- [ELK Stack](https://www.elastic.co/elk-stack)

---

## 🎉 Erfolgsmetriken

### **Technical KPIs**
- **Uptime**: > 99.9%
- **Response Time**: < 200ms
- **Error Rate**: < 0.1%
- **Payment Success**: > 99%

### **Business KPIs**
- **User Growth**: 20% pro Monat
- **Payment Conversion**: 5-10%
- **User Retention**: 60%+
- **Revenue Growth**: 20%+ pro Monat

---

## 🔄 Wartung & Updates

### **Regelmäßige Tasks**
- **Täglich**: Logs prüfen, Alerts überwachen
- **Wöchentlich**: Performance Review, Backup Status
- **Monatlich**: Security Audit, Dependency Updates
- **Quartalsweise**: Full System Review, Capacity Planning

### **Update-Prozess**
1. **Staging Environment** testen
2. **Backup** erstellen
3. **Maintenance Window** planen
4. **Update** durchführen
5. **Health Check** durchführen
6. **Monitoring** aktivieren

---

**Viel Erfolg beim Go-Live! 🚀**

Bei Fragen oder Problemen wenden Sie sich an das Development Team. 