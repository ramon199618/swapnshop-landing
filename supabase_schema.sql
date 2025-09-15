-- Supabase Schema für Swap&Shop
-- Enthält alle Tabellen, Funktionen und Policies

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "cron";

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

-- Listings table
CREATE TABLE IF NOT EXISTS public.listings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('swap', 'giveaway', 'sell')),
    price DECIMAL(10,2),
    value DECIMAL(10,2),
    desired_item TEXT,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    owner_name TEXT NOT NULL,
    images TEXT[],
    tags TEXT[],
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location_name TEXT,
    radius INTEGER DEFAULT 50,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Likes table
CREATE TABLE IF NOT EXISTS public.likes (
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

-- Community posts table
CREATE TABLE IF NOT EXISTS public.community_posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE NOT NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    images TEXT[],
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Community post likes table
CREATE TABLE IF NOT EXISTS public.community_post_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Community post comments table
CREATE TABLE IF NOT EXISTS public.community_post_comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE NOT NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES public.community_post_comments(id) ON DELETE CASCADE,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Community invites table
CREATE TABLE IF NOT EXISTS public.community_invites (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE NOT NULL,
    inviter_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    invitee_email TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
    created_at TIMESTAMPTZ DEFAULT NOW()
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

-- Store Ad Impressions für Tracking
CREATE TABLE IF NOT EXISTS public.store_ad_impressions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ad_id UUID REFERENCES public.store_ads(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    user_lat DOUBLE PRECISION NOT NULL,
    user_lon DOUBLE PRECISION NOT NULL,
    distance_km DOUBLE PRECISION NOT NULL,
    rotation_slot INTEGER NOT NULL, -- Position in der Rotation
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Store Ad Clicks für Tracking
CREATE TABLE IF NOT EXISTS public.store_ad_clicks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    ad_id UUID REFERENCES public.store_ads(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    user_lat DOUBLE PRECISION NOT NULL,
    user_lon DOUBLE PRECISION NOT NULL,
    distance_km DOUBLE PRECISION NOT NULL,
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

-- Donations table
CREATE TABLE IF NOT EXISTS public.donations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method TEXT,
    stripe_payment_intent_id TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User credits table
CREATE TABLE IF NOT EXISTS public.user_credits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    swap_credits INTEGER DEFAULT 0,
    sell_credits INTEGER DEFAULT 0,
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

-- Indexes für bessere Performance
CREATE INDEX IF NOT EXISTS idx_listings_owner_id ON public.listings(owner_id);
CREATE INDEX IF NOT EXISTS idx_listings_category ON public.listings(category);
CREATE INDEX IF NOT EXISTS idx_listings_location ON public.listings(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON public.listings(created_at);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON public.likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_listing_id ON public.likes(listing_id);
CREATE INDEX IF NOT EXISTS idx_matches_user_a_id ON public.matches(user_a_id);
CREATE INDEX IF NOT EXISTS idx_matches_user_b_id ON public.matches(user_b_id);
CREATE INDEX IF NOT EXISTS idx_communities_owner_id ON public.communities(owner_id);
CREATE INDEX IF NOT EXISTS idx_community_members_community_id ON public.community_members(community_id);
CREATE INDEX IF NOT EXISTS idx_community_members_user_id ON public.community_members(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_chat_id ON public.chat_participants(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON public.messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_stores_owner_id ON public.stores(owner_id);
CREATE INDEX IF NOT EXISTS idx_banners_is_active ON public.banners(is_active);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_donations_user_id ON public.donations(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_quota_user_month ON public.usage_quota(user_id, month_key);

-- RPC Functions für Usage Quota

-- Prüft ob ein User ein Listing erstellen kann
CREATE OR REPLACE FUNCTION rpc_can_post(
    p_user_id UUID,
    p_category TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_is_premium BOOLEAN;
    v_month_key TEXT;
    v_quota RECORD;
    v_result JSONB;
BEGIN
    -- Prüfe ob User existiert und Premium-Status
    SELECT is_premium INTO v_is_premium
    FROM public.profiles
    WHERE id = p_user_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'reason', 'user_not_found',
            'remaining', 0
        );
    END IF;
    
    -- Aktueller Monat (Europe/Zurich)
    v_month_key := to_char(NOW() AT TIME ZONE 'Europe/Zurich', 'YYYY-MM');
    
    -- Hole aktuelle Quota
    SELECT * INTO v_quota
    FROM public.usage_quota
    WHERE user_id = p_user_id AND month_key = v_month_key;
    
    -- Erstelle Quota falls nicht vorhanden
    IF NOT FOUND THEN
        INSERT INTO public.usage_quota (user_id, month_key)
        VALUES (p_user_id, v_month_key)
        RETURNING * INTO v_quota;
    END IF;
    
    -- Prüfe Limits basierend auf Kategorie
    CASE p_category
        WHEN 'giveaway' THEN
            -- Giveaway ist immer erlaubt
            v_result := jsonb_build_object(
                'allowed', true,
                'reason', 'ok',
                'remaining', -1
            );
            
        WHEN 'swap' THEN
            -- Swap: 8 gratis + Bonus
            IF v_quota.swap_used < (8 + v_quota.swap_bonus) THEN
                v_result := jsonb_build_object(
                    'allowed', true,
                    'reason', 'ok',
                    'remaining', (8 + v_quota.swap_bonus) - v_quota.swap_used
                );
            ELSE
                v_result := jsonb_build_object(
                    'allowed', false,
                    'reason', 'limit_reached',
                    'remaining', 0
                );
            END IF;
            
        WHEN 'sell' THEN
            -- Sell: Premium oder 4 gratis
            IF v_is_premium THEN
                v_result := jsonb_build_object(
                    'allowed', true,
                    'reason', 'ok',
                    'remaining', -1
                );
            ELSIF v_quota.sell_used < 4 THEN
                v_result := jsonb_build_object(
                    'allowed', true,
                    'reason', 'ok',
                    'remaining', 4 - v_quota.sell_used
                );
            ELSE
                v_result := jsonb_build_object(
                    'allowed', false,
                    'reason', 'premium_required',
                    'remaining', 0
                );
            END IF;
            
        ELSE
            v_result := jsonb_build_object(
                'allowed', false,
                'reason', 'invalid_category',
                'remaining', 0
            );
    END CASE;
    
    RETURN v_result;
END;
$$;

-- Bestätigt ein erfolgreich erstelltes Listing und inkrementiert den Counter
CREATE OR REPLACE FUNCTION rpc_confirm_post(
    p_user_id UUID,
    p_category TEXT,
    p_listing_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_month_key TEXT;
    v_quota RECORD;
BEGIN
    -- Aktueller Monat (Europe/Zurich)
    v_month_key := to_char(NOW() AT TIME ZONE 'Europe/Zurich', 'YYYY-MM');
    
    -- Hole aktuelle Quota
    SELECT * INTO v_quota
    FROM public.usage_quota
    WHERE user_id = p_user_id AND month_key = v_month_key;
    
    -- Erstelle Quota falls nicht vorhanden
    IF NOT FOUND THEN
        INSERT INTO public.usage_quota (user_id, month_key)
        VALUES (p_user_id, v_month_key)
        RETURNING * INTO v_quota;
    END IF;
    
    -- Inkrementiere den passenden Counter
    CASE p_category
        WHEN 'swap' THEN
            UPDATE public.usage_quota
            SET swap_used = swap_used + 1,
                updated_at = NOW()
            WHERE user_id = p_user_id AND month_key = v_month_key;
            
        WHEN 'sell' THEN
            UPDATE public.usage_quota
            SET sell_used = sell_used + 1,
                updated_at = NOW()
            WHERE user_id = p_user_id AND month_key = v_month_key;
            
        WHEN 'giveaway' THEN
            -- Kein Counter für Giveaway
            RETURN true;
            
        ELSE
            RETURN false;
    END CASE;
    
    RETURN true;
END;
$$;

-- Funktion für Spenden (5 zusätzliche Swaps)
CREATE OR REPLACE FUNCTION rpc_add_swap_bonus(
    p_user_id UUID,
    p_amount INTEGER DEFAULT 5
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_month_key TEXT;
BEGIN
    -- Aktueller Monat (Europe/Zurich)
    v_month_key := to_char(NOW() AT TIME ZONE 'Europe/Zurich', 'YYYY-MM');
    
    -- Füge Bonus hinzu (upsert)
    INSERT INTO public.usage_quota (user_id, month_key, swap_bonus)
    VALUES (p_user_id, v_month_key, p_amount)
    ON CONFLICT (user_id, month_key)
    DO UPDATE SET
        swap_bonus = usage_quota.swap_bonus + p_amount,
        updated_at = NOW();
    
    RETURN true;
END;
$$;

-- Monatliche Limits zurücksetzen
CREATE OR REPLACE FUNCTION reset_monthly_limits()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_month_key TEXT;
    v_old_month_key TEXT;
BEGIN
    -- Neuer Monat (Europe/Zurich)
    v_new_month_key := to_char(NOW() AT TIME ZONE 'Europe/Zurich', 'YYYY-MM');
    
    -- Alter Monat (vorheriger Monat)
    v_old_month_key := to_char((NOW() AT TIME ZONE 'Europe/Zurich') - INTERVAL '1 month', 'YYYY-MM');
    
    -- Erstelle neue Quota für alle aktiven User
    INSERT INTO public.usage_quota (user_id, month_key, swap_used, sell_used, swap_bonus)
    SELECT 
        user_id,
        v_new_month_key,
        0, -- swap_used auf 0 setzen
        0, -- sell_used auf 0 setzen
        0  -- swap_bonus verfällt (Business-Regel)
    FROM public.usage_quota
    WHERE month_key = v_old_month_key
    ON CONFLICT (user_id, month_key) DO NOTHING;
    
    -- Log der Reset-Operation
    RAISE NOTICE 'Monthly limits reset for month: %', v_new_month_key;
END;
$$;

-- Funktion für faire Banner-Ausspielung mit lokaler Priorität
CREATE OR REPLACE FUNCTION get_targeted_banners(
    p_user_lat DOUBLE PRECISION,
    p_user_lon DOUBLE PRECISION,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id UUID,
    store_id UUID,
    title TEXT,
    description TEXT,
    image_url TEXT,
    link_url TEXT,
    radius_km INTEGER,
    distance_km DOUBLE PRECISION,
    ranking_score DOUBLE PRECISION,
    rotation_slot INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_point GEOGRAPHY;
    v_local_banners_count INTEGER;
    v_rotation_counter INTEGER;
BEGIN
    -- User-Position als Geography-Point
    v_user_point := ST_SetSRID(ST_MakePoint(p_user_lon, p_user_lat), 4326)::GEOGRAPHY;
    
    -- Hole aktuelle Rotation-Counter
    SELECT COALESCE(MAX(rotation_slot), 0) INTO v_rotation_counter
    FROM public.store_ad_impressions
    WHERE created_at >= NOW() - INTERVAL '1 hour';
    
    -- Zähle lokale Banner (≤ 5 km)
    SELECT COUNT(*) INTO v_local_banners_count
    FROM public.store_ads
    WHERE status = 'active'
      AND is_active = true
      AND NOW() BETWEEN start_at AND end_at
      AND ST_DWithin(
          center_geo,
          v_user_point,
          radius_km * 1000
      )
      AND radius_km <= 5;
    
    -- Garantiere mindestens 1 lokales Banner pro Rotation
    IF v_local_banners_count > 0 THEN
        -- Lokale Banner zuerst (≤ 5 km)
        RETURN QUERY
        SELECT 
            sa.id,
            sa.store_id,
            sa.title,
            sa.description,
            sa.image_url,
            sa.link_url,
            sa.radius_km,
            ST_Distance(sa.center_geo, v_user_point) / 1000.0 as distance_km,
            -- Ranking Score für lokale Banner (ohne Budget-Tier)
            (0.7 * (1.0 / (1.0 + (ST_Distance(sa.center_geo, v_user_point) / 1000.0))) +
             0.3 * EXTRACT(EPOCH FROM (NOW() - sa.created_at)) / 86400.0) as ranking_score,
            (v_rotation_counter + 1) % GREATEST(v_local_banners_count, 1) as rotation_slot
        FROM public.store_ads sa
        WHERE sa.status = 'active'
          AND sa.is_active = true
          AND NOW() BETWEEN sa.start_at AND sa.end_at
          AND ST_DWithin(
              sa.center_geo,
              v_user_point,
              sa.radius_km * 1000
          )
          AND sa.radius_km <= 5
        ORDER BY ranking_score DESC
        LIMIT GREATEST(1, p_limit / 2); -- Mindestens 1 lokales Banner
    END IF;
    
    -- Alle anderen Banner (inkl. lokale für vollständige Rotation)
    RETURN QUERY
    SELECT 
        sa.id,
        sa.store_id,
        sa.title,
        sa.description,
        sa.image_url,
        sa.link_url,
        sa.radius_km,
        ST_Distance(sa.center_geo, v_user_point) / 1000.0 as distance_km,
        -- Vollständiger Ranking Score für alle Banner
        (0.5 * (1.0 / (1.0 + (ST_Distance(sa.center_geo, v_user_point) / 1000.0))) +
         0.3 * EXTRACT(EPOCH FROM (NOW() - sa.created_at)) / 86400.0 +
         0.2 * sa.budget_tier) as ranking_score,
        (v_rotation_counter + 1) % GREATEST(COUNT(*) OVER(), 1) as rotation_slot
    FROM public.store_ads sa
    WHERE sa.status = 'active'
      AND sa.is_active = true
      AND NOW() BETWEEN sa.start_at AND sa.end_at
      AND ST_DWithin(
          sa.center_geo,
          v_user_point,
          sa.radius_km * 1000
      )
    ORDER BY 
        CASE WHEN sa.radius_km <= 5 THEN 0 ELSE 1 END, -- Lokale Banner zuerst
        ranking_score DESC
    LIMIT p_limit;
END;
$$;

-- Funktion für Banner-Impression-Tracking
CREATE OR REPLACE FUNCTION track_banner_impression(
    p_ad_id UUID,
    p_user_id UUID,
    p_user_lat DOUBLE PRECISION,
    p_user_lon DOUBLE PRECISION,
    p_rotation_slot INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_distance_km DOUBLE PRECISION;
    v_ad_exists BOOLEAN;
BEGIN
    -- Prüfe ob Ad existiert und aktiv ist
    SELECT EXISTS(
        SELECT 1 FROM public.store_ads 
        WHERE id = p_ad_id 
          AND status = 'active' 
          AND is_active = true
    ) INTO v_ad_exists;
    
    IF NOT v_ad_exists THEN
        RETURN false;
    END IF;
    
    -- Berechne Distanz
    SELECT ST_Distance(
        center_geo,
        ST_SetSRID(ST_MakePoint(p_user_lon, p_user_lat), 4326)::GEOGRAPHY
    ) / 1000.0
    INTO v_distance_km
    FROM public.store_ads
    WHERE id = p_ad_id;
    
    -- Speichere Impression
    INSERT INTO public.store_ad_impressions (
        ad_id, user_id, user_lat, user_lon, distance_km, rotation_slot
    ) VALUES (
        p_ad_id, p_user_id, p_user_lat, p_user_lon, v_distance_km, p_rotation_slot
    );
    
    -- Erhöhe Impression-Counter
    UPDATE public.store_ads
    SET impressions_count = impressions_count + 1
    WHERE id = p_ad_id;
    
    RETURN true;
END;
$$;

-- Funktion für Banner-Click-Tracking
CREATE OR REPLACE FUNCTION track_banner_click(
    p_ad_id UUID,
    p_user_id UUID,
    p_user_lat DOUBLE PRECISION,
    p_user_lon DOUBLE PRECISION
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_distance_km DOUBLE PRECISION;
    v_ad_exists BOOLEAN;
BEGIN
    -- Prüfe ob Ad existiert und aktiv ist
    SELECT EXISTS(
        SELECT 1 FROM public.store_ads 
        WHERE id = p_ad_id 
          AND status = 'active' 
          AND is_active = true
    ) INTO v_ad_exists;
    
    IF NOT v_ad_exists THEN
        RETURN false;
    END IF;
    
    -- Berechne Distanz
    SELECT ST_Distance(
        center_geo,
        ST_SetSRID(ST_MakePoint(p_user_lon, p_user_lat), 4326)::GEOGRAPHY
    ) / 1000.0
    INTO v_distance_km
    FROM public.store_ads
    WHERE id = p_ad_id;
    
    -- Speichere Click
    INSERT INTO public.store_ad_clicks (
        ad_id, user_id, user_lat, user_lon, distance_km
    ) VALUES (
        p_ad_id, p_user_id, p_user_lat, p_user_lon, v_distance_km
    );
    
    -- Erhöhe Click-Counter
    UPDATE public.store_ads
    SET clicks_count = clicks_count + 1
    WHERE id = p_ad_id;
    
    RETURN true;
END;
$$;

-- Cron Job für monatlichen Reset (1. Tag um 00:10 Europe/Zurich)
SELECT cron.schedule(
    'reset-monthly-limits',
    '10 0 1 * *', -- Jeden 1. des Monats um 00:10
    'SELECT reset_monthly_limits();'
);

-- Row Level Security (RLS) Policies

-- Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Listings
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active listings" ON public.listings
    FOR SELECT USING (is_active = true);
CREATE POLICY "Users can create own listings" ON public.listings
    FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Users can update own listings" ON public.listings
    FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Users can delete own listings" ON public.listings
    FOR DELETE USING (auth.uid() = owner_id);

-- Likes
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view likes" ON public.likes
    FOR SELECT USING (true);
CREATE POLICY "Users can create own likes" ON public.likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON public.likes
    FOR DELETE USING (auth.uid() = user_id);

-- Matches
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own matches" ON public.matches
    FOR SELECT USING (auth.uid() = user_a_id OR auth.uid() = user_b_id);
CREATE POLICY "Users can create matches" ON public.matches
    FOR INSERT WITH CHECK (auth.uid() = user_a_id);
CREATE POLICY "Users can update own matches" ON public.matches
    FOR UPDATE USING (auth.uid() = user_a_id OR auth.uid() = user_b_id);

-- Communities
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view public communities" ON public.communities
    FOR SELECT USING (is_public = true);
CREATE POLICY "Users can view joined communities" ON public.communities
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.community_members
            WHERE community_id = id AND user_id = auth.uid()
        )
    );
CREATE POLICY "Users can create communities" ON public.communities
    FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Owners can update communities" ON public.communities
    FOR UPDATE USING (auth.uid() = owner_id);

-- Community members
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view community members" ON public.community_members
    FOR SELECT USING (true);
CREATE POLICY "Users can join communities" ON public.community_members
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can leave communities" ON public.community_members
    FOR DELETE USING (auth.uid() = user_id);

-- Community posts
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view posts in public communities" ON public.community_posts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = community_id AND c.is_public = true
        )
    );
CREATE POLICY "Members can view posts in joined communities" ON public.community_posts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.community_members cm
            WHERE cm.community_id = community_id AND cm.user_id = auth.uid()
        )
    );
CREATE POLICY "Users can create posts in joined communities" ON public.community_posts
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.community_members cm
            WHERE cm.community_id = community_id AND cm.user_id = auth.uid()
        )
    );
CREATE POLICY "Users can update own posts" ON public.community_posts
    FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own posts" ON public.community_posts
    FOR DELETE USING (auth.uid() = author_id);

-- Chats
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own chats" ON public.chats
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_participants
            WHERE chat_id = id AND user_id = auth.uid()
        )
    );
CREATE POLICY "Users can create chats" ON public.chats
    FOR INSERT WITH CHECK (true);

-- Chat participants
ALTER TABLE public.chat_participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view chat participants" ON public.chat_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_participants cp
            WHERE cp.chat_id = chat_id AND cp.user_id = auth.uid()
        )
    );
CREATE POLICY "Users can join chats" ON public.chat_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view messages in own chats" ON public.messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_participants
            WHERE chat_id = chat_id AND user_id = auth.uid()
        )
    );
