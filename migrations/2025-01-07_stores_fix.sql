-- ============================================
-- Store-Erstellung: Idempotente Migration für Production
-- Projekt: Swap&Shop • main (Production)
-- URL: https://nqxgsuxyvhjveigbjyxb.supabase.co
-- Datum: 2025-01-07
-- ============================================
-- Diese Migration ist sicher wiederholbar (idempotent)
-- Keine destruktiven Operationen - bestehende Daten bleiben erhalten

BEGIN;

-- ============================================
-- 1. Extension pgcrypto sicherstellen (für gen_random_uuid)
-- ============================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 2. Tabelle stores erstellen/ergänzen
-- ============================================

-- Haupttabelle erstellen, falls nicht existiert
CREATE TABLE IF NOT EXISTS public.stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT stores_type_check CHECK (type IN ('1', '2', '3', 'private', 'small', 'professional')),
  CONSTRAINT stores_status_check CHECK (status IN ('active', 'inactive', 'suspended'))
);

-- Fehlende Spalten hinzufügen (falls Tabelle bereits existiert)
DO $$
BEGIN
  -- user_id FK
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'stores_user_id_fkey'
  ) THEN
    ALTER TABLE public.stores 
    ADD CONSTRAINT stores_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;

  -- Beschreibung hinzufügen
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'stores' 
    AND column_name = 'description'
  ) THEN
    ALTER TABLE public.stores ADD COLUMN description TEXT;
  END IF;

  -- Logo URL hinzufügen
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'stores' 
    AND column_name = 'logo_url'
  ) THEN
    ALTER TABLE public.stores ADD COLUMN logo_url TEXT;
  END IF;

  -- Type hinzufügen
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'stores' 
    AND column_name = 'type'
  ) THEN
    ALTER TABLE public.stores ADD COLUMN type TEXT NOT NULL DEFAULT '1';
  END IF;

  -- Status hinzufügen
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'stores' 
    AND column_name = 'status'
  ) THEN
    ALTER TABLE public.stores ADD COLUMN status TEXT NOT NULL DEFAULT 'active';
  END IF;

  -- created_at hinzufügen
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'stores' 
    AND column_name = 'created_at'
  ) THEN
    ALTER TABLE public.stores ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
  END IF;

  -- updated_at hinzufügen
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'stores' 
    AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public.stores ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
END $$;

-- ============================================
-- 3. Funktion update_updated_at_column() erstellen
-- ============================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. Trigger für automatische updated_at Updates
-- ============================================

-- Trigger droppen, falls existiert (um Neu-Erstellung zu ermöglichen)
DROP TRIGGER IF EXISTS update_stores_updated_at ON public.stores;

-- Trigger neu erstellen
CREATE TRIGGER update_stores_updated_at
BEFORE UPDATE ON public.stores
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 5. Indizes erstellen
-- ============================================

CREATE INDEX IF NOT EXISTS idx_stores_user_id ON public.stores(user_id);
CREATE INDEX IF NOT EXISTS idx_stores_status ON public.stores(status);
CREATE INDEX IF NOT EXISTS idx_stores_created_at ON public.stores(created_at);

-- ============================================
-- 6. RLS aktivieren und Policies setzen
-- ============================================

-- RLS aktivieren
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;

-- Bestehende Policies droppen (für saubere Neu-Erstellung)
DROP POLICY IF EXISTS "Users can view all active stores" ON public.stores;
DROP POLICY IF EXISTS "Users can view their own stores" ON public.stores;
DROP POLICY IF EXISTS "Users can insert their own stores" ON public.stores;
DROP POLICY IF EXISTS "Users can update their own stores" ON public.stores;
DROP POLICY IF EXISTS "Users can delete their own stores" ON public.stores;

-- Neue Policies: Nur Eigentümer-Zugriff
CREATE POLICY "Users can view their own stores"
ON public.stores FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own stores"
ON public.stores FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own stores"
ON public.stores FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own stores"
ON public.stores FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- 7. Kommentare für Dokumentation
-- ============================================

COMMENT ON TABLE public.stores IS 'Stores von Benutzern (Privat, Klein, Professional)';
COMMENT ON COLUMN public.stores.type IS 'Store-Typ: 1=Privat, 2=Klein, 3=Professional';
COMMENT ON COLUMN public.stores.status IS 'Status: active, inactive, suspended';
COMMENT ON FUNCTION public.update_updated_at_column() IS 'Aktualisiert updated_at vor UPDATE';

COMMIT;

-- ============================================
-- SUCCESS: Migration abgeschlossen
-- ============================================
-- Tabelle: public.stores
-- RLS: Aktiviert
-- Policies: Nur Eigentümer-Zugriff
-- Trigger: update_stores_updated_at
-- Indizes: user_id, status, created_at
-- ============================================

