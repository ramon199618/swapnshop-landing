# 🧪 Supabase Integration Test Protocol

## 📋 **Test-Übersicht**

### **Ziel:**
Vollständige Integration der Swap&Shop App mit Supabase-Datenbank testen und validieren.

### **Test-Umgebung:**
- **Supabase URL**: `https://nqxgsuxyvhjveigbjyxb.supabase.co`
- **App**: Swap&Shop Flutter App
- **Datum**: $(date)

---

## 🔧 **1. Database-Schema Setup**

### **✅ Erforderliche Schritte:**
1. **SQL-Schema ausführen:**
   ```sql
   -- In Supabase Dashboard > SQL Editor ausführen:
   -- 1. supabase_schema_complete.sql
   -- 2. supabase_rls_policies.sql  
   -- 3. supabase_storage_setup.sql
   ```

2. **Tabellen validieren:**
   - [ ] `profiles` - User-Profile
   - [ ] `listings` - Swap/Giveaway/Sell Inserate
   - [ ] `likes` - User-Likes
   - [ ] `matches` - Matches zwischen Usern
   - [ ] `chats` - Chat-Räume
   - [ ] `messages` - Chat-Nachrichten
   - [ ] `communities` - Communities
   - [ ] `stores` - Stores
   - [ ] `jobs` - Job-Inserate
   - [ ] `categories` - Kategorien

3. **RLS-Policies aktivieren:**
   - [ ] Alle Tabellen haben RLS aktiviert
   - [ ] Policies für User-spezifische Daten
   - [ ] Öffentliche Daten für alle sichtbar

4. **Storage-Buckets erstellen:**
   - [ ] `avatars` - Profilbilder
   - [ ] `listing-images` - Artikelbilder
   - [ ] `store-logos` - Store-Logos
   - [ ] `store-banners` - Store-Banner
   - [ ] `community-images` - Community-Bilder
   - [ ] `chat-images` - Chat-Bilder

---

## 🧪 **2. App-Integration Tests**

### **A. Authentication Tests**
- [ ] **User Registration:**
  - [ ] Neuer User kann sich registrieren
  - [ ] Profil wird automatisch erstellt
  - [ ] Email-Verifikation funktioniert

- [ ] **User Login:**
  - [ ] Bestehender User kann sich anmelden
  - [ ] Session wird korrekt verwaltet
  - [ ] Logout funktioniert

- [ ] **Profile Management:**
  - [ ] User kann Profil bearbeiten
  - [ ] Avatar-Upload funktioniert
  - [ ] Standort wird gespeichert

### **B. Listing Tests**
- [ ] **Listing Creation:**
  - [ ] Swap-Inserat erstellen
  - [ ] Giveaway-Inserat erstellen
  - [ ] Sell-Inserat erstellen
  - [ ] Bilder hochladen
  - [ ] Kategorien zuweisen

- [ ] **Listing Discovery:**
  - [ ] Listings nach Standort filtern
  - [ ] Kategorie-Filter funktioniert
  - [ ] Suchfunktion arbeitet
  - [ ] Pagination funktioniert

- [ ] **Listing Management:**
  - [ ] User kann eigene Listings bearbeiten
  - [ ] User kann eigene Listings löschen
  - [ ] Inaktive Listings werden ausgeblendet

### **C. Swipe & Match Tests**
- [ ] **Swipe Functionality:**
  - [ ] Like-Funktion funktioniert
  - [ ] Dislike-Funktion funktioniert
  - [ ] Swipe-History wird gespeichert

- [ ] **Match System:**
  - [ ] Matches werden korrekt erstellt
  - [ ] Match-Notification funktioniert
  - [ ] Match-Status wird verwaltet

### **D. Chat Tests**
- [ ] **Chat Creation:**
  - [ ] Chat wird bei Match erstellt
  - [ ] Chat-Teilnehmer werden korrekt zugewiesen

- [ ] **Messaging:**
  - [ ] Text-Nachrichten senden
  - [ ] Bild-Nachrichten senden
  - [ ] Real-time Updates funktionieren
  - [ ] Nachrichten werden korrekt angezeigt

### **E. Community Tests**
- [ ] **Community Discovery:**
  - [ ] Communities nach Standort anzeigen
  - [ ] Community-Details laden
  - [ ] Mitglieder-Liste anzeigen

- [ ] **Community Participation:**
  - [ ] Community beitreten
  - [ ] Community verlassen
  - [ ] Posts erstellen
  - [ ] Posts liken/kommentieren

### **F. Store Tests**
- [ ] **Store Creation:**
  - [ ] Store erstellen
  - [ ] Store-Typ auswählen
  - [ ] Store-Banner hochladen

- [ ] **Store Management:**
  - [ ] Store-Listings verwalten
  - [ ] Store-Statistiken anzeigen
  - [ ] Store-Einstellungen bearbeiten

### **G. Job Tests**
- [ ] **Job Creation:**
  - [ ] Job-Inserat erstellen
  - [ ] Job-Kategorien zuweisen
  - [ ] Gehaltsspanne definieren

- [ ] **Job Applications:**
  - [ ] Auf Job bewerben
  - [ ] Bewerbungsstatus verfolgen
  - [ ] Bewerbungen verwalten

---

## 🔍 **3. Performance Tests**

### **A. Database Performance:**
- [ ] **Query Performance:**
  - [ ] Listing-Queries < 500ms
  - [ ] Chat-Queries < 200ms
  - [ ] Search-Queries < 1000ms

- [ ] **Index Performance:**
  - [ ] Geografische Indizes funktionieren
  - [ ] Text-Search-Indizes funktionieren
  - [ ] Composite-Indizes funktionieren

