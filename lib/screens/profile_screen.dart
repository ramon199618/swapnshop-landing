import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../widgets/profile_avatar.dart';
import '../constants/texts.dart';
import '../constants/colors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

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

  static const String _imagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    nameController.text = userName;
    emailController.text = userEmail;
    _loadProfileImage();
    _loadProfileFromFirestore();
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

  Future<void> _loadProfileFromFirestore() async {
    // final uid = FirebaseAuth.instance.currentUser?.uid;
    final uid = 'dummy_user_123';
    if (uid != null) {
      // TODO: Firebase wieder aktivieren
      // final doc = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(uid)
      //     .get();
      // final data = doc.data();
      // if (data != null) {
      //   setState(() {
      //     userName = data['userName'] ?? userName;
      //     userEmail = data['userEmail'] ?? userEmail;
      //     if (data['profileImageUrl'] != null) {
      //       _profileImageUrl = data['profileImageUrl'];
      //   }
      //   });
      // }
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
      userEmail = emailController.text;
    });
    // final uid = FirebaseAuth.instance.currentUser?.uid;
    final uid = 'dummy_user_123';
    String? imageUrl;
    if (uid != null && _profileImage != null) {
      // TODO: Firebase Storage wieder aktivieren
      // final ref = FirebaseStorage.instance.ref().child(
      //   'profile_images/$uid.jpg',
      // );
      // await ref.putFile(_profileImage!);
      // imageUrl = await ref.getDownloadURL();
    }
    if (uid != null) {
      // TODO: Firebase Firestore wieder aktivieren
      // await FirebaseFirestore.instance.collection('users').doc(uid).set({
      //   'userName': userName,
      //   'userEmail': userEmail,
      //   if (imageUrl != null) 'profileImageUrl': imageUrl,
      // }, SetOptions(merge: true));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppTexts.profileSaved)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(255, 87, 34, 0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    AppTexts.profileTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.settings, color: AppColors.primary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppTexts.settingsTodo)),
                      );
                    },
                  ),
                ],
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
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: AppTexts.nameLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: AppTexts.emailLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: AppColors.primary,
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
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(AppTexts.saveProfile),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 24),

                    // Communities Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.groups, color: Colors.white),
                        ),
                        title: Text(
                          AppTexts.communities,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(AppTexts.communitiesSubtitle),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primary,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(AppTexts.communitiesTodo),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Eigene Inserate Übersicht
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
                                      AppTexts.myListings,
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
                              Icon(
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

                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
                          AppTexts.logout,
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
                            const SnackBar(content: Text(AppTexts.logoutTodo)),
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
