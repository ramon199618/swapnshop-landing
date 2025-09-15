import 'package:flutter/material.dart';
import '../services/like_service.dart';

class LikeProvider extends ChangeNotifier {
  // Artikel-IDs, die ich geliket habe (mit User-ID des Artikel-Erstellers)
  final Map<String, String> _myLikedItems = {}; // articleId -> userId
  // User-IDs, die meine Artikel geliket haben (simuliert)
  final List<String> _likedMeUserIds = ['user_002', 'user_003'];

  // Getter für die Logik
  Map<String, String> get myLikedItems => Map.unmodifiable(_myLikedItems);
  List<String> get likedMeUserIds => List.unmodifiable(_likedMeUserIds);

  // Like-Logik: Artikel liken
  void likeItem(String articleId, String articleUserId) {
    if (!_myLikedItems.containsKey(articleId)) {
      _myLikedItems[articleId] = articleUserId;
      notifyListeners();
      debugPrint('❤️ Artikel $articleId von User $articleUserId geliket');

      // Synchronisiere mit LikeService
      _syncWithLikeService();
    }
  }

  // Alias für likeItem
  void addLike(String articleId) {
    // Für Backend-Integration ohne articleUserId
    if (!_myLikedItems.containsKey(articleId)) {
      _myLikedItems[articleId] = 'unknown_user'; // Placeholder
      notifyListeners();
      debugPrint('❤️ Artikel $articleId geliket');
    }
  }

  // Unlike-Logik: Artikel unliken
  void unlikeItem(String articleId) {
    if (_myLikedItems.remove(articleId) != null) {
      notifyListeners();
      debugPrint('💔 Artikel $articleId ungeliket');

      // Synchronisiere mit LikeService
      _syncWithLikeService();
    }
  }

  // Alias für unlikeItem
  void removeLike(String articleId) {
    if (_myLikedItems.remove(articleId) != null) {
      notifyListeners();
      debugPrint('💔 Artikel $articleId ungeliket');
    }
  }

  // Simuliere, dass mich jemand liked (Testfunktion)
  void simulateLikeMe(String userId) {
    if (!_likedMeUserIds.contains(userId)) {
      _likedMeUserIds.add(userId);
      notifyListeners();
      debugPrint('👤 User $userId hat mich geliket');
    }
  }

  // Hilfsfunktionen für die Logik
  List<String> getMatches() {
    // Matches: User, die ich geliket habe UND die mich geliket haben
    final usersILiked = _myLikedItems.values.toSet();
    return usersILiked
        .where((userId) => _likedMeUserIds.contains(userId))
        .toList();
  }

  List<String> getLikes() {
    // Likes: User, die mich geliket haben, aber ich sie noch nicht
    return _likedMeUserIds
        .where((userId) => !_myLikedItems.values.contains(userId))
        .toList();
  }

  List<String> getLiked() {
    // Liked: User, die ich geliket habe, aber sie mich noch nicht
    final usersILiked = _myLikedItems.values.toSet();
    return usersILiked
        .where((userId) => !_likedMeUserIds.contains(userId))
        .toList();
  }

  // Prüfe, ob ein bestimmter Artikel geliket wurde
  bool isItemLiked(String articleId) {
    return _myLikedItems.containsKey(articleId);
  }

  // Prüfe, ob ein User geliket wurde
  bool isUserLiked(String userId) {
    return _myLikedItems.values.contains(userId);
  }

  // Prüfe, ob ein Match mit einem User besteht
  bool hasMatchWithUser(String userId) {
    return _myLikedItems.values.contains(userId) &&
        _likedMeUserIds.contains(userId);
  }

  // Getter für alle Artikel-IDs, die ich geliked habe
  List<String> getAllLikedArticleIds() {
    return _myLikedItems.keys.toList();
  }

  // Getter für alle User-IDs, die ich geliked habe (inkl. Matches)
  List<String> getAllLikedUserIds() {
    return _myLikedItems.values.toSet().toList();
  }

  // Synchronisiere mit LikeService
  void _syncWithLikeService() {
    final likeService = LikeService();
    final likedArticleIds = _myLikedItems.keys.toList();

    // Speichere alle gelikten Artikel-IDs im LikeService (async)
    for (final articleId in likedArticleIds) {
      likeService.likeItem(articleId).catchError((error) {
        debugPrint('❌ Fehler beim Speichern von Like: $error');
      });
    }
  }
}