CREATE POLICY "Users can send messages in own chats" ON public.messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.chat_participants
            WHERE chat_id = chat_id AND user_id = auth.uid()
        )
    );

-- Stores
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active stores" ON public.stores
    FOR SELECT USING (is_active = true);
CREATE POLICY "Users can create stores" ON public.stores
    FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Owners can update stores" ON public.stores
    FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Owners can delete stores" ON public.stores
    FOR DELETE USING (auth.uid() = owner_id);

-- Banners
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active banners" ON public.banners
    FOR SELECT USING (is_active = true);

-- Subscriptions
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own subscriptions" ON public.subscriptions
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create subscriptions" ON public.subscriptions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Donations
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own donations" ON public.donations
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create donations" ON public.donations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Payments
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own payments" ON public.payments
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create payments" ON public.payments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usage Quota
ALTER TABLE public.usage_quota ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own quota" ON public.usage_quota
    FOR SELECT USING (auth.uid() = user_id);
-- Keine direkten INSERT/UPDATE/DELETE erlaubt - nur über RPCs

-- Store Ads
ALTER TABLE public.store_ads ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active store ads" ON public.store_ads
    FOR SELECT USING (is_active = true AND status = 'active');
CREATE POLICY "Store owners can create ads" ON public.store_ads
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.stores
            WHERE id = store_id AND owner_id = auth.uid()
        )
    );
