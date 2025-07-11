import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/listing.dart';
import '../widgets/image_picker_avatar.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/listing_service.dart'; // Für Firestore-Speicherung

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController desiredSwapController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();

  String selectedCategory = 'Swap';
  final List<String> categories = ['Swap', 'Give away', 'Sell'];
  File? selectedImage;

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Bild auswählen: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Auswählen des Bildes')),
      );
    }
  }

  void saveListing() async {
    final title = titleController.text.trim();
    final price = priceController.text.trim();
    final value = valueController.text.trim();
    final desired = desiredSwapController.text.trim();
    final owner = ownerNameController.text.trim();
    // final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final uid = 'dummy_user_123';

    final listing = Listing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: selectedCategory == 'Sell'
          ? 'CHF $price'
          : selectedCategory == 'Swap'
          ? 'Tausch: $value CHF'
          : 'Kostenlos',
      userId: uid,
      userName: owner.isNotEmpty ? owner : 'Unbekannt',
      swapWish: selectedCategory == 'Swap' ? desired : null,
      description: descriptionController.text.trim(),
      price: double.tryParse(price) ?? 0.0,
      category: selectedCategory,
      images: const [],
      createdAt: DateTime.now(),
      location: locationController.text.trim(),
      condition: 'used',
    );

    // Listing in Firestore speichern
    // await FirebaseFirestore.instance
    //     .collection('listings')
    //     .add(listing.toJson());
    await Future.delayed(const Duration(milliseconds: 500));
    print('Listing würde gespeichert: ${listing.title}');

    debugPrint('📦 Inserat gespeichert: $listing');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppTexts.listingCreated}: ${listing.title}')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.createListingTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bildauswahl
            Center(
              child: ImagePickerAvatar(
                imageFile: selectedImage,
                onTap: pickImage,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            const Text(AppTexts.ownerName),
            TextField(
              controller: ownerNameController,
              decoration: const InputDecoration(
                hintText: AppTexts.ownerNameHint,
              ),
            ),
            const SizedBox(height: 16),

            // Titel
            const Text(AppTexts.title),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: AppTexts.titleHint),
            ),
            const SizedBox(height: 16),

            // Beschreibung
            const Text(AppTexts.description),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: AppTexts.descriptionHint,
              ),
            ),
            const SizedBox(height: 16),

            // Kategorie
            const Text(AppTexts.category),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((cat) {
                return DropdownMenuItem<String>(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Preis bei "Sell"
            if (selectedCategory == 'Sell') ...[
              const Text(AppTexts.price),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: AppTexts.priceHint),
              ),
              const SizedBox(height: 16),
            ],

            // Wert und Wunsch bei "Swap"
            if (selectedCategory == 'Swap') ...[
              const Text(AppTexts.swapValue),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: AppTexts.swapValueHint,
                ),
              ),
              const SizedBox(height: 16),
              const Text(AppTexts.desiredSwapItem),
              TextField(
                controller: desiredSwapController,
                decoration: const InputDecoration(
                  hintText: AppTexts.desiredSwapItemHint,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Standort
            const Text(AppTexts.location),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                hintText: AppTexts.locationHint,
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            const Text(AppTexts.tags),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(hintText: AppTexts.tagsHint),
            ),
            const SizedBox(height: 20),

            // Button
            Center(
              child: ElevatedButton(
                onPressed: saveListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: const Text(AppTexts.createListingButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
