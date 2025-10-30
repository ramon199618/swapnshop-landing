-- Supabase Schema für vereinheitlichte Listings (Gruppen, Stores, allgemein)
-- Alle Inhalte werden in einer zentralen Tabelle gespeichert

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "cron";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Für Volltext-Suche

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_premium BOOLEAN DEFAULT FALSE,
    premium_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Usage Quota für monatliche Limits
CREATE TABLE IF NOT EXISTS public.usage_quota (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    month_key TEXT NOT NULL, -- Format: YYYY-MM (Europe/Zurich)
    swap_used INTEGER DEFAULT 0,
    sell_used INTEGER DEFAULT 0,
    swap_bonus INTEGER DEFAULT 0, -- Durch Spenden freigeschaltet
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, month_key)
);

-- VEREINHEITLICHTE LISTINGS TABLE
CREATE TABLE IF NOT EXISTS public.listings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('swap', 'giveaway', 'sell')),
    category TEXT NOT NULL,
    price DECIMAL(10,2), -- nullable für Giveaways
    value DECIMAL(10,2), -- geschätzter Wert
    desired_item TEXT, -- Was wird gesucht? (nur bei Swap)
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    owner_name TEXT NOT NULL,
    images TEXT[],
    tags TEXT[],
    offer_tags TEXT[], -- Was wird angeboten? (nur bei Swap)
    want_tags TEXT[], -- Was wird gesucht? (nur bei Swap)
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location_name TEXT,
    radius_km INTEGER DEFAULT 50,
    is_active BOOLEAN DEFAULT TRUE,
    visibility TEXT DEFAULT 'public' CHECK (visibility IN ('public', 'group_only', 'store_only', 'private')),
    language TEXT DEFAULT 'de' CHECK (language IN ('de', 'it', 'fr', 'en', 'pt')),
    group_id UUID, -- Optional: Quelle Gruppe
    store_id UUID, -- Optional: Quelle Store
    is_anonymous BOOLEAN DEFAULT FALSE,
    condition TEXT DEFAULT 'used' CHECK (condition IN ('new', 'like_new', 'used', 'worn')),
    keywords_tsv TSVECTOR, -- Volltext-Suchvektor
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SWIPE INDEX für globale Swipe-Ansicht
CREATE TABLE IF NOT EXISTS public.swipe_index (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    keywords_tsv TSVECTOR NOT NULL,
    category TEXT NOT NULL,
    language TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    radius_km INTEGER DEFAULT 50,
    created_at TIMESTAMPTZ NOT NULL,
    score_cache DECIMAL(10,6) DEFAULT 0, -- Gecachter Score für Performance
    is_public BOOLEAN DEFAULT TRUE, -- Nur public Listings
    UNIQUE(listing_id)
);

-- Likes table
CREATE TABLE IF NOT EXISTS public.likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, listing_id)
);

-- Passes table (für Swipe-Logik)
CREATE TABLE IF NOT EXISTS public.passes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, listing_id)
);

-- Matches table
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_a_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    user_b_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    listing_a_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    listing_b_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_a_id, user_b_id, listing_a_id, listing_b_id)
);

-- Communities table
CREATE TABLE IF NOT EXISTS public.communities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    is_public BOOLEAN DEFAULT TRUE,
    allow_global_visibility BOOLEAN DEFAULT TRUE, -- Erlaubt Listings global sichtbar zu machen
    member_count INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Community members table
CREATE TABLE IF NOT EXISTS public.community_members (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    role TEXT DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'moderator', 'member')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(community_id, user_id)
);

