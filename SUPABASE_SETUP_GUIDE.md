# 🚀 Supabase Setup Guide für Swap&Shop

## 📋 **Übersicht**

Diese Anleitung führt Sie durch die komplette Einrichtung der Supabase-Datenbank für die Swap&Shop App.

### **Voraussetzungen:**
- ✅ Supabase-Projekt erstellt: `https://nqxgsuxyvhjveigbjyxb.supabase.co`
- ✅ JWT Token verfügbar: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- ✅ App konfiguriert mit echten Supabase-Keys

---

## 🔧 **Schritt 1: Database Schema erstellen**

### **1.1 Supabase Dashboard öffnen**
1. Gehe zu: https://supabase.com/dashboard/project/nqxgsuxyvhjveigbjyxb
2. Klicke auf **"SQL Editor"** im linken Menü
3. Klicke auf **"New Query"**

### **1.2 Schema-Script ausführen**
1. Kopiere den Inhalt von `supabase_schema_complete.sql`
2. Füge ihn in den SQL Editor ein
3. Klicke auf **"Run"** (oder Strg+Enter)

**Erwartetes Ergebnis:**
```
✅ 25 tables created
✅ 50+ indexes created  
✅ 10+ triggers created
✅ Sample categories inserted
```

### **1.3 Schema validieren**
1. Gehe zu **"Table Editor"** im linken Menü
2. Überprüfe, dass folgende Tabellen erstellt wurden:
   - `profiles`
   - `listings`
   - `likes`
   - `matches`
   - `chats`
   - `messages`
   - `communities`
   - `stores`
   - `jobs`
   - `categories`

---

## 🛡️ **Schritt 2: RLS Policies konfigurieren**

### **2.1 RLS-Script ausführen**
1. Gehe zurück zum **"SQL Editor"**
2. Kopiere den Inhalt von `supabase_rls_policies.sql`
3. Füge ihn in den SQL Editor ein
4. Klicke auf **"Run"**

**Erwartetes Ergebnis:**
```
✅ RLS enabled on all tables
✅ 50+ policies created
✅ Security rules configured
```

### **2.2 Policies validieren**
1. Gehe zu **"Authentication" > "Policies"**
2. Überprüfe, dass alle Tabellen RLS aktiviert haben
3. Überprüfe, dass Policies für alle Tabellen erstellt wurden

---

## 📁 **Schritt 3: Storage Buckets einrichten**

### **3.1 Storage-Script ausführen**
1. Gehe zurück zum **"SQL Editor"**
2. Kopiere den Inhalt von `supabase_storage_setup.sql`
3. Füge ihn in den SQL Editor ein
4. Klicke auf **"Run"**

**Erwartetes Ergebnis:**
```
✅ 6 storage buckets created
✅ Storage policies configured
✅ Helper functions created
```

### **3.2 Storage validieren**
1. Gehe zu **"Storage"** im linken Menü
2. Überprüfe, dass folgende Buckets erstellt wurden:
   - `avatars`
   - `listing-images`
   - `store-logos`
   - `store-banners`
   - `community-images`
   - `chat-images`

---

## 🔐 **Schritt 4: Authentication konfigurieren**

### **4.1 Auth-Einstellungen**
1. Gehe zu **"Authentication" > "Settings"**
2. Konfiguriere folgende Einstellungen:

**Site URL:**
```
https://nqxgsuxyvhjveigbjyxb.supabase.co
```

**Redirect URLs:**
```
https://nqxgsuxyvhjveigbjyxb.supabase.co/auth/callback
http://localhost:3000/auth/callback
```

**Email Templates:**
- ✅ **Confirm signup** aktiviert
- ✅ **Reset password** aktiviert
- ✅ **Magic link** aktiviert

### **4.2 Auth-Provider konfigurieren**
1. Gehe zu **"Authentication" > "Providers"**
2. Aktiviere **"Email"** Provider
3. Konfiguriere **"Email"** Einstellungen:
   - **Enable email confirmations**: ✅
   - **Enable email change confirmations**: ✅
   - **Enable email change**: ✅

---

## 🧪 **Schritt 5: App testen**

### **5.1 App starten**
```bash
cd /Users/ramonbieri/swapshop_clean
flutter run --debug
```

### **5.2 Grundfunktionen testen**
1. **User Registration:**
   - [ ] Neuer User registrieren
   - [ ] Email-Verifikation prüfen
   - [ ] Profil wird erstellt

