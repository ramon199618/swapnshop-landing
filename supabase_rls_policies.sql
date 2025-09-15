-- =====================================================
-- SWAP&SHOP RLS (ROW LEVEL SECURITY) POLICIES
-- =====================================================
-- Erstellt für Supabase: https://nqxgsuxyvhjveigbjyxb.supabase.co
-- Datum: $(date)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_credits ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 1. PROFILES POLICIES
-- =====================================================

-- Users can view all profiles (for discovery)
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles
    FOR SELECT USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- 2. CATEGORIES POLICIES
-- =====================================================

-- Categories are public (read-only for users)
CREATE POLICY "Categories are viewable by everyone" ON public.categories
    FOR SELECT USING (true);

-- Only admins can modify categories (implement admin check later)
CREATE POLICY "Only admins can modify categories" ON public.categories
    FOR ALL USING (false); -- TODO: Add admin role check

-- =====================================================
-- 3. LISTINGS POLICIES
-- =====================================================

-- Everyone can view active listings
CREATE POLICY "Active listings are viewable by everyone" ON public.listings
    FOR SELECT USING (is_active = true);

-- Users can view their own listings (even inactive)
CREATE POLICY "Users can view own listings" ON public.listings
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own listings
CREATE POLICY "Users can insert own listings" ON public.listings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own listings
CREATE POLICY "Users can update own listings" ON public.listings
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own listings
CREATE POLICY "Users can delete own listings" ON public.listings
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 4. LISTING IMAGES POLICIES
-- =====================================================

-- Everyone can view images of active listings
CREATE POLICY "Listing images are viewable by everyone" ON public.listing_images
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.listings 
            WHERE id = listing_id AND is_active = true
        )
    );

-- Users can manage images of their own listings
CREATE POLICY "Users can manage own listing images" ON public.listing_images
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.listings 
            WHERE id = listing_id AND user_id = auth.uid()
        )
    );

-- =====================================================
-- 5. LISTING TAGS POLICIES
-- =====================================================

-- Everyone can view tags of active listings
CREATE POLICY "Listing tags are viewable by everyone" ON public.listing_tags
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.listings 
            WHERE id = listing_id AND is_active = true
        )
    );

-- Users can manage tags of their own listings
CREATE POLICY "Users can manage own listing tags" ON public.listing_tags
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.listings 
            WHERE id = listing_id AND user_id = auth.uid()
        )
    );

-- =====================================================
-- 6. LIKES POLICIES
-- =====================================================

-- Users can view their own likes
CREATE POLICY "Users can view own likes" ON public.likes
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own likes
CREATE POLICY "Users can insert own likes" ON public.likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own likes
CREATE POLICY "Users can update own likes" ON public.likes
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own likes
CREATE POLICY "Users can delete own likes" ON public.likes
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 7. MATCHES POLICIES
-- =====================================================

-- Users can view matches they are part of
CREATE POLICY "Users can view own matches" ON public.matches
    FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Users can insert matches (system-generated)
CREATE POLICY "Users can insert matches" ON public.matches
    FOR INSERT WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Users can update matches they are part of
CREATE POLICY "Users can update own matches" ON public.matches
    FOR UPDATE USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- =====================================================
-- 8. CHATS POLICIES
-- =====================================================

-- Users can view chats they are part of
CREATE POLICY "Users can view own chats" ON public.chats
    FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Users can insert chats (system-generated)
CREATE POLICY "Users can insert chats" ON public.chats
    FOR INSERT WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Users can update chats they are part of
CREATE POLICY "Users can update own chats" ON public.chats
    FOR UPDATE USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- =====================================================
-- 9. MESSAGES POLICIES
-- =====================================================

-- Users can view messages in chats they are part of
CREATE POLICY "Users can view messages in own chats" ON public.messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE id = chat_id AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

-- Users can insert messages in chats they are part of
CREATE POLICY "Users can insert messages in own chats" ON public.messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE id = chat_id AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

