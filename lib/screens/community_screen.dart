import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../widgets/gradient_background.dart';
import '../l10n/app_localizations.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';
import '../services/monetization_service.dart';
import '../providers/premium_test_provider.dart';
import 'create_community_screen.dart';
import 'premium_upgrade_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _myCommunities = [];
  List<Map<String, dynamic>> _publicCommunities = [];
  bool _isLoading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCommunities();
    _checkPremiumStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lade meine Communities
      _myCommunities = [
        {
          'id': '1',
          'name': 'Velotausch Zürich',
          'description': 'Fahrräder und Zubehör tauschen in Zürich',
          'imageUrl': null,
          'memberCount': 127,
          'radius': 25,
          'isMember': true,
          'categories': ['Velotausch', 'Sport'],
        },
        {
          'id': '3',
          'name': 'Sport Equipment Basel',
          'description': 'Sportausrüstung und Outdoor-Equipment in Basel',
          'imageUrl': null,
          'memberCount': 234,
          'radius': 30,
          'isMember': true,
          'categories': ['Sport', 'Outdoor'],
        },
        {
          'id': '5',
          'name': 'Elektronik Tausch Zürich',
          'description': 'Smartphones, Laptops und Elektronik in Zürich',
          'imageUrl': null,
          'memberCount': 89,
          'radius': 20,
          'isMember': true,
          'categories': ['Elektronik', 'Technik'],
        },
      ];

      // Lade öffentliche Communities
      _publicCommunities = [
        {
          'id': '2',
          'name': 'WG Zermatt',
          'description': 'Wohngemeinschaft und Haushaltsartikel in Zermatt',
          'imageUrl': null,
          'memberCount': 89,
          'radius': 15,
          'isMember': false,
          'categories': ['WG', 'Haushalt'],
          'location': 'Zermatt',
        },
        {
          'id': '4',
          'name': 'Bücher & Medien Bern',
          'description': 'Bücher, CDs, DVDs und Medien in Bern',
          'imageUrl': null,
          'memberCount': 156,
          'radius': 20,
          'isMember': false,
          'categories': ['Bücher', 'Medien'],
          'location': 'Bern',
        },
        {
          'id': '6',
          'name': 'Kleidung & Mode Genf',
          'description': 'Kleidung, Schuhe und Accessoires in Genf',
          'imageUrl': null,
          'memberCount': 198,
          'radius': 25,
          'isMember': false,
          'categories': ['Kleidung', 'Mode'],
          'location': 'Genf',
        },
      ];
    } catch (e) {
      debugPrint('Fehler beim Laden der Communities: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) return;

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
      final isPremium = await MonetizationService.isUserPremium(currentUser.id);
      if (mounted) {
        setState(() {
          _isPremium = isPremium;
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Prüfen des Premium-Status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.groups,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Meine Gruppen (${_myCommunities.length})'),
            Tab(text: 'Alle Gruppen (${_publicCommunities.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyCommunitiesTab(),
                _buildPublicCommunitiesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isPremium ? _createGroup : _showPremiumRequired,
        backgroundColor: _isPremium ? AppColors.primary : Colors.grey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMyCommunitiesTab() {
    if (_myCommunities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Du bist noch in keiner Gruppe',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tritt einer Gruppe bei oder erstelle eine neue',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myCommunities.length,
      itemBuilder: (context, index) {
        final community = _myCommunities[index];
        return _buildCommunityCard(community, true);
      },
    );
  }

  Widget _buildPublicCommunitiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _publicCommunities.length,
      itemBuilder: (context, index) {
        final community = _publicCommunities[index];
        return _buildCommunityCard(community, false);
      },
    );
  }

  Widget _buildCommunityCard(
      Map<String, dynamic> community, bool isMyCommunity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (isMyCommunity) {
            // Öffne Community-Übersicht
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityOverviewScreen(
                  communityId: community['id'],
                ),
              ),
            );
          } else {
            // Zeige Community-Details und Beitritts-Option
            _showJoinCommunityDialog(community);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Community Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.groups,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Community Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      community['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${community['memberCount']} Mitglieder',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${community['radius']}km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: (community['categories'] as List<dynamic>)
                          .take(3)
                          .map((category) {
                        return Chip(
                          label: Text(
                            category,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Action Button
              if (isMyCommunity)
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityOverviewScreen(
                          communityId: community['id'],
                        ),
                      ),
                    );
                  },
                )
              else
                ElevatedButton(
                  onPressed: () => _showJoinCommunityDialog(community),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Beitreten'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinCommunityDialog(Map<String, dynamic> community) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${community['name']} beitreten?'),
          content: Text(
            'Möchtest du der Gruppe "${community['name']}" beitreten? '
            'Du erhältst dann Zugriff auf alle Gruppen-Inhalte und kannst '
            'mit anderen Mitgliedern interagieren.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _joinCommunity(community);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Beitreten'),
            ),
          ],
        );
      },
    );
  }

  void _joinCommunity(Map<String, dynamic> community) async {
    // Capture BuildContext before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Zeige Ladezustand
      setState(() {
        _isLoading = true;
      });

      // Rufe CommunityService auf
      final success = await CommunityService.joinCommunity(
        community['id'],
        AuthService.getCurrentUser()?.id ?? '',
      );

      if (success) {
        // Erfolgreich beigetreten
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                  'Du bist der Gruppe "${community['name']}" beigetreten!'),
              backgroundColor: Colors.green,
            ),
          );

          // Aktualisiere die Listen (optimistisch)
          setState(() {
            _myCommunities.add(community);
            _publicCommunities.removeWhere((c) => c['id'] == community['id']);
          });
        }
      } else {
        // Fehler beim Beitritt
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content:
                  Text('Beitritt fehlgeschlagen. Bitte versuche es erneut.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Fehlerbehandlung
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Fehler beim Beitritt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Ladezustand beenden
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _createGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCommunityScreen(),
      ),
    );
  }

  void _showPremiumRequired() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PremiumUpgradeScreen(),
      ),
    );
  }
}

// Community Overview Screen (vereinfacht)
class CommunityOverviewScreen extends StatefulWidget {
  final String communityId;

  const CommunityOverviewScreen({
    super.key,
    required this.communityId,
  });

  @override
  State<CommunityOverviewScreen> createState() =>
      _CommunityOverviewScreenState();
}

class _CommunityOverviewScreenState extends State<CommunityOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Übersicht'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Community-Übersicht wird geladen...'),
      ),
    );
  }
}
