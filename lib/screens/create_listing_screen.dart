import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/listing.dart';
import '../widgets/image_picker_avatar.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
import '../services/auth_service.dart';
import '../services/monetization_service.dart';
import '../services/database_service.dart';
import '../widgets/limit_dialog.dart';
import '../screens/premium_upgrade_screen.dart';

class CreateListingScreen extends StatefulWidget {
  final String? groupId; // Falls in Gruppe erstellt
  final String? storeId; // Falls in Store erstellt

  const CreateListingScreen({
    super.key,
    this.groupId,
    this.storeId,
  });

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
  final TextEditingController offerTagsController = TextEditingController();
  final TextEditingController wantTagsController = TextEditingController();

  String selectedCategory = 'Swap';
  final List<String> categories = [
    'Swap',
    'Give away',
    'Sell',
    'Job/Hilfe inserieren'
  ];
  String? selectedJobCategory;
  final List<String> jobCategories = ['Alltagsjobs', 'Sommerjobs', 'Hauptjobs'];
  String? selectedPaymentType; // Payment Type für Jobs
  File? selectedImage;
  bool isAnonymous = false;

  // Location variables
  double? _userLatitude;
  double? _userLongitude;
  String _userLocationName = '';
  bool _isLoadingLocation = false;

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

  /// Get current user location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permission
      final permission = await Permission.location.request();
      if (permission != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Standort-Berechtigung erforderlich für bessere Sichtbarkeit'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Check if location services are enabled
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bitte aktivieren Sie die Standort-Dienste'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _userLatitude = position.latitude;
          _userLongitude = position.longitude;
          _userLocationName =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          locationController.text = _userLocationName;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Standort erfolgreich ermittelt'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Fehler beim Ermitteln des Standorts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Ermitteln des Standorts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void saveListing() async {
    final title = titleController.text.trim();
    final price = priceController.text.trim();
    final value = valueController.text.trim();
    final desired = desiredSwapController.text.trim();
    final owner = ownerNameController.text.trim();

    // Validierung
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib einen Titel ein')),
      );
      return;
    }

    // Validierung für Jobs
    if (selectedCategory == 'Job/Hilfe inserieren') {
      if (selectedJobCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte wähle eine Job-Kategorie aus'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (selectedPaymentType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte wähle einen Bezahlungstyp aus'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final currentUser = AuthService.getCurrentUser();
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Bitte melden Sie sich an, um ein Inserat zu erstellen')),
      );
      return;
    }

    final uid = currentUser.id;

    // Store locale before async operations
    final currentLocale = Localizations.localeOf(context).languageCode;

    // Prüfe Limits vor dem Erstellen des Listings
    if (selectedCategory == 'Swap' || selectedCategory == 'Sell') {
      final canPost = await MonetizationService.checkCanPost(
          uid, selectedCategory.toLowerCase());

      if (!canPost['allowed']) {
        if (!mounted) return;

        // Zeige entsprechenden Dialog basierend auf dem Grund
        if (canPost['reason'] == 'limit_reached' &&
            selectedCategory == 'Swap') {
          // Swap-Limit erreicht: Zeige Spenden-Dialog
          showDialog(
            context: context,
            builder: (context) => LimitDialog(
              category: selectedCategory,
              remaining: 0,
              maxFree: selectedCategory == 'Swap' ? 8 : 4,
            ),
          );
        } else if (canPost['reason'] == 'premium_required' &&
            selectedCategory == 'Sell') {
          // Premium erforderlich: Zeige Upgrade-Dialog
          showDialog(
            context: context,
            builder: (context) => const PremiumUpgradeScreen(),
          );
        }
        return;
      }
    }

    // Tag-Listen erstellen (nur für Swap)
    List<String> offerTags = [];
    List<String> wantTags = [];

    if (selectedCategory == 'Swap') {
      offerTags = offerTagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      wantTags = wantTagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    final listing = Listing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: descriptionController.text.trim(),
      type: selectedCategory == 'Sell'
          ? ListingType.sell
          : selectedCategory == 'Swap'
              ? ListingType.swap
              : selectedCategory == 'Job/Hilfe inserieren'
                  ? ListingType.job
                  : ListingType.giveaway,
      category: selectedCategory == 'Job/Hilfe inserieren'
          ? selectedJobCategory!.toLowerCase()
          : selectedCategory.toLowerCase(),
      price: selectedCategory == 'Sell' ? double.tryParse(price) : null,
      value: selectedCategory == 'Swap' ? double.tryParse(value) : null,
      desiredItem: selectedCategory == 'Swap' ? desired : null,
      ownerId: uid,
      ownerName: owner.isNotEmpty ? owner : 'Unbekannt',
      images: const [],
      tags: offerTags + wantTags,
      offerTags: offerTags,
      wantTags: wantTags,
      latitude: _userLatitude, // Aus Location-Service geholt
      longitude: _userLongitude, // Aus Location-Service geholt
      locationName: locationController.text.trim(),
      radiusKm: 50,
      isActive: true,
      visibility: ListingVisibility.public,
      language: currentLocale, // Aus Language-Provider geholt
      groupId: widget.groupId, // TODO: Falls in Gruppe erstellt
      storeId: widget.storeId, // TODO: Falls in Store erstellt
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: isAnonymous,
      condition: 'used',
      // Job-spezifische Felder
      jobCategory: selectedCategory == 'Job/Hilfe inserieren'
          ? selectedJobCategory
          : null,
      paymentType: selectedCategory == 'Job/Hilfe inserieren'
          ? selectedPaymentType
          : null, // TODO: Payment Type für Jobs
    );

    try {
      // Listing in Supabase speichern
      final response = await DatabaseService.createListing(listing);

      if (response != null) {
        // Bestätige den erfolgreichen Post für Quota-Tracking
        await MonetizationService.confirmPost(
            uid, selectedCategory.toLowerCase(), listing.id);

        debugPrint('📦 Inserat erfolgreich gespeichert: ${listing.title}');

        if (!mounted) return;

        // Store context before async operations
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${AppTexts.listingCreated}: ${listing.title}'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else {
        throw Exception('Fehler beim Speichern des Listings');
      }
    } catch (e) {
      debugPrint('❌ Fehler beim Speichern des Listings: $e');
      if (!mounted) return;

      // Store context before async operations
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createListingTitle),
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
            Text(l10n.ownerName),
            TextField(
              controller: ownerNameController,
              decoration: InputDecoration(
                hintText: l10n.ownerNameHint,
              ),
            ),
            const SizedBox(height: 16),

            // Titel
            Text(l10n.title),
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: l10n.titleHint),
            ),
            const SizedBox(height: 16),

            // Beschreibung
            Text(l10n.description),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.descriptionHint,
              ),
            ),
            const SizedBox(height: 16),

            // Kategorie
            Text(l10n.category),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((cat) {
                return DropdownMenuItem<String>(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                  // Reset job category when main category changes
                  if (value != 'Job/Hilfe inserieren') {
                    selectedJobCategory = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Job-Kategorie (nur bei "Job/Hilfe inserieren")
            if (selectedCategory == 'Job/Hilfe inserieren') ...[
              const Text('Job-Kategorie'),
              DropdownButton<String>(
                value: selectedJobCategory,
                isExpanded: true,
                hint: const Text('Bitte wähle eine Job-Kategorie'),
                items: jobCategories.map((cat) {
                  return DropdownMenuItem<String>(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJobCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Payment Type für Jobs
              const Text('Bezahlung'),
              DropdownButton<String>(
                value: selectedPaymentType,
                isExpanded: true,
                hint: const Text('Bitte wähle den Bezahlungstyp'),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'paid',
                    child: Text('Bezahlt (CHF/Stunde oder Pauschal)'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'barter',
                    child: Text('Tausch (Gegenleistung)'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'both',
                    child: Text('Beides möglich'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPaymentType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Preis bei "Sell"
            if (selectedCategory == 'Sell') ...[
              Text(l10n.price),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: l10n.priceHint),
              ),
              const SizedBox(height: 16),
            ],

            // Wert und Wunsch bei "Swap"
            if (selectedCategory == 'Swap') ...[
              Text(l10n.swapValue),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.swapValueHint,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.desiredSwapItem),
              TextField(
                controller: desiredSwapController,
                decoration: InputDecoration(
                  hintText: l10n.desiredSwapItemHint,
                ),
              ),
              const SizedBox(height: 16),

              // Offer Tags (Was wird angeboten?)
              Text(
                'Was bietest du an? (1-3 Stichwörter, durch Komma getrennt)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: offerTagsController,
                decoration: InputDecoration(
                  hintText: 'z.B. Gitarre, Musikinstrument, Akustik',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Want Tags (Was wird gesucht?)
              Text(
                'Was suchst du? (1-3 Stichwörter, durch Komma getrennt)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: wantTagsController,
                decoration: InputDecoration(
                  hintText: 'z.B. Keyboard, Klavier, Synthesizer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Standort
            Text(l10n.location),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: l10n.locationHint,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  tooltip: 'Aktuellen Standort verwenden',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Anonyme Option
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.privacy,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.privacyDescription,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Anonyme Checkbox
            CheckboxListTile(
              title: Text(l10n.anonymousPost),
              subtitle: Text(
                l10n.anonymousPostSubtitle,
                style: const TextStyle(fontSize: 12),
              ),
              value: isAnonymous,
              onChanged: (value) {
                setState(() {
                  isAnonymous = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Tags
            Text(l10n.tags),
            TextField(
              controller: tagsController,
              decoration: InputDecoration(hintText: l10n.tagsHint),
            ),
            const SizedBox(height: 20),

            // Button
            Center(
              child: ElevatedButton(
                onPressed: saveListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: Text(l10n.createListingButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
