-- =====================================================
-- SWAP&SHOP STORAGE BUCKETS SETUP
-- =====================================================
-- Erstellt für Supabase: https://nqxgsuxyvhjveigbjyxb.supabase.co
-- Datum: $(date)
-- =====================================================

-- =====================================================
-- 1. CREATE STORAGE BUCKETS
-- =====================================================

-- Create buckets for different types of images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']), -- 5MB limit
    ('listing-images', 'listing-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']), -- 10MB limit
    ('store-logos', 'store-logos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']), -- 5MB limit
    ('store-banners', 'store-banners', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']), -- 10MB limit
    ('community-images', 'community-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']), -- 10MB limit
    ('chat-images', 'chat-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']); -- 10MB limit

-- =====================================================
-- 2. STORAGE POLICIES FOR AVATARS BUCKET
-- =====================================================

-- Everyone can view avatars
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

-- Users can upload their own avatar
CREATE POLICY "Users can upload own avatar" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can update their own avatar
CREATE POLICY "Users can update own avatar" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can delete their own avatar
CREATE POLICY "Users can delete own avatar" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- =====================================================
-- 3. STORAGE POLICIES FOR LISTING IMAGES BUCKET
-- =====================================================

-- Everyone can view listing images
CREATE POLICY "Listing images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'listing-images');

-- Users can upload images for their own listings
CREATE POLICY "Users can upload listing images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'listing-images' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.listings 
            WHERE id::text = (storage.foldername(name))[2] 
            AND user_id = auth.uid()
        )
    );

-- Users can update images for their own listings
CREATE POLICY "Users can update listing images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'listing-images' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.listings 
            WHERE id::text = (storage.foldername(name))[2] 
            AND user_id = auth.uid()
        )
    );

-- Users can delete images for their own listings
CREATE POLICY "Users can delete listing images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'listing-images' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.listings 
            WHERE id::text = (storage.foldername(name))[2] 
            AND user_id = auth.uid()
        )
    );

-- =====================================================
-- 4. STORAGE POLICIES FOR STORE LOGOS BUCKET
-- =====================================================

-- Everyone can view store logos
CREATE POLICY "Store logos are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'store-logos');

-- Store owners can upload their store logo
CREATE POLICY "Store owners can upload store logos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'store-logos' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id::text = (storage.foldername(name))[2] 
            AND owner_id = auth.uid()
        )
    );

-- Store owners can update their store logo
CREATE POLICY "Store owners can update store logos" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'store-logos' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id::text = (storage.foldername(name))[2] 
            AND owner_id = auth.uid()
        )
    );

-- Store owners can delete their store logo
CREATE POLICY "Store owners can delete store logos" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'store-logos' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id::text = (storage.foldername(name))[2] 
            AND owner_id = auth.uid()
        )
    );

-- =====================================================
-- 5. STORAGE POLICIES FOR STORE BANNERS BUCKET
-- =====================================================

-- Everyone can view store banners
CREATE POLICY "Store banners are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'store-banners');

-- Store owners can upload store banners
CREATE POLICY "Store owners can upload store banners" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'store-banners' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id::text = (storage.foldername(name))[2] 
            AND owner_id = auth.uid()
        )
    );

-- Store owners can update store banners
CREATE POLICY "Store owners can update store banners" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'store-banners' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id::text = (storage.foldername(name))[2] 
            AND owner_id = auth.uid()
        )
    );

-- Store owners can delete store banners
CREATE POLICY "Store owners can delete store banners" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'store-banners' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.stores 
            WHERE id::text = (storage.foldername(name))[2] 
            AND owner_id = auth.uid()
        )
    );

-- =====================================================
-- 6. STORAGE POLICIES FOR COMMUNITY IMAGES BUCKET
-- =====================================================

-- Everyone can view community images
CREATE POLICY "Community images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'community-images');

-- Community members can upload community images
CREATE POLICY "Community members can upload community images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'community-images' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.community_members 
            WHERE community_id::text = (storage.foldername(name))[2] 
            AND user_id = auth.uid()
        )
    );

-- Community members can update community images
CREATE POLICY "Community members can update community images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'community-images' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.community_members 
            WHERE community_id::text = (storage.foldername(name))[2] 
            AND user_id = auth.uid()
        )
    );

-- Community members can delete community images
CREATE POLICY "Community members can delete community images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'community-images' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        EXISTS (
            SELECT 1 FROM public.community_members 
            WHERE community_id::text = (storage.foldername(name))[2] 
            AND user_id = auth.uid()
        )
    );

-- =====================================================
-- 7. STORAGE POLICIES FOR CHAT IMAGES BUCKET
-- =====================================================

