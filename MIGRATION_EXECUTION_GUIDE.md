# Store-Erstellung: Migrations-Ausführung

## 📋 Übersicht

Dieses Dokument erklärt, wie die Migration für die `stores` Tabelle in Supabase Production ausgeführt wird.

**Projekt:** Swap&Shop • main (Production)  
**Supabase URL:** https://nqxgsuxyvhjveigbjyxb.supabase.co  
**Project Reference ID:** `nqxgsuxyvhjveigbjyxb`

---

## 🚀 Migration ausführen

### Schritt 1: Supabase SQL Editor öffnen

1. Gehe zu: https://supabase.com/dashboard/project/nqxgsuxyvhjveigbjyxb/sql
2. Klicke auf "New query"

### Schritt 2: Migrations-SQL laden

```bash
# Datei anzeigen
cat migrations/2025-01-07_stores_fix.sql
```

Oder öffne die Datei direkt:
```
migrations/2025-01-07_stores_fix.sql
```

### Schritt 3: SQL in Editor einfügen und ausführen

1. Kopiere den **gesamten Inhalt** von `migrations/2025-01-07_stores_fix.sql`
2. Füge ihn in die Supabase SQL-Konsole ein
3. Klicke auf **"Run"** (oder drücke `Cmd + Enter` / `Ctrl + Enter`)

### Schritt 4: Ergebnis prüfen

**Erwartete Ausgabe:**
```
BEGIN
CREATE EXTENSION
CREATE TABLE
DO
CREATE OR REPLACE FUNCTION
DROP TRIGGER
CREATE TRIGGER
CREATE INDEX
ALTER TABLE
DROP POLICY
CREATE POLICY
[...]
COMMIT
SUCCESS: Migration abgeschlossen
```

**Bei Fehlern:** Siehe "Fehlerbehandlung" unten.

---

## ✅ Verifikation nach Migration

### 1. Tabelle existiert?

```sql
SELECT 
  table_name, 
  table_schema 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'stores';
```

**Erwartet:** `stores` in Tabelle `public`

### 2. Alle Spalten vorhanden?

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'stores'
ORDER BY ordinal_position;
```

**Erwartet:** 9 Spalten (id, user_id, name, description, logo_url, type, status, created_at, updated_at)

### 3. Foreign Key vorhanden?

```sql
SELECT 
  tc.constraint_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'stores' 
  AND tc.constraint_type = 'FOREIGN KEY';
```

**Erwartet:** Foreign Key `stores_user_id_fkey` zu `auth.users(id)`

### 4. RLS aktiviert?

```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'stores';
```

**Erwartet:** `rowsecurity = true`

### 5. Policies vorhanden?

```sql
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'stores';
```

**Erwartet:** 4 Policies:
- `Users can view their own stores` (SELECT)
- `Users can insert their own stores` (INSERT)
- `Users can update their own stores` (UPDATE)
- `Users can delete their own stores` (DELETE)

### 6. Trigger vorhanden?

```sql
SELECT tgname, tgtype::text
FROM pg_trigger 
WHERE tgrelid = 'public.stores'::regclass;
```

**Erwartet:** `update_stores_updated_at` Trigger

### 7. Indizes vorhanden?

```sql
SELECT indexname, indexdef
FROM pg_indexes 
WHERE schemaname = 'public' AND tablename = 'stores';
```

**Erwartet:** 3 Indizes:
- `idx_stores_user_id`
- `idx_stores_status`
- `idx_stores_created_at`

---

## 🐛 Fehlerbehandlung

### Fehler: "relation already exists"

**Ursache:** Tabelle existiert bereits

**Lösung:** Das ist **OK**! Die Migration ist idempotent und kann wiederholt werden. Die `CREATE TABLE IF NOT EXISTS` Anweisung erstellt die Tabelle nur, falls sie nicht existiert.

**Aktion:** Migration einfach weiterlaufen lassen.

### Fehler: "function update_updated_at_column() already exists"

**Ursache:** Funktion existiert bereits

**Lösung:** Das ist **OK**! `CREATE OR REPLACE FUNCTION` überschreibt die Funktion ohne Daten zu löschen.

**Aktion:** Migration einfach weiterlaufen lassen.

### Fehler: "permission denied for table stores"

**Ursache:** Keine Berechtigung

**Lösung:** 
1. Stelle sicher, dass du im richtigen Supabase-Projekt bist
2. Verwende ein Account mit Admin-Rechten
3. Versuche die Migration erneut

### Fehler: "violates foreign key constraint"

**Ursache:** `user_id` existiert nicht in `auth.users`

**Lösung:** 
1. Prüfe, ob der User existiert: `SELECT * FROM auth.users WHERE id = '<user_id>';`
2. Falls nicht, erstelle den User über die Supabase Auth
3. Führe die Migration erneut aus

### Fehler: "no such file"

**Ursache:** Migration-Datei nicht gefunden

**Lösung:**
```bash
# Prüfe, ob Datei existiert
ls -lh migrations/2025-01-07_stores_fix.sql