-- Users can update their own messages
CREATE POLICY "Users can update own messages" ON public.messages
    FOR UPDATE USING (auth.uid() = sender_id);

-- =====================================================
-- 10. COMMUNITIES POLICIES
-- =====================================================

-- Everyone can view public communities
CREATE POLICY "Public communities are viewable by everyone" ON public.communities
    FOR SELECT USING (is_public = true AND is_active = true);

-- Users can view communities they are members of
CREATE POLICY "Users can view communities they are members of" ON public.communities
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.community_members 
            WHERE community_id = id AND user_id = auth.uid()
        )
    );

-- Users can insert communities
CREATE POLICY "Users can insert communities" ON public.communities
    FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Users can update communities they created
CREATE POLICY "Users can update communities they created" ON public.communities
    FOR UPDATE USING (auth.uid() = created_by);

-- =====================================================
-- 11. COMMUNITY MEMBERS POLICIES
-- =====================================================

-- Users can view members of communities they are part of
CREATE POLICY "Users can view community members" ON public.community_members
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.community_members cm2
            WHERE cm2.community_id = community_id AND cm2.user_id = auth.uid()
        )
    );

-- Users can join communities
CREATE POLICY "Users can join communities" ON public.community_members
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can leave communities
CREATE POLICY "Users can leave communities" ON public.community_members
    FOR DELETE USING (auth.uid() = user_id);

-- Community creators can manage members
CREATE POLICY "Community creators can manage members" ON public.community_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.communities 
            WHERE id = community_id AND created_by = auth.uid()
        )
    );

-- =====================================================
-- 12. COMMUNITY POSTS POLICIES
-- =====================================================

-- Users can view posts in communities they are members of
CREATE POLICY "Users can view community posts" ON public.community_posts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.community_members 
            WHERE community_id = community_id AND user_id = auth.uid()
        )
    );

-- Users can insert posts in communities they are members of
CREATE POLICY "Users can insert community posts" ON public.community_posts
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.community_members 
            WHERE community_id = community_id AND user_id = auth.uid()
        )
    );

-- Users can update their own posts
CREATE POLICY "Users can update own community posts" ON public.community_posts
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete own community posts" ON public.community_posts
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 13. COMMUNITY POST LIKES POLICIES
-- =====================================================

-- Users can view likes on posts in communities they are members of
CREATE POLICY "Users can view community post likes" ON public.community_post_likes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.community_posts cp
            JOIN public.community_members cm ON cp.community_id = cm.community_id
            WHERE cp.id = post_id AND cm.user_id = auth.uid()
        )
    );

-- Users can like posts in communities they are members of
CREATE POLICY "Users can like community posts" ON public.community_post_likes
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.community_posts cp
            JOIN public.community_members cm ON cp.community_id = cm.community_id
            WHERE cp.id = post_id AND cm.user_id = auth.uid()
        )
    );

-- Users can unlike posts
CREATE POLICY "Users can unlike community posts" ON public.community_post_likes
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 14. COMMUNITY POST COMMENTS POLICIES
-- =====================================================

-- Users can view comments on posts in communities they are members of
CREATE POLICY "Users can view community post comments" ON public.community_post_comments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.community_posts cp
            JOIN public.community_members cm ON cp.community_id = cm.community_id
            WHERE cp.id = post_id AND cm.user_id = auth.uid()
        )
    );

-- Users can comment on posts in communities they are members of
CREATE POLICY "Users can comment on community posts" ON public.community_post_comments
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.community_posts cp
            JOIN public.community_members cm ON cp.community_id = cm.community_id
            WHERE cp.id = post_id AND cm.user_id = auth.uid()
        )
    );

-- Users can update their own comments
CREATE POLICY "Users can update own community post comments" ON public.community_post_comments
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own comments
CREATE POLICY "Users can delete own community post comments" ON public.community_post_comments
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 15. STORES POLICIES
-- =====================================================

-- Everyone can view active stores
CREATE POLICY "Active stores are viewable by everyone" ON public.stores
    FOR SELECT USING (is_active = true);

