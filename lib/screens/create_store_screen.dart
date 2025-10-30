import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'store_configuration_screen.dart';

class CreateStoreScreen extends StatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  String? _selectedStoreType;

  final List<Map<String, dynamic>> _storeTypes = [
    {
      'id': 'second_hand',
      'title': 'Second-Hand-Händler:in',
      'description':
          'Für Einzelpersonen, die gebrauchte Gegenstände verkaufen (ähnlich wie ein privater Flohmarkt).',
      'price': 'Kostenlos',
      'features': [
        'Einfacher Store',
        'Grundlegende Funktionen',
        'Banner-Werbung möglich',
        'Default Radius: 5 km'
      ],
      'icon': Icons.store,
      'color': Colors.green,
    },
    {
      'id': 'small',
      'title': 'Kleiner Store (Hobby / Handmade)',
      'description':
          'Für kreative Produkte wie Schmuck, Deko, DIY – auch als Nebeneinkommen.',
      'price': 'Kleiner Preis',
      'features': [
        'Eigene Gestaltung (Logo, Farben, Text)',
        'Kreative Produkte',
        'Banner-Werbung möglich',
        'Default Radius: 5-10 km'
      ],
      'icon': Icons.handyman,
      'color': Colors.blue,
    },
    {
      'id': 'pro',
      'title': 'Professioneller Store',
      'description':
          'Für regelmässige oder gewerbliche Anbieter mit höherem Bedarf.',
      'price': 'Abo-Modell',
      'features': [
        'Erweiterte Features',
        'Radius-Werbung bis 50 km',
        'Statistiken & Analytics',
        'Default Radius: 20 km'
      ],
      'icon': Icons.business,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store erstellen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wählen Sie Ihren Store-Typ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entscheiden Sie sich für den Store-Typ, der am besten zu Ihren Bedürfnissen passt.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ..._storeTypes.map((storeType) => _buildStoreTypeCard(storeType)),
            const SizedBox(height: 24),
            if (_selectedStoreType != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToStoreConfiguration();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Weiter zur Store-Konfiguration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreTypeCard(Map<String, dynamic> storeType) {
    final isSelected = _selectedStoreType == storeType['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? storeType['color'] : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStoreType = storeType['id'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: storeType['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      storeType['icon'],
                      color: storeType['color'],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeType['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          storeType['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: storeType['color'],
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: storeType['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  storeType['price'],
                  style: TextStyle(
                    color: storeType['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...storeType['features']
                  .map<Widget>((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: storeType['color'],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStoreConfiguration() async {
    if (_selectedStoreType != null) {
      final navigator = Navigator.of(context);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StoreConfigurationScreen(storeType: _selectedStoreType!),
        ),
      );

      // Wenn ein Store erstellt wurde, zurück zur vorherigen Seite
      if (result != null) {
        navigator.pop(result);
      }
    }
  }
}
