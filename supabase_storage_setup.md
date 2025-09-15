# Supabase Storage Buckets Setup

## Storage Buckets erstellen

Gehe zu: https://nqxgsuxyvhjveigbjyxb.supabase.co/project/default/storage/buckets

### 1. "images" Bucket erstellen
- **Name**: `images`
- **Public**: ✅ Ja (für öffentliche Bilder)
- **File size limit**: 10 MB
- **Allowed MIME types**: image/*

### 2. "avatars" Bucket erstellen  
- **Name**: `avatars`
- **Public**: ✅ Ja (für Profilbilder)
- **File size limit**: 5 MB
- **Allowed MIME types**: image/*

### 3. Storage Policies

Für beide Buckets folgende Policies erstellen:

#### Für "images" Bucket:
```sql
-- Anyone can view images
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'images');

-- Authenticated users can upload images
CREATE POLICY "Authenticated users can upload images" ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'images' AND auth.role() = 'authenticated');

-- Users can update their own images
CREATE POLICY "Users can update own images" ON storage.objects FOR UPDATE 
USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users can delete their own images
CREATE POLICY "Users can delete own images" ON storage.objects FOR DELETE 
USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);
```

#### Für "avatars" Bucket:
```sql
-- Anyone can view avatars
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

-- Authenticated users can upload avatars
CREATE POLICY "Authenticated users can upload avatars" ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

-- Users can update their own avatars
CREATE POLICY "Users can update own avatars" ON storage.objects FOR UPDATE 
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users can delete their own avatars
CREATE POLICY "Users can delete own avatars" ON storage.objects FOR DELETE 
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
``` 