-- =====================================================
-- SWAP&SHOP COMPLETE DATABASE SCHEMA
-- =====================================================
-- Erstellt für Supabase: https://nqxgsuxyvhjveigbjyxb.supabase.co
-- Datum: $(date)
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- =====================================================
-- 1. CORE USER MANAGEMENT
-- =====================================================

-- Users/Profiles Table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    radius_km INTEGER DEFAULT 25,
    language TEXT DEFAULT 'de',
    is_premium BOOLEAN DEFAULT FALSE,
    premium_expires_at TIMESTAMP WITH TIME ZONE,
    swap_credits INTEGER DEFAULT 5,
    sell_credits INTEGER DEFAULT 3,
    giveaway_credits INTEGER DEFAULT 10,
    addon_swap_credits INTEGER DEFAULT 0,
    addon_sell_credits INTEGER DEFAULT 0,
    total_donations DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. LISTINGS & ITEMS
-- =====================================================

-- Categories Table
CREATE TABLE public.categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    name_de TEXT,
    name_en TEXT,
    name_fr TEXT,
    name_it TEXT,
    name_pt TEXT,
    icon TEXT,
    color TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Listings Table (Swap, Giveaway, Sell)
CREATE TABLE public.listings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES public.categories(id),
    title TEXT NOT NULL,
    description TEXT,
    condition TEXT CHECK (condition IN ('new', 'like_new', 'good', 'fair', 'poor')),
    listing_type TEXT CHECK (listing_type IN ('swap', 'giveaway', 'sell')) NOT NULL,
    price DECIMAL(10,2), -- NULL for swap/giveaway
    currency TEXT DEFAULT 'CHF',
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_anonymous BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE -- NULL = no expiration
);

-- Listing Images Table
CREATE TABLE public.listing_images (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    image_order INTEGER DEFAULT 0,
    alt_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Listing Tags Table
CREATE TABLE public.listing_tags (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    tag TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(listing_id, tag)
);

-- =====================================================
-- 3. MATCHES & LIKES
-- =====================================================

-- Likes Table
CREATE TABLE public.likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    is_like BOOLEAN NOT NULL, -- TRUE = like, FALSE = dislike
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, listing_id)
);

-- Matches Table (when both users like each other's listings)
CREATE TABLE public.matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user1_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    user2_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    listing1_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    listing2_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    status TEXT CHECK (status IN ('active', 'completed', 'cancelled')) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user1_id, user2_id, listing1_id, listing2_id)
);

-- =====================================================
-- 4. CHAT SYSTEM
-- =====================================================

-- Chats Table
CREATE TABLE public.chats (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    user1_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    user2_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat Messages Table
CREATE TABLE public.messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    chat_id UUID REFERENCES public.chats(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    message_type TEXT CHECK (message_type IN ('text', 'image', 'system')) DEFAULT 'text',
    image_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 5. COMMUNITIES
-- =====================================================

-- Communities Table
CREATE TABLE public.communities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    radius_km INTEGER DEFAULT 10,
    is_public BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    member_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community Members Table
CREATE TABLE public.community_members (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    role TEXT CHECK (role IN ('member', 'moderator', 'admin')) DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(community_id, user_id)
);

-- Community Posts Table
CREATE TABLE public.community_posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    post_type TEXT CHECK (post_type IN ('text', 'image', 'listing', 'event')) DEFAULT 'text',
    image_url TEXT,
    is_pinned BOOLEAN DEFAULT FALSE,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community Post Likes Table
CREATE TABLE public.community_post_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Community Post Comments Table
CREATE TABLE public.community_post_comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES public.community_post_comments(id) ON DELETE CASCADE,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 6. STORES & MONETIZATION
-- =====================================================

-- Stores Table
CREATE TABLE public.stores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    store_type TEXT CHECK (store_type IN ('private_flea_market', 'small_store', 'professional_store')) NOT NULL,
    logo_url TEXT,
    banner_url TEXT,
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    radius_km INTEGER DEFAULT 25,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    subscription_type TEXT CHECK (subscription_type IN ('free', 'small', 'professional')) DEFAULT 'free',
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Store Listings Table (listings that belong to stores)
CREATE TABLE public.store_listings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE NOT NULL,
    listing_id UUID REFERENCES public.listings(id) ON DELETE CASCADE NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(store_id, listing_id)
);

-- Store Banners Table
CREATE TABLE public.store_banners (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    link_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    view_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. JOBS & SERVICES
-- =====================================================

-- Jobs Table
CREATE TABLE public.jobs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    job_type TEXT CHECK (job_type IN ('full_time', 'part_time', 'contract', 'freelance', 'volunteer')) NOT NULL,
    category TEXT,
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    salary_min DECIMAL(10,2),
    salary_max DECIMAL(10,2),
    currency TEXT DEFAULT 'CHF',
    is_remote BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    application_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Job Applications Table
CREATE TABLE public.job_applications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE NOT NULL,
    applicant_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    cover_letter TEXT,
    status TEXT CHECK (status IN ('pending', 'reviewed', 'accepted', 'rejected')) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, applicant_id)
);