-- Users can view their own stores
CREATE POLICY "Users can view own stores" ON public.stores
    FOR SELECT USING (auth.uid() = owner_id);

-- Users can insert their own stores
CREATE POLICY "Users can insert own stores" ON public.stores
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

-- Users can update their own stores
CREATE POLICY "Users can update own stores" ON public.stores
    FOR UPDATE USING (auth.uid() = owner_id);

-- Users can delete their own stores
CREATE POLICY "Users can delete own stores" ON public.stores
    FOR DELETE USING (auth.uid() = owner_id);

-- =====================================================
-- 16. STORE LISTINGS POLICIES
-- =====================================================

-- Everyone can view store listings of active stores
CREATE POLICY "Store listings are viewable by everyone" ON public.store_listings
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id = store_id AND is_active = true
        )
    );

-- Store owners can manage their store listings
CREATE POLICY "Store owners can manage store listings" ON public.store_listings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id = store_id AND owner_id = auth.uid()
        )
    );

-- =====================================================
-- 17. STORE BANNERS POLICIES
-- =====================================================

-- Everyone can view active store banners
CREATE POLICY "Active store banners are viewable by everyone" ON public.store_banners
    FOR SELECT USING (is_active = true);

-- Store owners can manage their store banners
CREATE POLICY "Store owners can manage store banners" ON public.store_banners
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id = store_id AND owner_id = auth.uid()
        )
    );

-- =====================================================
-- 18. JOBS POLICIES
-- =====================================================

-- Everyone can view active jobs
CREATE POLICY "Active jobs are viewable by everyone" ON public.jobs
    FOR SELECT USING (is_active = true);

-- Users can view their own jobs
CREATE POLICY "Users can view own jobs" ON public.jobs
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own jobs
CREATE POLICY "Users can insert own jobs" ON public.jobs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own jobs
CREATE POLICY "Users can update own jobs" ON public.jobs
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own jobs
CREATE POLICY "Users can delete own jobs" ON public.jobs
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 19. JOB APPLICATIONS POLICIES
-- =====================================================

-- Users can view their own job applications
CREATE POLICY "Users can view own job applications" ON public.job_applications
    FOR SELECT USING (auth.uid() = applicant_id);

-- Job posters can view applications to their jobs
CREATE POLICY "Job posters can view applications" ON public.job_applications
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.jobs 
            WHERE id = job_id AND user_id = auth.uid()
        )
    );

-- Users can apply to jobs
CREATE POLICY "Users can apply to jobs" ON public.job_applications
    FOR INSERT WITH CHECK (auth.uid() = applicant_id);

-- Job posters can update application status
CREATE POLICY "Job posters can update application status" ON public.job_applications
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.jobs 
            WHERE id = job_id AND user_id = auth.uid()
        )
    );

-- =====================================================
-- 20. SUBSCRIPTIONS POLICIES
-- =====================================================

-- Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions" ON public.subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own subscriptions
CREATE POLICY "Users can insert own subscriptions" ON public.subscriptions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own subscriptions
CREATE POLICY "Users can update own subscriptions" ON public.subscriptions
    FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- 21. DONATIONS POLICIES
-- =====================================================

-- Users can view their own donations
CREATE POLICY "Users can view own donations" ON public.donations
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own donations
CREATE POLICY "Users can insert own donations" ON public.donations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- 22. USER CREDITS POLICIES
-- =====================================================

-- Users can view their own credits
CREATE POLICY "Users can view own credits" ON public.user_credits
    FOR SELECT USING (auth.uid() = user_id);

-- System can insert credits (implement service role later)
CREATE POLICY "System can insert credits" ON public.user_credits
    FOR INSERT WITH CHECK (true); -- TODO: Add service role check

-- =====================================================
-- RLS POLICIES COMPLETED
-- =====================================================
-- Next steps:
-- 1. Run this SQL in Supabase Dashboard > SQL Editor
-- 2. Test policies with different user roles
-- 3. Set up Storage buckets (see storage_setup.sql)
-- 4. Test with app integration
-- =====================================================