# Falls nicht vorhanden, verwende die alternative:
cat supabase_migration_stores_production.sql
```

---

## 🧪 Test in der App

### Test 1: Store-Erstellung

1. Öffne die App auf dem iPhone
2. Navigiere zu "Meine Stores" oder "Store erstellen"
3. Fülle das Formular aus:
   - **Name:** "Test Store"
   - **Beschreibung:** "Test"
   - **Typ:** Wähle einen Typ (1, 2 oder 3)
4. Klicke auf "Store erstellen"

**Erwartetes Ergebnis:**
- ✅ Keine Fehlermeldung
- ✅ Store wird erfolgreich erstellt
- ✅ Store erscheint in "Meine Stores"

### Test 2: Debug-Logs in Xcode

In Xcode Console sollte erscheinen:

```
🔧 Creating store with data: {name: Test Store, user_id: ..., ...}
🔧 Using table: stores
✅ Store created successfully: {id: ..., name: ...}
```

### Test 3: updated_at automatisch aktualisieren

```sql
-- Store laden
SELECT id, name, updated_at FROM public.stores 
WHERE user_id = '<deine_user_id>' 
ORDER BY created_at DESC LIMIT 1;

-- Store aktualisieren
UPDATE public.stores SET name = 'Updated Name' 
WHERE id = '<store_id>';

-- Prüfen, ob updated_at sich geändert hat
SELECT updated_at FROM public.stores WHERE id = '<store_id>';
```

**Erwartet:** `updated_at` ist jetzt aktueller Zeitstempel

---

## 🔄 Erneute Ausführung

Die Migration ist **idempotent** und kann beliebig oft ausgeführt werden:

1. Öffne die Supabase SQL-Konsole
2. Führe die Migration erneut aus
3. Keine Fehler = ✅ Alles OK

---

## 📊 Status-Übersicht

### Vor Migration

- ❌ Tabelle `public.stores` fehlt oder unvollständig
- ❌ Funktion `update_updated_at_column()` fehlt
- ❌ Trigger `update_stores_updated_at` fehlt
- ❌ RLS-Policies fehlen oder fehlerhaft
- ❌ Store-Erstellung schlägt mit 404 fehl

### Nach Migration

- ✅ Tabelle `public.stores` vollständig
- ✅ Funktion `update_updated_at_column()` vorhanden
- ✅ Trigger `update_stores_updated_at` aktiv
- ✅ RLS-Policies erstellt (nur Owner-Zugriff)
- ✅ Store-Erstellung funktioniert
- ✅ `updated_at` wird automatisch gesetzt
- ✅ Keine Daten gelöscht

---

## 📁 Dateien

- **Migration:** `migrations/2025-01-07_stores_fix.sql`
- **Dokumentation:** `docs/db-stores-fix.md`
- **Ausführungs-Guide:** `MIGRATION_EXECUTION_GUIDE.md` (dieses Dokument)
- **Alternative Migration:** `supabase_migration_stores_production.sql`

---

## ✅ Check-Liste

- [ ] Supabase SQL Editor geöffnet
- [ ] Migration ausgeführt
- [ ] Keine Fehler in der Ausgabe
- [ ] Tabelle `stores` existiert
- [ ] Alle 9 Spalten vorhanden
- [ ] Foreign Key zu `auth.users` vorhanden
- [ ] RLS aktiviert
- [ ] 4 Policies vorhanden
- [ ] Trigger vorhanden
- [ ] 3 Indizes vorhanden
- [ ] Store-Erstellung in App funktioniert
- [ ] `updated_at` wird automatisch gesetzt

---

**Erstellt:** 2025-01-07  
**Von:** Cursor AI  
**Projekt:** Swap&Shop • main (Production)