### **B. Real-time Performance:**
- [ ] **Real-time Updates:**
  - [ ] Chat-Updates < 100ms
  - [ ] Match-Updates < 200ms
  - [ ] Listing-Updates < 500ms

### **C. Storage Performance:**
- [ ] **Image Upload:**
  - [ ] Avatar-Upload < 2s
  - [ ] Listing-Image-Upload < 3s
  - [ ] Batch-Upload funktioniert

---

## 🛡️ **4. Security Tests**

### **A. RLS Policy Tests:**
- [ ] **User Isolation:**
  - [ ] User kann nur eigene Daten sehen
  - [ ] User kann nur eigene Daten bearbeiten
  - [ ] Cross-User-Zugriff blockiert

- [ ] **Public Data Access:**
  - [ ] Öffentliche Listings sichtbar
  - [ ] Öffentliche Communities sichtbar
  - [ ] Öffentliche Stores sichtbar

### **B. Storage Security:**
- [ ] **File Access:**
  - [ ] User kann nur eigene Dateien hochladen
  - [ ] User kann nur eigene Dateien löschen
  - [ ] Öffentliche Dateien für alle sichtbar

---

## 📊 **5. Error Handling Tests**

### **A. Network Errors:**
- [ ] **Offline Handling:**
  - [ ] App funktioniert offline
  - [ ] Daten werden synchronisiert
  - [ ] Fehler werden korrekt angezeigt

### **B. Database Errors:**
- [ ] **Connection Errors:**
  - [ ] Verbindungsfehler werden behandelt
  - [ ] Retry-Mechanismus funktioniert
  - [ ] Fallback-Modi aktiviert

### **C. Validation Errors:**
- [ ] **Input Validation:**
  - [ ] Ungültige Eingaben werden abgefangen
  - [ ] Fehlermeldungen sind verständlich
  - [ ] Formulare werden korrekt validiert

---

## 📱 **6. User Experience Tests**

### **A. Navigation:**
- [ ] **Flow Tests:**
  - [ ] Login → Home → Swipe → Match → Chat
  - [ ] Home → Search → Filter → Listing
  - [ ] Profile → Settings → Edit → Save

### **B. Responsiveness:**
- [ ] **UI Tests:**
  - [ ] Alle Screens laden korrekt
  - [ ] Buttons reagieren sofort
  - [ ] Loading-States werden angezeigt

### **C. Internationalization:**
- [ ] **Language Tests:**
  - [ ] Deutsch (Standard)
  - [ ] Englisch
  - [ ] Französisch
  - [ ] Italienisch
  - [ ] Portugiesisch

---

## 🚨 **7. Critical Issues Checklist**

### **P0 - Critical (App-Breaking):**
- [ ] User kann sich nicht registrieren/anmelden
- [ ] Listings werden nicht angezeigt
- [ ] Swipe-Funktion funktioniert nicht
- [ ] Chats funktionieren nicht
- [ ] App stürzt ab

### **P1 - Important (Feature-Breaking):**
- [ ] Bilder werden nicht hochgeladen
- [ ] Real-time Updates funktionieren nicht
- [ ] Search/Filter funktioniert nicht
- [ ] Communities funktionieren nicht
- [ ] Stores funktionieren nicht

### **P2 - Nice-to-Have (Enhancement):**
- [ ] Performance-Optimierungen
- [ ] UI/UX-Verbesserungen
- [ ] Zusätzliche Features
- [ ] Analytics-Integration

---

## 📝 **8. Test Results**

### **Test Status:**
- [ ] ✅ **PASSED** - Alle Tests erfolgreich
- [ ] ⚠️ **PARTIAL** - Einige Tests fehlgeschlagen
- [ ] ❌ **FAILED** - Kritische Tests fehlgeschlagen

### **Issues Found:**
```
# Hier Issues dokumentieren:

## Issue 1: [Titel]
- **Severity**: P0/P1/P2
- **Description**: [Beschreibung]
- **Steps to Reproduce**: [Schritte]
- **Expected Result**: [Erwartetes Ergebnis]
- **Actual Result**: [Tatsächliches Ergebnis]
- **Fix**: [Lösung]

## Issue 2: [Titel]
...
```

### **Performance Metrics:**
```
# Hier Performance-Metriken dokumentieren:

## Database Queries:
- Average Query Time: [X]ms
- Slowest Query: [X]ms
- Query Success Rate: [X]%

## Real-time Updates:
- Average Update Time: [X]ms
- Update Success Rate: [X]%

## Image Uploads:
- Average Upload Time: [X]s
- Upload Success Rate: [X]%
```

---

## 🎯 **9. Next Steps**

### **After Testing:**
1. **Fix Critical Issues** (P0)
2. **Address Important Issues** (P1)
3. **Plan Enhancements** (P2)
4. **Performance Optimization**
5. **Security Review**
6. **Production Deployment**

### **Deployment Checklist:**
- [ ] Alle Tests bestanden
- [ ] Performance-Ziele erreicht
- [ ] Security-Review abgeschlossen
- [ ] Monitoring eingerichtet
- [ ] Backup-Strategie implementiert
- [ ] Rollback-Plan erstellt

---

## 📞 **10. Support & Contact**

### **Bei Problemen:**
- **Supabase Dashboard**: https://supabase.com/dashboard/project/nqxgsuxyvhjveigbjyxb
- **App Logs**: Flutter Debug Console
- **Database Logs**: Supabase Dashboard > Logs

### **Test-Team:**
- **Lead Tester**: [Name]
- **Date**: $(date)
- **Version**: 1.0.0

---

**Status**: 🟡 **IN PROGRESS**  
**Last Updated**: $(date)  
**Next Review**: [Datum]
