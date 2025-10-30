import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseStorageService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Upload image to storage
  static Future<String?> uploadImage({
    required File imageFile,
    required String bucket,
    String? path,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final filePath = path != null ? '$path/$fileName' : fileName;

      await _client.storage.from(bucket).upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from(bucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Upload listing image
  static Future<String?> uploadListingImage(
      File imageFile, String listingId) async {
    return await uploadImage(
      imageFile: imageFile,
      bucket: SupabaseConfig.imagesBucket,
      path: 'listings/$listingId',
    );
  }

  // Upload profile avatar
  static Future<String?> uploadAvatar(File imageFile, String userId) async {
    return await uploadImage(
      imageFile: imageFile,
      bucket: SupabaseConfig.avatarsBucket,
      path: 'avatars/$userId',
    );
  }

  // Delete file from storage
  static Future<bool> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Get file URL
  static String getFileUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // List files in bucket
  static Future<List<String>> listFiles(String bucket, {String? path}) async {
    try {
      final response = await _client.storage.from(bucket).list(path: path);
      return response.map((file) => file.name).toList();
    } catch (e) {
      debugPrint('Error listing files: $e');
      return [];
    }
  }

  // Download file
  static Future<Uint8List?> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await _client.storage.from(bucket).download(path);
      return response;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  // Create bucket if not exists
  static Future<bool> createBucket(String bucket) async {
    try {
      // Note: This requires admin privileges
      // In production, buckets should be created via Supabase dashboard
      return true;
    } catch (e) {
      debugPrint('Error creating bucket: $e');
      return false;
    }
  }
}