-- Stores table
CREATE TABLE IF NOT EXISTS public.stores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    store_type TEXT NOT NULL CHECK (store_type IN ('second_hand', 'small', 'pro')),
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    logo_url TEXT,
    banner_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_restricted BOOLEAN DEFAULT FALSE, -- Beschränkt globale Sichtbarkeit
    allow_global_visibility BOOLEAN DEFAULT TRUE, -- Erlaubt Listings global sichtbar zu machen
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Store Ads für Banner-Werbung
CREATE TABLE IF NOT EXISTS public.store_ads (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    link_url TEXT,
    radius_km INTEGER NOT NULL CHECK (radius_km >= 1 AND radius_km <= 50),
    center_lat DOUBLE PRECISION NOT NULL,
    center_lon DOUBLE PRECISION NOT NULL,
    center_geo GEOGRAPHY(POINT, 4326),
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'active', 'paused', 'ended')),
    budget_tier INTEGER DEFAULT 1 CHECK (budget_tier >= 1 AND budget_tier <= 3),
    price_chf DECIMAL(10,2) NOT NULL,
    impressions_count INTEGER DEFAULT 0,
    clicks_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('premium_monthly', 'premium_yearly')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'past_due')),
    stripe_subscription_id TEXT,
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments table
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'CHF',
    payment_type TEXT NOT NULL CHECK (payment_type IN ('premium_monthly', 'premium_yearly', 'addon_swaps_5', 'addon_sells_5')),
    payment_method TEXT,
    stripe_payment_intent_id TEXT,
    payrexx_payment_id TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled', 'refunded')),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chats table
