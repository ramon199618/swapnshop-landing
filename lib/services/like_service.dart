import 'package:shared_preferences/shared_preferences.dart';

class LikeService {
  static const String _likedKey = 'liked_items';

  Future<List<String>> getLikedItemIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_likedKey) ?? [];
  }

  Future<void> likeItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList(_likedKey) ?? [];
    if (!liked.contains(itemId)) {
      liked.add(itemId);
      await prefs.setStringList(_likedKey, liked);
    }
  }

  Future<void> unlikeItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList(_likedKey) ?? [];
    liked.remove(itemId);
    await prefs.setStringList(_likedKey, liked);
  }

  Future<bool> isLiked(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList(_likedKey) ?? [];
    return liked.contains(itemId);
  }
}
