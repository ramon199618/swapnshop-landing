import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_background.dart';
import '../services/monetization_service.dart';
import '../services/community_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _jobs = [];
  final bool _isLoading = true;
  String _selectedCategory = 'Alle';
  String? _sortBy = 'newest';

  // Filter-Variablen
  final Set<String> _selectedStoreTypes = {}; // Mehrfachauswahl
  final Set<String> _selectedGroupTypes = {}; // Mehrfachauswahl
  final Set<String> _selectedJobTypes = {
    'Alltagsjobs',
    'Sommerjobs',
    'Hauptjobs'
  }; // Job-Kategorien
  double _selectedRadius = 10.0; // Standard: 10km
  String _searchQuery = '';
  bool _isFilterActive = false;

  // Job-Kategorien
  static const List<String> _jobCategories = [
    'Alltagsjobs',
    'Sommerjobs',
    'Hauptjobs',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadStores(),
        _loadGroups(),
        _loadJobs(),
      ]);
    } catch (e) {
      debugPrint('Fehler beim Laden der Daten: $e');
    }
  }

  Future<void> _loadStores() async {
    try {
      final stores = await MonetizationService.getNearbyStores(
        latitude: 47.3769, // Zürich als Beispiel
        longitude: 8.5417,
        radius: _selectedRadius.toInt(),
        storeTypes: _selectedStoreTypes.isNotEmpty
            ? _selectedStoreTypes.toList()
            : null,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
      );

      if (mounted) {
        setState(() {
          _stores = stores;
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Stores: $e');
    }
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await CommunityService.getGroups(
        category:
            _selectedGroupTypes.isNotEmpty ? _selectedGroupTypes.first : null,
        radiusKm: _selectedRadius,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        lat: 47.3769, // Zürich als Beispiel
        lon: 8.5417,
      );

      if (mounted) {
        setState(() {
          _groups = groups;
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Gruppen: $e');
    }
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await MonetizationService.getJobs(
        category: _selectedJobTypes.length < 3 ? _selectedJobTypes.first : null,
        radiusKm: _selectedRadius,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        jobType: _selectedJobTypes.contains('Bezahlt') &&
                _selectedJobTypes.contains('Tausch')
            ? 'both'
            : _selectedJobTypes.contains('Bezahlt')
                ? 'paid'
                : 'barter',
      );

      if (mounted) {
        setState(() {
          _jobs = jobs;
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Jobs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Entdecken'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textOnBlue,
          unselectedLabelColor: AppColors.textOnBlue.withValues(alpha: 0.7),
          indicatorColor: AppColors.textOnBlue,
          tabs: const [
            Tab(text: 'Stores'),
            Tab(text: 'Gruppen'),
            Tab(text: 'Jobs'),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_isFilterActive)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContent(_stores, 'Stores'),
          _buildContent(_groups, 'Gruppen'),
          _buildContent(_jobs, 'Jobs'),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> items, String title) {
    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategorie',
                    labelStyle: TextStyle(color: AppColors.textOnWhite),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: AppColors.textOnWhite),
                  items: const [
                    DropdownMenuItem(
                        value: 'Alle',
                        child: Text('Alle',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Schmuck',
                        child: Text('Schmuck',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Deko',
                        child: Text('Deko',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Kleidung',
                        child: Text('Kleidung',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Elektronik',
                        child: Text('Elektronik',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Sport',
                        child: Text('Sport',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Bücher',
                        child: Text('Bücher',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Spielzeug',
                        child: Text('Spielzeug',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Haushalt',
                        child: Text('Haushalt',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'Sonstiges',
                        child: Text('Sonstiges',
                            style: TextStyle(color: AppColors.textOnWhite))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _loadData(); // Reload data for the current tab
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Sortieren nach',
                    labelStyle: TextStyle(color: AppColors.textOnWhite),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: AppColors.textOnWhite),
                  items: const [
                    DropdownMenuItem(
                        value: 'newest',
                        child: Text('Neueste zuerst',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'popular',
                        child: Text('Beliebteste',
                            style: TextStyle(color: AppColors.textOnWhite))),
                    DropdownMenuItem(
                        value: 'distance',
                        child: Text('Nächste',
                            style: TextStyle(color: AppColors.textOnWhite))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                    _loadData(); // Reload data for the current tab
                  },
                ),
              ),
            ],
          ),
        ),

        // Items List
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.store,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Keine $title in der Nähe',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Erweitere deinen Suchradius oder versuche es später erneut.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/${title.toLowerCase()}-detail',
                                arguments: item,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  if (item['imageUrl'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item['imageUrl']!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.store),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.store,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['name'] ?? item['title'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textOnWhite,
                                                ),
                                              ),
                                            ),
                                            if (item['isPremium'])
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Premium',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['location'],
                                          style: const TextStyle(
                                              color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textOnWhite,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Zeige Job-Kategorie und Bezahlung für Jobs
                                        if (title == 'Jobs') ...[
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getJobCategoryColor(
                                                      item['category']),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  item['category'] ??
                                                      'Unbekannt',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: item['type'] ==
                                                          'Bezahlt'
                                                      ? Colors.green.shade100
                                                      : AppColors.primary
                                                          .withValues(
                                                              alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  item['type'] ?? 'Unbekannt',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: item['type'] ==
                                                            'Bezahlt'
                                                        ? Colors.green.shade700
                                                        : Colors
                                                            .orange.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Bezahlung: ${item['payment']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ] else ...[
                                          // Normale Kategorien für Stores und Gruppen
                                          Wrap(
                                            spacing: 4,
                                            children: (item['categories']
                                                        as List<dynamic>?)
                                                    ?.take(3)
                                                    .map((category) {
                                                  return Chip(
                                                    label: Text(
                                                      category,
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .textOnWhite),
                                                    ),
                                                    backgroundColor: AppColors
                                                        .primary
                                                        .withValues(alpha: 0.1),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  );
                                                }).toList() ??
                                                [],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Radius Slider
                  const Text(
                    'Suchradius',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _selectedRadius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: '${_selectedRadius.round()} km',
                    onChanged: (value) {
                      setModalState(() {
                        _selectedRadius = value;
                      });
                    },
                  ),
                  Center(
                    child: Text(
                      '${_selectedRadius.round()} km',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Suchfeld
                  const Text(
                    'Suche',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'z.B. Vintage, Schmuck, Kinderkleider...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      prefixIcon:
                          Icon(Icons.search, color: AppColors.iconOnWhite),
                    ),
                    style: const TextStyle(color: AppColors.textOnWhite),
                    onChanged: (value) {
                      setModalState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Job-Kategorien (nur im Jobs-Tab sichtbar)
                  if (_tabController.index == 2) ...[
                    const Text(
                      'Job-Kategorien',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _jobCategories.map((category) {
                        return FilterChip(
                          label: Text(
                            category,
                            style:
                                const TextStyle(color: AppColors.textOnWhite),
                          ),
                          selected: _selectedJobTypes.contains(category),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                _selectedJobTypes.add(category);
                              } else {
                                _selectedJobTypes.remove(category);
                              }
                            });
                          },
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Sortierung
                  const Text(
                    'Sortierung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                        'Neueste',
                        'newest',
                        _sortBy,
                        (value) => setModalState(() => _sortBy = value),
                      ),
                      _buildFilterChip(
                        'Beliebteste',
                        'popular',
                        _sortBy,
                        (value) => setModalState(() => _sortBy = value),
                      ),
                      _buildFilterChip(
                        'Nächste',
                        'distance',
                        _sortBy,
                        (value) => setModalState(() => _sortBy = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Anwenden Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isFilterActive = _selectedStoreTypes.isNotEmpty ||
                              _selectedGroupTypes.isNotEmpty ||
                              _selectedJobTypes.length !=
                                  3 || // Alle Job-Kategorien ausgewählt = kein Filter
                              _selectedRadius != 10.0 ||
                              _searchQuery.isNotEmpty;
                        });
                        Navigator.pop(context);
                        _applyFilters();
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
                        'Filter anwenden',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? value, String? selectedValue,
      Function(String?) onChanged) {
    final isSelected = selectedValue == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textOnWhite,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        onChanged(selected ? value : null);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  void _applyFilters() {
    // Simuliere das Neuladen der Stores mit Filtern
    _loadData();
  }

  Color _getJobCategoryColor(String? category) {
    switch (category) {
      case 'Alltagsjobs':
        return Colors.blue;
      case 'Sommerjobs':
        return AppColors.primary;
      case 'Hauptjobs':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
