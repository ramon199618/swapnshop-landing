import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../widgets/profile_avatar.dart';
import '../constants/texts.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/supabase_storage_service.dart';
import '../services/monetization_service.dart';
import '../providers/premium_test_provider.dart';
import '../screens/create_store_screen.dart';
import '../screens/create_community_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/create_listing_screen.dart';
import '../screens/my_store_screen.dart';
import '../screens/store_detail_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/community_screen.dart';
import '../screens/premium_upgrade_screen.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String? _profileImageUrl;

  String userName = 'Ramon Bieri';
  String userEmail = 'ramon@example.com';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final List<Map<String, String>> myListings = [
    {'title': 'Snowboard', 'status': 'Active'},
    {'title': 'Ski Boots', 'status': 'Sold'},
    {'title': 'Winter Jacket', 'status': 'Active'},
  ];

  final List<Map<String, String>> myStores = [
    {'name': 'Vintage Boutique', 'status': 'Active'},
    {'name': 'Tech Corner', 'status': 'Active'},
  ];

  final List<Map<String, String>> myGroups = [
    {'name': 'Fahrradtouren Zürich', 'members': '45'},
    {'name': 'Nachhaltigkeit Zürich', 'members': '128'},
  ];

  final List<Map<String, String>> myJobs = [
    {'title': 'Gartenarbeit', 'status': 'Active'},
    {'title': 'Babysitting', 'status': 'Completed'},
  ];

  bool _isPremium = false;
  static const String _imagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    nameController.text = userName;
    emailController.text = userEmail;
    _loadProfileImage();
    _loadProfileFromSupabase();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      try {
        // Prüfe zuerst den Testmodus
        final premiumTestProvider =
            Provider.of<PremiumTestProvider>(context, listen: false);
        if (premiumTestProvider.isPremiumTestEnabled &&
            premiumTestProvider.isPremiumTestMode) {
          if (mounted) {
            setState(() {
              _isPremium = true;
            });
          }
          return;
        }

        // Normale Premium-Prüfung
        final isPremium =
            await MonetizationService.isUserPremium(currentUser.id);
        if (mounted) {
          setState(() {
            _isPremium = isPremium;
          });
        }
      } catch (e) {
        debugPrint('Fehler beim Prüfen des Premium-Status: $e');
      }
    }
  }

  void _createStore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateStoreScreen(),
      ),
    );
  }

  void _createGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCommunityScreen(),
      ),
    );
  }

  void _createJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateListingScreen(),
      ),
    );
  }

  void _showPremiumRequired() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.premiumFeatures),
          content: const Text(
            'Diese Funktion ist nur für Premium-User verfügbar. '
            'Upgrade auf Premium, um Stores und Gruppen zu erstellen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToPremiumUpgrade();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(l10n.upgradeToPremium),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPremiumUpgrade() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PremiumUpgradeScreen(),
      ),
    );

    // Aktualisiere den Premium-Status nach der Rückkehr
    if (result == true) {
      await _checkPremiumStatus();
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_imagePathKey);

    if (savedPath != null) {
      final file = File(savedPath);
      if (await file.exists()) {
        if (!mounted) return;
        setState(() {
          _profileImage = file;
        });
      } else {
        prefs.remove(_imagePathKey);
      }
    }
  }

  Future<void> _loadProfileFromSupabase() async {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      try {
        final userProfile =
            await SupabaseService.getUserProfile(currentUser.id);
        if (userProfile != null) {
          setState(() {
            userName = userProfile.name;
            userEmail = userProfile.email ?? userEmail;
            if (userProfile.avatarUrl != null) {
              _profileImageUrl = userProfile.avatarUrl;
            }
          });
          // Update controllers
          nameController.text = userName;
          emailController.text = userEmail;
        }
      } catch (e) {
        debugPrint('Fehler beim Laden des Profils: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final savedFile = await _saveFilePermanently(pickedFile.path);
        if (!mounted) return;
        setState(() {
          _profileImage = savedFile;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_imagePathKey, savedFile.path);
      }
    } catch (e) {
      debugPrint('Fehler beim Bild auswählen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden des Bildes')),
        );
      }
    }
  }

  Future<File> _saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final newPath = path.join(directory.path, name);
    final newFile = await File(imagePath).copy(newPath);
    return newFile;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() {
      userName = nameController.text;
      // E-Mail wird nicht mehr bearbeitet (Auth-gebunden)
    });

    final currentUser = AuthService.getCurrentUser();
    String? imageUrl;

    if (currentUser != null && _profileImage != null) {
      try {
        // Upload profile image to Supabase Storage
        imageUrl = await SupabaseStorageService.uploadAvatar(
          _profileImage!,
          currentUser.id,
        );

        if (imageUrl != null) {
          setState(() {
            _profileImageUrl = imageUrl;
          });
        }
      } catch (e) {
        debugPrint('Fehler beim Upload des Profilbilds: $e');
      }
    }

    if (currentUser != null) {
      try {
        // Update user profile in Supabase
        await SupabaseService.updateUserProfile(currentUser.id, {
          'name': userName,
          // E-Mail wird nicht mehr aktualisiert (Auth-gebunden)
          if (imageUrl != null) 'avatar_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Also update auth user data
        await AuthService.updateProfile(
          name: userName,
          avatarUrl: imageUrl,
        );
      } catch (e) {
        debugPrint('Fehler beim Speichern des Profils: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Speichern: $e')),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppTexts.profileSaved)),
    );
  }

  void _handleProfileHeaderTap() {
    final premiumTestProvider =
        Provider.of<PremiumTestProvider>(context, listen: false);
    if (premiumTestProvider.isPremiumTestEnabled) {
      premiumTestProvider.togglePremiumTestMode();
      if (mounted) {
        setState(() {
          _isPremium = premiumTestProvider.isPremiumTestMode;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Container(
                    decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 87, 34, 0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
        child: Column(
          children: [
            // Profil-Header
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _handleProfileHeaderTap,
                child: Row(
                  children: [
                    ProfileAvatar(
                      imageFile: _profileImage,
                      imageUrl: _profileImageUrl,
                      onTap: _pickImage,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _isPremium
                                      ? Colors.amber
                                      : Theme.of(context).colorScheme.outline,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _isPremium ? 'Premium' : 'Free',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _isPremium
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                              ),
                              if (Provider.of<PremiumTestProvider>(context,
                                      listen: false)
                                  .isPremiumTestEnabled) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'TEST',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profilbild
                    ProfileAvatar(
                      imageFile: _profileImage,
                      imageUrl: _profileImageUrl,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: 24),

                    // Name & E-Mail editierbar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: l10n.nameLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: emailController,
                            enabled: false, // E-Mail ist nicht editierbar (Auth-gebunden)
                            decoration: InputDecoration(
                              labelText: l10n.emailLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: AppColors.primary,
                              ),
                              helperText: 'E-Mail ist an das Benutzerkonto gebunden',
                              helperStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(l10n.saveProfile),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 24),

                    // Eigene Inserate Übersicht
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.list,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.myListings,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${myListings.length} Inserate',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Liste der eigenen Inserate
                          ...myListings.map(
                            (listing) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      listing['title']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: listing['status'] == 'Active'
                                          ? Colors.green.shade100
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      listing['status']!,
                                      style: TextStyle(
                                        color: listing['status'] == 'Active'
                                            ? Colors.green.shade700
                                            : Colors.grey.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Eigene Stores Übersicht
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _isPremium
                                ? () {
                                    // Premium: Öffne Store-Übersicht (alt)
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MyStoreScreen(),
                                      ),
                                    );
                                  }
                                : () {
                                    // Free: Zeige Premium-Overlay direkt
                                    _showPremiumRequired();
                                  },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.myStores,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${myStores.length} Stores',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Liste der eigenen Stores
                          ...myStores.map(
                            (store) => InkWell(
                              onTap: _isPremium
                                  ? () {
                                      // Premium: Öffne Store-Details (alt)
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StoreDetailScreen(
                                            storeId: store['id'] ?? '1',
                                          ),
                                        ),
                                      );
                                    }
                                  : () {
                                      // Free: Zeige Premium-Overlay direkt
                                      _showPremiumRequired();
                                    },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        store['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: store['status'] == 'Active'
                                            ? Colors.green.shade100
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        store['status']!,
                                        style: TextStyle(
                                          color: store['status'] == 'Active'
                                              ? Colors.green.shade700
                                              : Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Store erstellen Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isPremium
                                  ? _createStore
                                  : _showPremiumRequired,
                              icon: const Icon(Icons.add),
                              label: const Text('Neuen Store erstellen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPremium
                                    ? AppColors.primary
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Eigene Gruppen Übersicht
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              // Immer tappbar (Free & Premium) → öffnet Gruppen-Übersicht (alt)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CommunityScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.groups,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                                                      const Text(
                                  'Meine Gruppen',
                                  style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${myGroups.length} Gruppen',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Liste der eigenen Gruppen
                          ...myGroups.map(
                            (group) => InkWell(
                              onTap: () {
                                // Öffne Gruppen-Details (alt)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommunityOverviewScreen(
                                      communityId: group['id'] ?? '1',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        group['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${group['members']} Mitglieder',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Gruppe erstellen Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isPremium
                                  ? _createGroup
                                  : _showPremiumRequired,
                              icon: const Icon(Icons.add),
                              label: const Text('Neue Gruppe erstellen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPremium
                                    ? AppColors.primary
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Link zu Gruppen entdecken
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                // Öffne Entdecken-Tab vorgefiltert auf Groups
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DiscoverScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.explore, size: 16),
                              label: const Text('Gruppen entdecken'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Jobs Übersicht
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.work,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                                                    const Text(
                                  'Meine Jobs',
                                  style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${myJobs.length} Jobs',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Liste der eigenen Jobs
                          ...myJobs.map(
                            (job) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      job['title']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: job['status'] == 'Active'
                                          ? Colors.green.shade100
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      job['status']!,
                                      style: TextStyle(
                                        color: job['status'] == 'Active'
                                            ? Colors.green.shade700
                                            : Colors.grey.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Job erstellen Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _createJob,
                              icon: const Icon(Icons.add),
                              label: const Text('Neuen Job anbieten'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Einstellungen
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(
                          l10n.settings,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                                                 subtitle: const Text('Sprachen, Support, Infos'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primary,
                        ),
                        onTap: _openSettings,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.logout, color: Colors.red.shade600),
                        ),
                        title: Text(
                          l10n.logout,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red.shade600,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red.shade600,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                                                         const SnackBar(content: Text('Logout-Funktion noch nicht implementiert')),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
