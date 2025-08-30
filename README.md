# Swap&Shop

Eine Flutter-App für Tausch, Verkauf und Communities.

## Features

### ✅ Implementiert
- **Premium-System**: Vollständiger Premium-Flow mit Limits und Upgrade-Screen
- **Store-System**: Store-Erstellung und -Verwaltung
- **Filter & Suche**: Erweiterte Filterfunktionen für Stores
- **Swipe-System**: Like/Dislike mit Matches
- **Internationalisierung**: DE/EN/FR/IT/PT Support
- **Dark/Light Mode**: Vollständige Theme-Unterstützung

### 🔄 Offene Tasks

#### Hochpriorität
- [ ] **Zahlungsintegration**: Stripe/Twint/Apple Pay für Premium-Upgrades
- [ ] **Standort-Service**: GPS-basierte Radius-Filter
- [ ] **Push-Benachrichtigungen**: Für Matches und neue Inserate
- [ ] **Bild-Upload**: Supabase Storage Integration

#### Mittlere Priorität
- [ ] **Chat-System**: Vollständige Messaging-Funktionalität
- [ ] **Community-Management**: Mitglieder-Verwaltung und Privacy-Settings
- [ ] **Analytics**: Store-Statistiken und Nutzer-Metriken
- [ ] **Banner-System**: Radius-Werbung für Premium-Stores

#### Niedrige Priorität
- [ ] **Offline-Support**: Caching und Offline-Funktionalität
- [ ] **Social Features**: Teilen und Empfehlungen
- [ ] **Gamification**: Badges und Achievements
- [ ] **A/B Testing**: Feature-Flags und Experimente

### 🐛 Bekannte Issues
- [ ] Store-Banner werden manchmal vom FAB verdeckt
- [ ] Einige Texte sind noch nicht vollständig lokalisiert
- [ ] Premium-Limits werden nur lokal gespeichert (noch nicht in Supabase)

## Technische Details

### Architektur
- **State Management**: Provider Pattern
- **Backend**: Supabase (Auth, Database, Storage)
- **Lokalisierung**: Flutter Intl mit .arb Files
- **Navigation**: Direct Navigator.push() Calls

### Premium-Limits
- **Swaps**: 5 kostenlose pro Monat
- **Verkäufe**: 2 kostenlose pro Monat
- **Giveaways**: Unbegrenzt
- **Reset**: Automatisch am Monatsanfang

### Store-Typen
1. **Second-Hand-Händler:in**: Kostenlos, einfache Funktionen
2. **Kleiner Store**: Kleiner Preis, eigene Gestaltung
3. **Professioneller Store**: Abo-Modell, erweiterte Features

## Build & Deployment

```bash
# Debug Build
flutter build ios --debug --no-codesign

# Release Build
flutter build ios --release

# Run auf Device
flutter run --release
```

## Entwicklung

### Setup
1. Flutter SDK installieren
2. Dependencies installieren: `flutter pub get`
3. iOS Setup: `cd ios && pod install`
4. Supabase konfigurieren

### Code-Style
- Dart/Flutter Best Practices
- Konsistente Namensgebung
- Vollständige Lokalisierung
- Error Handling

### Testing
- Widget Tests für UI-Komponenten
- Integration Tests für Flows
- Unit Tests für Services