-- =====================================================
-- 8. PAYMENTS & SUBSCRIPTIONS
-- =====================================================

-- Subscriptions Table
CREATE TABLE public.subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    subscription_type TEXT CHECK (subscription_type IN ('monthly', 'yearly')) NOT NULL,
    status TEXT CHECK (status IN ('active', 'cancelled', 'expired', 'pending')) DEFAULT 'pending',
    stripe_subscription_id TEXT,
    stripe_customer_id TEXT,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'CHF',
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Donations Table
CREATE TABLE public.donations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'CHF',
    stripe_payment_intent_id TEXT,
    status TEXT CHECK (status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
    donation_type TEXT CHECK (donation_type IN ('swap_bonus', 'sell_bonus', 'general')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Credits Table (for tracking add-on purchases)
CREATE TABLE public.user_credits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    credit_type TEXT CHECK (credit_type IN ('swap', 'sell', 'giveaway')) NOT NULL,
    amount INTEGER NOT NULL,
    source TEXT CHECK (source IN ('monthly_reset', 'addon_purchase', 'admin_grant')) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 9. INDEXES FOR PERFORMANCE
-- =====================================================

-- Profiles indexes
CREATE INDEX idx_profiles_location ON public.profiles USING GIST (ll_to_earth(latitude, longitude));
CREATE INDEX idx_profiles_premium ON public.profiles (is_premium, premium_expires_at);
CREATE INDEX idx_profiles_active ON public.profiles (last_active_at);

-- Listings indexes
CREATE INDEX idx_listings_location ON public.listings USING GIST (ll_to_earth(latitude, longitude));
CREATE INDEX idx_listings_user ON public.listings (user_id);
CREATE INDEX idx_listings_type ON public.listings (listing_type);
CREATE INDEX idx_listings_active ON public.listings (is_active, created_at);
CREATE INDEX idx_listings_category ON public.listings (category_id);

-- Likes indexes
CREATE INDEX idx_likes_user ON public.likes (user_id);
CREATE INDEX idx_likes_listing ON public.likes (listing_id);
CREATE INDEX idx_likes_created ON public.likes (created_at);

-- Matches indexes
CREATE INDEX idx_matches_user1 ON public.matches (user1_id);
CREATE INDEX idx_matches_user2 ON public.matches (user2_id);
CREATE INDEX idx_matches_status ON public.matches (status);

-- Chats indexes
CREATE INDEX idx_chats_users ON public.chats (user1_id, user2_id);
CREATE INDEX idx_chats_last_message ON public.chats (last_message_at);

-- Messages indexes
CREATE INDEX idx_messages_chat ON public.messages (chat_id);
CREATE INDEX idx_messages_created ON public.messages (created_at);

-- Communities indexes
CREATE INDEX idx_communities_location ON public.communities USING GIST (ll_to_earth(latitude, longitude));
CREATE INDEX idx_communities_public ON public.communities (is_public, is_active);

-- Stores indexes
CREATE INDEX idx_stores_owner ON public.stores (owner_id);
CREATE INDEX idx_stores_location ON public.stores USING GIST (ll_to_earth(latitude, longitude));
CREATE INDEX idx_stores_active ON public.stores (is_active, subscription_type);

-- Jobs indexes
CREATE INDEX idx_jobs_location ON public.jobs USING GIST (ll_to_earth(latitude, longitude));
CREATE INDEX idx_jobs_active ON public.jobs (is_active, created_at);
CREATE INDEX idx_jobs_type ON public.jobs (job_type);

-- =====================================================
-- 10. TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_listings_updated_at BEFORE UPDATE ON public.listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON public.matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_communities_updated_at BEFORE UPDATE ON public.communities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_community_posts_updated_at BEFORE UPDATE ON public.community_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_community_post_comments_updated_at BEFORE UPDATE ON public.community_post_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON public.stores FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_job_applications_updated_at BEFORE UPDATE ON public.job_applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 11. SAMPLE DATA
-- =====================================================

-- Insert default categories
INSERT INTO public.categories (name, name_de, name_en, name_fr, name_it, name_pt, icon, color, sort_order) VALUES
('electronics', 'Elektronik', 'Electronics', 'Électronique', 'Elettronica', 'Eletrônicos', 'phone_android', '#2196F3', 1),
('clothing', 'Kleidung', 'Clothing', 'Vêtements', 'Abbigliamento', 'Roupas', 'checkroom', '#E91E63', 2),
('books', 'Bücher', 'Books', 'Livres', 'Libri', 'Livros', 'menu_book', '#4CAF50', 3),
('furniture', 'Möbel', 'Furniture', 'Meubles', 'Mobili', 'Móveis', 'chair', '#FF9800', 4),
('sports', 'Sport', 'Sports', 'Sport', 'Sport', 'Esportes', 'sports_soccer', '#9C27B0', 5),
('toys', 'Spielzeug', 'Toys', 'Jouets', 'Giocattoli', 'Brinquedos', 'toys', '#FF5722', 6),
('beauty', 'Schönheit', 'Beauty', 'Beauté', 'Bellezza', 'Beleza', 'face', '#E91E63', 7),
('home', 'Haushalt', 'Home', 'Maison', 'Casa', 'Casa', 'home', '#607D8B', 8),
('garden', 'Garten', 'Garden', 'Jardin', 'Giardino', 'Jardim', 'yard', '#4CAF50', 9),
('automotive', 'Auto & Motorrad', 'Automotive', 'Automobile', 'Automotive', 'Automotivo', 'directions_car', '#795548', 10),
('music', 'Musik', 'Music', 'Musique', 'Musica', 'Música', 'music_note', '#3F51B5', 11),
('art', 'Kunst', 'Art', 'Art', 'Arte', 'Arte', 'palette', '#FF9800', 12),
('collectibles', 'Sammlerstücke', 'Collectibles', 'Objets de collection', 'Collezionismo', 'Colecionáveis', 'star', '#FFD700', 13),
('jewelry', 'Schmuck', 'Jewelry', 'Bijoux', 'Gioielli', 'Joias', 'diamond', '#FFD700', 14),
('watches', 'Uhren', 'Watches', 'Montres', 'Orologi', 'Relógios', 'watch', '#607D8B', 15),
('bags', 'Taschen', 'Bags', 'Sacs', 'Borse', 'Bolsas', 'shopping_bag', '#795548', 16),
('shoes', 'Schuhe', 'Shoes', 'Chaussures', 'Scarpe', 'Sapatos', 'directions_walk', '#795548', 17),
('accessories', 'Accessoires', 'Accessories', 'Accessoires', 'Accessori', 'Acessórios', 'style', '#9E9E9E', 18),
('health', 'Gesundheit', 'Health', 'Santé', 'Salute', 'Saúde', 'health_and_safety', '#4CAF50', 19),
('baby', 'Baby', 'Baby', 'Bébé', 'Bambino', 'Bebê', 'child_care', '#FF9800', 20),
('kids', 'Kinder', 'Kids', 'Enfants', 'Bambini', 'Crianças', 'child_friendly', '#FF9800', 21),
('pets', 'Haustiere', 'Pets', 'Animaux', 'Animali', 'Animais', 'pets', '#4CAF50', 22),
('office', 'Büro', 'Office', 'Bureau', 'Ufficio', 'Escritório', 'business', '#607D8B', 23),
('tools', 'Werkzeug', 'Tools', 'Outils', 'Strumenti', 'Ferramentas', 'build', '#795548', 24),
('miscellaneous', 'Sonstiges', 'Miscellaneous', 'Divers', 'Varie', 'Diversos', 'more_horiz', '#9E9E9E', 25);

-- =====================================================
-- SCHEMA COMPLETED
-- =====================================================
-- Next steps:
-- 1. Run this SQL in Supabase Dashboard > SQL Editor
-- 2. Configure RLS policies (see rls_policies.sql)
-- 3. Set up Storage buckets (see storage_setup.sql)
-- 4. Test with app integration
-- =====================================================
