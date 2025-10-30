import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class StoreConfigurationScreen extends StatefulWidget {
  final String storeType;

  const StoreConfigurationScreen({
    super.key,
    required this.storeType,
  });

  @override
  State<StoreConfigurationScreen> createState() =>
      _StoreConfigurationScreenState();
}

class _StoreConfigurationScreenState extends State<StoreConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _logoImage;
  final ImagePicker _picker = ImagePicker();

  String get _storeTypeName {
    switch (widget.storeType) {
      case 'second_hand':
        return 'Second-Hand-Händler:in';
      case 'small':
        return 'Kleiner Store';
      case 'pro':
        return 'Professioneller Store';
      default:
        return 'Store';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store konfigurieren'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konfigurieren Sie Ihren $_storeTypeName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Geben Sie die grundlegenden Informationen für Ihren Store ein.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Logo/Bild Upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Store-Logo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: _pickLogoImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: _logoImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.file(
                                      _logoImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tippen Sie, um ein Logo hochzuladen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Store Name
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Store-Name *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'z.B. Mein Flohmarkt, Handgemachte Schätze',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte geben Sie einen Store-Namen ein';
                          }
                          if (value.length < 3) {
                            return 'Der Name muss mindestens 3 Zeichen lang sein';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Store Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Beschreibung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'Beschreiben Sie Ihren Store und was Sie anbieten...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Create Store Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Store erstellen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLogoImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _logoImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Auswählen des Bildes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createStore() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store wird erstellt...'),
          backgroundColor: AppColors.primary,
        ),
      );

      try {
        final user = AuthService.getCurrentUser();
        if (user == null) {
          throw Exception('Benutzer nicht angemeldet');
        }

        // Store in Supabase erstellen
        final storeData = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'logo_url': _logoImage?.path,
          'user_id': user.id,
          'type': widget.storeType,
          'created_at': DateTime.now().toIso8601String(),
        };

        await DatabaseService.createStore(storeData);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store erfolgreich erstellt!'),
            backgroundColor: Colors.green,
          ),
        );

        // Store-Daten für sofortige Anzeige vorbereiten
        final createdStore = {
          'id':
              DateTime.now().millisecondsSinceEpoch.toString(), // Temporäre ID
          'name': _nameController.text,
          'description': _descriptionController.text,
          'logo_url': _logoImage?.path,
          'user_id': user.id,
          'type': widget.storeType,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Zurück zur MyStoreScreen mit aktualisierten Daten
        Navigator.pop(context, createdStore);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Erstellen des Stores: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