CREATE POLICY "Store owners can update own ads" ON public.store_ads
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.stores
            WHERE id = store_id AND owner_id = auth.uid()
        )
    );
CREATE POLICY "Store owners can delete own ads" ON public.store_ads
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.stores
            WHERE id = store_id AND owner_id = auth.uid()
        )
    );

-- Store Ad Impressions
ALTER TABLE public.store_ad_impressions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own impressions" ON public.store_ad_impressions
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create impressions" ON public.store_ad_impressions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Store Ad Clicks
ALTER TABLE public.store_ad_clicks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own clicks" ON public.store_ad_clicks
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create clicks" ON public.store_ad_clicks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Triggers für automatische Updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_listings_updated_at BEFORE UPDATE ON public.listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON public.matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_communities_updated_at BEFORE UPDATE ON public.communities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_community_posts_updated_at BEFORE UPDATE ON public.community_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_community_post_comments_updated_at BEFORE UPDATE ON public.community_post_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON public.stores FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_banners_updated_at BEFORE UPDATE ON public.banners FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_usage_quota_updated_at BEFORE UPDATE ON public.usage_quota FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_store_ads_updated_at BEFORE UPDATE ON public.store_ads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Initial data für Banners (nur im Development)
DO $$
BEGIN
    IF current_setting('app.environment', true) = 'development' THEN
        INSERT INTO public.banners (title, description, image_url, link_url, priority) VALUES
        ('Willkommen bei Swap&Shop', 'Entdecke tolle Artikel in deiner Nähe', 'https://via.placeholder.com/400x200/FF5722/FFFFFF?text=Welcome', null, 1),
        ('Premium werden', 'Unbegrenzte Möglichkeiten mit Premium', 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Premium', null, 2),
        ('Community beitreten', 'Verbinde dich mit Gleichgesinnten', 'https://via.placeholder.com/400x200/2196F3/FFFFFF?text=Community', null, 3)
        ON CONFLICT DO NOTHING;
    END IF;
END $$; 