-- Chat participants can view chat images
CREATE POLICY "Chat participants can view chat images" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'chat-images' AND
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE id::text = (storage.foldername(name))[1] 
            AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

-- Chat participants can upload chat images
CREATE POLICY "Chat participants can upload chat images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'chat-images' AND
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE id::text = (storage.foldername(name))[1] 
            AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

-- Chat participants can update chat images
CREATE POLICY "Chat participants can update chat images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'chat-images' AND
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE id::text = (storage.foldername(name))[1] 
            AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

-- Chat participants can delete chat images
CREATE POLICY "Chat participants can delete chat images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'chat-images' AND
        EXISTS (
            SELECT 1 FROM public.chats 
            WHERE id::text = (storage.foldername(name))[1] 
            AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

-- =====================================================
-- 8. HELPER FUNCTIONS FOR STORAGE
-- =====================================================

-- Function to get public URL for storage objects
CREATE OR REPLACE FUNCTION get_public_url(bucket_name TEXT, file_path TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN CONCAT('https://nqxgsuxyvhjveigbjyxb.supabase.co/storage/v1/object/public/', bucket_name, '/', file_path);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate unique file names
CREATE OR REPLACE FUNCTION generate_unique_filename(original_name TEXT, user_id UUID)
RETURNS TEXT AS $$
DECLARE
    file_extension TEXT;
    timestamp_str TEXT;
    random_str TEXT;
BEGIN
    -- Extract file extension
    file_extension := COALESCE(
        CASE 
            WHEN position('.' in original_name) > 0 
            THEN substring(original_name from position('.' in original_name))
            ELSE ''
        END, 
        '.jpg'
    );
    
    -- Generate timestamp and random string
    timestamp_str := to_char(now(), 'YYYYMMDDHH24MISS');
    random_str := substring(md5(random()::text) from 1 for 8);
    
    -- Return unique filename
    RETURN user_id::text || '_' || timestamp_str || '_' || random_str || file_extension;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 9. STORAGE TRIGGERS
-- =====================================================

-- Function to update profile avatar_url when avatar is uploaded
CREATE OR REPLACE FUNCTION update_profile_avatar_url()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if it's an avatar upload
    IF NEW.bucket_id = 'avatars' THEN
        UPDATE public.profiles 
        SET avatar_url = get_public_url('avatars', NEW.name)
        WHERE id::text = (storage.foldername(NEW.name))[1];
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for avatar uploads
CREATE TRIGGER on_avatar_upload
    AFTER INSERT ON storage.objects
    FOR EACH ROW
    EXECUTE FUNCTION update_profile_avatar_url();

-- =====================================================
-- 10. STORAGE CLEANUP FUNCTIONS
-- =====================================================

-- Function to clean up orphaned storage objects
CREATE OR REPLACE FUNCTION cleanup_orphaned_storage_objects()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER := 0;
BEGIN
    -- Clean up orphaned listing images
    DELETE FROM storage.objects 
    WHERE bucket_id = 'listing-images' 
    AND NOT EXISTS (
        SELECT 1 FROM public.listing_images 
        WHERE image_url LIKE '%' || name
    );
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Clean up orphaned store logos
    DELETE FROM storage.objects 
    WHERE bucket_id = 'store-logos' 
    AND NOT EXISTS (
        SELECT 1 FROM public.stores 
        WHERE logo_url LIKE '%' || name
    );
    
    GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;
    
    -- Clean up orphaned store banners
    DELETE FROM storage.objects 
    WHERE bucket_id = 'store-banners' 
    AND NOT EXISTS (
        SELECT 1 FROM public.store_banners 
        WHERE image_url LIKE '%' || name
    );
    
    GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- STORAGE SETUP COMPLETED
-- =====================================================
-- Next steps:
-- 1. Run this SQL in Supabase Dashboard > SQL Editor
-- 2. Test file uploads with different user roles
-- 3. Verify storage policies work correctly
-- 4. Test with app integration
-- =====================================================

-- =====================================================
-- STORAGE BUCKET STRUCTURE:
-- =====================================================
-- avatars/
--   └── {user_id}/
--       └── {filename}
--
-- listing-images/
--   └── {user_id}/
--       └── {listing_id}/
--           └── {filename}
--
-- store-logos/
--   └── {user_id}/
--       └── {store_id}/
--           └── {filename}
--
-- store-banners/
--   └── {user_id}/
--       └── {store_id}/
--           └── {filename}
--
-- community-images/
--   └── {user_id}/
--       └── {community_id}/
--           └── {filename}
--
-- chat-images/
--   └── {chat_id}/
--       └── {filename}
-- =====================================================