2. **User Login:**
   - [ ] Mit registriertem User anmelden
   - [ ] Session wird verwaltet
   - [ ] Logout funktioniert

3. **Listing Creation:**
   - [ ] Swap-Inserat erstellen
   - [ ] Giveaway-Inserat erstellen
   - [ ] Sell-Inserat erstellen

4. **Swipe Functionality:**
   - [ ] Listings anzeigen
   - [ ] Like/Dislike funktioniert
   - [ ] Matches werden erstellt

5. **Chat System:**
   - [ ] Chat wird bei Match erstellt
   - [ ] Nachrichten senden
   - [ ] Real-time Updates

---

## 📊 **Schritt 6: Monitoring einrichten**

### **6.1 Database Monitoring**
1. Gehe zu **"Reports"** im linken Menü
2. Überprüfe **"Database"** Metriken:
   - Query Performance
   - Connection Count
   - Error Rate

### **6.2 Auth Monitoring**
1. Gehe zu **"Authentication" > "Users"**
2. Überprüfe User-Registrierungen
3. Überprüfe Login-Aktivitäten

### **6.3 Storage Monitoring**
1. Gehe zu **"Storage"**
2. Überprüfe Bucket-Usage
3. Überprüfe Upload-Aktivitäten

---

## 🚨 **Schritt 7: Troubleshooting**

### **Häufige Probleme:**

#### **Problem 1: "RLS policy violation"**
**Lösung:**
```sql
-- Prüfe RLS-Status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Aktiviere RLS falls nötig
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
```

#### **Problem 2: "Storage bucket not found"**
**Lösung:**
```sql
-- Prüfe Bucket-Status
SELECT * FROM storage.buckets;

-- Erstelle Bucket falls nötig
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true);
```

#### **Problem 3: "Authentication failed"**
**Lösung:**
1. Prüfe JWT Token in `lib/config/supabase_keys.dart`
2. Prüfe Supabase URL
3. Prüfe Auth-Einstellungen im Dashboard

#### **Problem 4: "Real-time not working"**
**Lösung:**
1. Prüfe Realtime-Einstellungen im Dashboard
2. Prüfe WebSocket-Verbindung
3. Prüfe Realtime-Policies

---

## 📋 **Schritt 8: Deployment Checklist**

### **Pre-Production:**
- [ ] Alle SQL-Scripts erfolgreich ausgeführt
- [ ] RLS-Policies konfiguriert und getestet
- [ ] Storage-Buckets erstellt und getestet
- [ ] Auth-Einstellungen konfiguriert
- [ ] App-Funktionen getestet
- [ ] Performance-Metriken überprüft
- [ ] Security-Review abgeschlossen

### **Production:**
- [ ] Backup-Strategie implementiert
- [ ] Monitoring eingerichtet
- [ ] Error-Tracking aktiviert
- [ ] Performance-Monitoring aktiviert
- [ ] Security-Monitoring aktiviert
- [ ] Rollback-Plan erstellt

---

## 📞 **Support & Hilfe**

### **Bei Problemen:**
1. **Supabase Dashboard**: https://supabase.com/dashboard/project/nqxgsuxyvhjveigbjyxb
2. **Supabase Docs**: https://supabase.com/docs
3. **Flutter Supabase**: https://pub.dev/packages/supabase_flutter

### **Logs prüfen:**
1. **App Logs**: Flutter Debug Console
2. **Database Logs**: Supabase Dashboard > Logs
3. **Auth Logs**: Authentication > Logs
4. **Storage Logs**: Storage > Logs

### **Nützliche SQL-Queries:**
```sql
-- User-Count prüfen
SELECT COUNT(*) FROM auth.users;

-- Listing-Count prüfen
SELECT COUNT(*) FROM public.listings;

-- Active Matches prüfen
SELECT COUNT(*) FROM public.matches WHERE status = 'active';

-- Storage Usage prüfen
SELECT 
  bucket_id,
  COUNT(*) as file_count,
  SUM(metadata->>'size')::bigint as total_size
FROM storage.objects 
GROUP BY bucket_id;
```

---

## 🎯 **Nächste Schritte**

Nach erfolgreichem Setup:

1. **App testen** mit echten Daten
2. **Performance optimieren** basierend auf Metriken
3. **Security review** durchführen
4. **Production deployment** vorbereiten
5. **Monitoring** einrichten
6. **Backup-Strategie** implementieren

---

**Status**: ✅ **BEREIT FÜR SETUP**  
**Letzte Aktualisierung**: $(date)  
**Version**: 1.0.0