CREATE TABLE IF NOT EXISTS public.chats (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat participants table
CREATE TABLE IF NOT EXISTS public.chat_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    chat_id UUID REFERENCES public.chats(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(chat_id, user_id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    chat_id UUID REFERENCES public.chats(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Banners table
CREATE TABLE IF NOT EXISTS public.banners (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    link_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES für Performance
CREATE INDEX IF NOT EXISTS idx_listings_visibility ON public.listings(visibility, is_active);
CREATE INDEX IF NOT EXISTS idx_listings_category ON public.listings(category);
CREATE INDEX IF NOT EXISTS idx_listings_language ON public.listings(language);
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON public.listings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_listings_geo ON public.listings USING GIST (
    ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
);
CREATE INDEX IF NOT EXISTS idx_listings_keywords ON public.listings USING GIN(keywords_tsv);
CREATE INDEX IF NOT EXISTS idx_listings_owner ON public.listings(owner_id);
CREATE INDEX IF NOT EXISTS idx_listings_group ON public.listings(group_id) WHERE group_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_listings_store ON public.listings(store_id) WHERE store_id IS NOT NULL;

-- Swipe Index Performance
CREATE INDEX IF NOT EXISTS idx_swipe_index_public ON public.swipe_index(is_public, score_cache DESC);
CREATE INDEX IF NOT EXISTS idx_swipe_index_category ON public.swipe_index(category);
CREATE INDEX IF NOT EXISTS idx_swipe_index_language ON public.swipe_index(language);
CREATE INDEX IF NOT EXISTS idx_swipe_index_geo ON public.swipe_index USING GIST (
    ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
);
CREATE INDEX IF NOT EXISTS idx_swipe_index_keywords ON public.swipe_index USING GIN(keywords_tsv);

-- Likes & Passes Performance
CREATE INDEX IF NOT EXISTS idx_likes_user ON public.likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_listing ON public.likes(listing_id);
CREATE INDEX IF NOT EXISTS idx_passes_user ON public.passes(user_id);
CREATE INDEX IF NOT EXISTS idx_passes_listing ON public.passes(listing_id);

-- Communities & Stores Performance
CREATE INDEX IF NOT EXISTS idx_communities_public ON public.communities(is_public);
CREATE INDEX IF NOT EXISTS idx_stores_active ON public.stores(is_active);

-- TRIGGER FUNCTIONS für automatische Swipe-Index-Pflege

-- Funktion zum Aktualisieren des keywords_tsv
CREATE OR REPLACE FUNCTION update_listing_keywords()
RETURNS TRIGGER AS $$
BEGIN
    -- Kombiniere title, description, tags, offer_tags, want_tags
    NEW.keywords_tsv = 
        setweight(to_tsvector('german', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('german', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('german', array_to_string(COALESCE(NEW.tags, ARRAY[]::text[]), ' ')), 'C') ||
        setweight(to_tsvector('german', array_to_string(COALESCE(NEW.offer_tags, ARRAY[]::text[]), ' ')), 'C') ||
        setweight(to_tsvector('german', array_to_string(COALESCE(NEW.want_tags, ARRAY[]::text[]), ' ')), 'C');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger für keywords_tsv Update
CREATE TRIGGER trigger_update_listing_keywords
    BEFORE INSERT OR UPDATE ON public.listings
    FOR EACH ROW
    EXECUTE FUNCTION update_listing_keywords();

-- Funktion zum Aktualisieren des Swipe-Index
CREATE OR REPLACE FUNCTION update_swipe_index()
RETURNS TRIGGER AS $$
BEGIN
    -- Wenn Listing public und active ist, in swipe_index aufnehmen/aktualisieren
    IF NEW.visibility = 'public' AND NEW.is_active = true THEN
        INSERT INTO public.swipe_index (
            listing_id, keywords_tsv, category, language, 
            latitude, longitude, radius_km, created_at, is_public
        ) VALUES (
            NEW.id, NEW.keywords_tsv, NEW.category, NEW.language,
            NEW.latitude, NEW.longitude, NEW.radius_km, NEW.created_at, true
        )
        ON CONFLICT (listing_id) DO UPDATE SET
            keywords_tsv = EXCLUDED.keywords_tsv,
            category = EXCLUDED.category,
            language = EXCLUDED.language,
            latitude = EXCLUDED.latitude,
            longitude = EXCLUDED.longitude,
            radius_km = EXCLUDED.radius_km,
            updated_at = NOW();
    ELSE
        -- Wenn nicht public oder nicht active, aus swipe_index entfernen
        DELETE FROM public.swipe_index WHERE listing_id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger für Swipe-Index Update
CREATE TRIGGER trigger_update_swipe_index
    AFTER INSERT OR UPDATE ON public.listings
    FOR EACH ROW
    EXECUTE FUNCTION update_swipe_index();

-- Funktion zum Entfernen aus Swipe-Index bei Löschung
CREATE OR REPLACE FUNCTION remove_from_swipe_index()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.swipe_index WHERE listing_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger für Swipe-Index Löschung
CREATE TRIGGER trigger_remove_from_swipe_index
    AFTER DELETE ON public.listings
    FOR EACH ROW
    EXECUTE FUNCTION remove_from_swipe_index();

-- RLS POLICIES

-- Listings: Nur public Listings sind global sichtbar
CREATE POLICY "Listings are viewable by everyone if public" ON public.listings
    FOR SELECT USING (visibility = 'public' AND is_active = true);

-- Listings: Gruppenmitglieder können group_only Listings sehen
CREATE POLICY "Group members can view group_only listings" ON public.listings
    FOR SELECT USING (
        visibility = 'group_only' AND 
        group_id IN (
            SELECT community_id FROM public.community_members 
            WHERE user_id = auth.uid()
        )
    );

-- Listings: Store-Besitzer können store_only Listings sehen
CREATE POLICY "Store owners can view store_only listings" ON public.listings
    FOR SELECT USING (
        visibility = 'store_only' AND 
        store_id IN (
            SELECT id FROM public.stores 
            WHERE owner_id = auth.uid()
        )
    );

-- Listings: Eigentümer können ihre eigenen Listings bearbeiten
CREATE POLICY "Users can update own listings" ON public.listings
    FOR UPDATE USING (owner_id = auth.uid());

-- Listings: Eigentümer können ihre eigenen Listings löschen
CREATE POLICY "Users can delete own listings" ON public.listings
    FOR DELETE USING (owner_id = auth.uid());

-- Swipe Index: Nur public Listings sind sichtbar
CREATE POLICY "Swipe index is viewable by everyone" ON public.swipe_index
    FOR SELECT USING (is_public = true);

-- Communities: Öffentliche Communities sind für alle sichtbar
CREATE POLICY "Public communities are viewable by everyone" ON public.communities
    FOR SELECT USING (is_public = true);

-- Communities: Mitglieder können private Communities sehen
CREATE POLICY "Members can view private communities" ON public.communities
    FOR SELECT USING (
        id IN (
            SELECT community_id FROM public.community_members 
            WHERE user_id = auth.uid()
        )
    );

-- Stores: Aktive Stores sind für alle sichtbar
CREATE POLICY "Active stores are viewable by everyone" ON public.stores
    FOR SELECT USING (is_active = true);

-- Likes & Passes: Benutzer können ihre eigenen Aktionen sehen
CREATE POLICY "Users can view own likes" ON public.likes
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can view own passes" ON public.passes
    FOR SELECT USING (user_id = auth.uid());

-- Likes & Passes: Benutzer können neue Aktionen erstellen
CREATE POLICY "Users can create likes" ON public.likes
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can create passes" ON public.passes
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Matches: Benutzer können ihre eigenen Matches sehen
CREATE POLICY "Users can view own matches" ON public.matches
    FOR SELECT USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

-- RLS aktivieren
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swipe_index ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.passes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

-- FUNKTIONEN für Swipe-Feed

-- Funktion zum Abrufen des Swipe-Feeds
CREATE OR REPLACE FUNCTION get_swipe_feed(
    p_user_id UUID,
    p_radius_km INTEGER DEFAULT 50,
    p_category TEXT DEFAULT NULL,
    p_language TEXT DEFAULT 'de',
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    listing_id UUID,
    title TEXT,
    description TEXT,
    type TEXT,
    category TEXT,
    price DECIMAL(10,2),
    value DECIMAL(10,2),
    desired_item TEXT,
    owner_id UUID,
    owner_name TEXT,
    images TEXT[],
    tags TEXT[],
    offer_tags TEXT[],
    want_tags TEXT[],
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location_name TEXT,
    radius_km INTEGER,
    is_anonymous BOOLEAN,
    condition TEXT,
    group_id UUID,
    store_id UUID,
    created_at TIMESTAMPTZ,
    score DECIMAL(10,6),
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id as listing_id,
        l.title,
        l.description,
        l.type,
        l.category,
        l.price,
        l.value,
        l.desired_item,
        l.owner_id,
        l.owner_name,
        l.images,
        l.tags,
        l.offer_tags,
        l.want_tags,
        l.latitude,
        l.longitude,
        l.location_name,
        l.radius_km,
        l.is_anonymous,
        l.condition,
        l.group_id,
        l.store_id,
        l.created_at,
        si.score_cache as score,
        CASE 
            WHEN l.latitude IS NOT NULL AND l.longitude IS NOT NULL THEN
                ST_Distance(
                    ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                    ST_SetSRID(ST_MakePoint(
                        (SELECT longitude FROM public.profiles WHERE id = p_user_id),
                        (SELECT latitude FROM public.profiles WHERE id = p_user_id)
                    ), 4326)::geography
                ) / 1000.0
            ELSE NULL
        END as distance_km
    FROM public.swipe_index si
    JOIN public.listings l ON si.listing_id = l.id
    WHERE 
        si.is_public = true
        AND l.owner_id != p_user_id -- Nicht eigene Listings
        AND l.id NOT IN ( -- Nicht bereits gelikte/passierte Listings
            SELECT listing_id FROM public.likes WHERE user_id = p_user_id
            UNION
            SELECT listing_id FROM public.passes WHERE user_id = p_user_id
        )
        AND (p_category IS NULL OR l.category = p_category)
        AND (p_language IS NULL OR l.language = p_language)
        AND (
            l.latitude IS NULL OR 
            l.longitude IS NULL OR
            ST_DWithin(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(
                    (SELECT longitude FROM public.profiles WHERE id = p_user_id),
                    (SELECT latitude FROM public.profiles WHERE id = p_user_id)
                ), 4326)::geography,
                p_radius_km * 1000.0
            )
        )
    ORDER BY 
        si.score_cache DESC,
        l.created_at DESC,
        random() -- Zufallskomponente für Entdeckung
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funktion zum Aktualisieren des Score-Caches
CREATE OR REPLACE FUNCTION update_swipe_score(listing_uuid UUID)
RETURNS VOID AS $$
DECLARE
    base_score DECIMAL(10,6);
    engagement_score DECIMAL(10,6);
    freshness_score DECIMAL(10,6);
    final_score DECIMAL(10,6);
BEGIN
    -- Basis-Score basierend auf Listing-Qualität
    SELECT 
        CASE 
            WHEN l.images IS NOT NULL AND array_length(l.images, 1) > 0 THEN 0.3
            ELSE 0.1
        END +
        CASE 
            WHEN l.description IS NOT NULL AND length(l.description) > 50 THEN 0.2
            ELSE 0.1
        END +
        CASE 
            WHEN l.tags IS NOT NULL AND array_length(l.tags, 1) > 0 THEN 0.2
            ELSE 0.1
        END
    INTO base_score
    FROM public.listings l WHERE l.id = listing_uuid;
    
    -- Engagement-Score basierend auf Likes
    SELECT COALESCE(
        (SELECT COUNT(*)::DECIMAL / 100.0 FROM public.likes WHERE listing_id = listing_uuid),
        0.0
    ) INTO engagement_score;
    
    -- Freshness-Score (ältere Listings bekommen niedrigeren Score)
    SELECT 
        GREATEST(0.0, 1.0 - EXTRACT(EPOCH FROM (NOW() - l.created_at)) / (86400.0 * 30.0))
    INTO freshness_score
    FROM public.listings l WHERE l.id = listing_uuid;
    
    -- Finaler Score
    final_score = (base_score * 0.4) + (engagement_score * 0.3) + (freshness_score * 0.3);
    
    -- Score in swipe_index aktualisieren
    UPDATE public.swipe_index 
    SET score_cache = final_score, updated_at = NOW()
    WHERE listing_id = listing_uuid;
END;
$$ LANGUAGE plpgsql;

-- CRON JOB für Score-Updates (alle 6 Stunden)
SELECT cron.schedule(
    'update-swipe-scores',
    '0 */6 * * *',
    'SELECT update_swipe_score(id) FROM public.listings WHERE visibility = ''public'' AND is_active = true;'
);

-- MIGRATION: Bestehende Daten in neue Struktur übertragen
-- Diese Funktion kann nach dem Schema-Update ausgeführt werden

CREATE OR REPLACE FUNCTION migrate_existing_listings()
RETURNS VOID AS $$
BEGIN
    -- Aktualisiere bestehende listings Tabelle
    -- (Falls bereits Daten vorhanden sind)
    
    -- Füge fehlende Spalten hinzu (falls nicht vorhanden)
    ALTER TABLE public.listings 
    ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'swap',
    ADD COLUMN IF NOT EXISTS value DECIMAL(10,2),
    ADD COLUMN IF NOT EXISTS desired_item TEXT,
    ADD COLUMN IF NOT EXISTS offer_tags TEXT[] DEFAULT ARRAY[]::text[],
    ADD COLUMN IF NOT EXISTS want_tags TEXT[] DEFAULT ARRAY[]::text[],
    ADD COLUMN IF NOT EXISTS visibility TEXT DEFAULT 'public',
    ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'de',
    ADD COLUMN IF NOT EXISTS group_id UUID,
    ADD COLUMN IF NOT EXISTS store_id UUID,
    ADD COLUMN IF NOT EXISTS is_anonymous BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS keywords_tsv TSVECTOR,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
    
    -- Aktualisiere bestehende Listings
    UPDATE public.listings SET
        type = CASE 
            WHEN category = 'giveaway' THEN 'giveaway'
            WHEN price > 0 THEN 'sell'
            ELSE 'swap'
        END,
        offer_tags = COALESCE(tags, ARRAY[]::text[]),
        want_tags = ARRAY[]::text[],
        keywords_tsv = setweight(to_tsvector('german', COALESCE(title, '')), 'A') ||
                      setweight(to_tsvector('german', COALESCE(description, '')), 'B') ||
                      setweight(to_tsvector('german', array_to_string(COALESCE(tags, ARRAY[]::text[]), ' ')), 'C');
    
    -- Erstelle swipe_index für bestehende public Listings
    INSERT INTO public.swipe_index (
        listing_id, keywords_tsv, category, language, 
        latitude, longitude, radius_km, created_at, is_public
    )
    SELECT 
        id, keywords_tsv, category, language,
        latitude, longitude, radius_km, created_at, true
    FROM public.listings 
    WHERE visibility = 'public' AND is_active = true
    ON CONFLICT (listing_id) DO NOTHING;
    
    -- Aktualisiere Scores für bestehende Listings
    SELECT update_swipe_score(id) FROM public.listings 
    WHERE visibility = 'public' AND is_active = true;
END;
$$ LANGUAGE plpgsql; 