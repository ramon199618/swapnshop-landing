import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/create_listing_screen.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<Map<String, String>> matchedItems;
  final List<Map<String, String>> likedItems;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.matchedItems = const [],
    this.likedItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            IconButton(
              icon: Icon(
                Icons.home,
                color: currentIndex == 0 ? AppColors.accent : Colors.grey,
              ),
              onPressed: () => onTap(0),
            ),
            // Matches
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: currentIndex == 1 ? AppColors.accent : Colors.grey,
              ),
              onPressed: () => onTap(1),
            ),
            // Platzhalter für FloatingActionButton
            const SizedBox(width: 40),
            // Chat
            IconButton(
              icon: Icon(
                Icons.chat,
                color: currentIndex == 2 ? AppColors.accent : Colors.grey,
              ),
              onPressed: () => onTap(2),
            ),
            // Profil
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentIndex == 3 ? AppColors.accent : Colors.grey,
              ),
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative: Einfache BottomNavigationBar ohne FloatingActionButton
class SimpleBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SimpleBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Stores'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}

// FloatingActionButton für "Inserat erstellen"
class CreateListingFAB extends StatelessWidget {
  const CreateListingFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.accent,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateListingScreen()),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
