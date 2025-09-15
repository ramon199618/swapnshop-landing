import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../services/community_service.dart';
import '../services/database_service.dart';

import '../constants/colors.dart';

class CommunityManagementScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityManagementScreen({
    super.key,
    required this.community,
  });

  @override
  State<CommunityManagementScreen> createState() =>
      _CommunityManagementScreenState();
}

class _CommunityManagementScreenState extends State<CommunityManagementScreen> {
  bool _isLoading = false;

  Future<void> _updateCommunitySettings(Map<String, dynamic> updates) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await CommunityService.updateCommunity(
        widget.community.id,
        updates,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Community-Einstellungen aktualisiert!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error updating community settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Aktualisieren')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.community.name} verwalten'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community-Informationen',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text('Name: ${widget.community.name}'),
                          Text(
                              'Kategorie: ${widget.community.category ?? 'Nicht angegeben'}'),
                          Text(
                              'Öffentlich: ${widget.community.isPublic ? 'Ja' : 'Nein'}'),
                          Text('Mitglieder: ${widget.community.memberCount}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Management Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verwaltungsaktionen',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.edit,
                                color: AppColors.primary),
                            title: const Text('Community bearbeiten'),
                            onTap: () {
                              _showEditCommunityDialog();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.people,
                                color: AppColors.primary),
                            title: const Text('Mitglieder verwalten'),
                            onTap: () {
                              _showMemberManagementDialog();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.settings,
                                color: AppColors.primary),
                            title: const Text('Privatsphäre-Einstellungen'),
                            onTap: () {
                              _showPrivacySettingsDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Danger Zone
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gefahrenbereich',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.red.shade700,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading:
                                Icon(Icons.delete, color: Colors.red.shade700),
                            title: Text(
                              'Community löschen',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            onTap: () {
                              _showDeleteDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Community löschen'),
          content: Text(
            'Möchtest du "${widget.community.name}" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success =
                    await CommunityService.deleteCommunity(widget.community.id);
                if (success && context.mounted) {
                  Navigator.of(context).pop(); // Back to community list
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommunityDialog() {
    final nameController = TextEditingController(text: widget.community.name);
    final descriptionController =
        TextEditingController(text: widget.community.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Community bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (context.mounted) {
                  await _updateCommunitySettings({
                    'name': nameController.text,
                    'description': descriptionController.text,
                  });
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void _showMemberManagementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mitglieder verwalten'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                const Text('Community-Mitglieder'),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _loadCommunityMembers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Fehler beim Laden'));
                      }

                      final members = snapshot.data ?? [];

                      return ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child:
                                  Text(member['name']?.substring(0, 1) ?? '?'),
                            ),
                            title: Text(member['name'] ?? 'Unbekannt'),
                            subtitle: Text(member['role'] ?? 'Mitglied'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) =>
                                  _handleMemberAction(member['id'], action),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'promote',
                                  child: Text('Zum Admin befördern'),
                                ),
                                const PopupMenuItem(
                                  value: 'demote',
                                  child: Text('Admin-Rechte entziehen'),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Entfernen'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacySettingsDialog() {
    bool isPublic = widget.community.isPublic;
    bool allowInvites = true;
    bool requireApproval = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Privatsphäre-Einstellungen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Öffentliche Community'),
                    subtitle: const Text('Jeder kann die Community sehen'),
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Einladungen erlauben'),
                    subtitle: const Text('Mitglieder können andere einladen'),
                    value: allowInvites,
                    onChanged: (value) {
                      setState(() {
                        allowInvites = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Genehmigung erforderlich'),
                    subtitle:
                        const Text('Neue Mitglieder müssen genehmigt werden'),
                    value: requireApproval,
                    onChanged: (value) {
                      setState(() {
                        requireApproval = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _updateCommunitySettings({
                      'is_public': isPublic,
                      'allow_invites': allowInvites,
                      'require_approval': requireApproval,
                    });
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadCommunityMembers() async {
    try {
      final members =
          await DatabaseService.getCommunityMembers(widget.community.id);
      return members
          .map((member) => {
                'id': member['user_id'],
                'name': member['profiles']?['name'] ?? 'Unbekannt',
                'role': member['role'] ?? 'Mitglied',
                'avatar': member['profiles']?['avatar_url'],
              })
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading community members: $e');
      return [];
    }
  }

  Future<void> _handleMemberAction(String memberId, String action) async {
    final navigatorContext = context;
    if (!navigatorContext.mounted) return;

    try {
      switch (action) {
        case 'promote':
          final success = await DatabaseService.promoteMemberToAdmin(
            widget.community.id,
            memberId,
          );
          if (navigatorContext.mounted) {
            if (success) {
              ScaffoldMessenger.of(navigatorContext).showSnackBar(
                const SnackBar(content: Text('Mitglied zum Admin befördert')),
              );
            } else {
              ScaffoldMessenger.of(navigatorContext).showSnackBar(
                const SnackBar(content: Text('Fehler beim Befördern')),
              );
            }
          }
          break;
        case 'demote':
          final success = await DatabaseService.demoteAdminToMember(
            widget.community.id,
            memberId,
          );
          if (navigatorContext.mounted) {
            if (success) {
              ScaffoldMessenger.of(navigatorContext).showSnackBar(
                const SnackBar(content: Text('Admin-Rechte entzogen')),
              );
            } else {
              ScaffoldMessenger.of(navigatorContext).showSnackBar(
                const SnackBar(
                    content: Text('Fehler beim Entziehen der Rechte')),
              );
            }
          }
          break;
        case 'remove':
          final success = await DatabaseService.removeMember(
            widget.community.id,
            memberId,
          );
          if (navigatorContext.mounted) {
            if (success) {
              ScaffoldMessenger.of(navigatorContext).showSnackBar(
                const SnackBar(content: Text('Mitglied entfernt')),
              );
            } else {
              ScaffoldMessenger.of(navigatorContext).showSnackBar(
                const SnackBar(content: Text('Fehler beim Entfernen')),
              );
            }
          }
          break;
        default:
          debugPrint('Unknown action: $action');
          break;
      }
    } catch (e) {
      debugPrint('❌ Error handling member action: $e');
      if (navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(content: Text('Fehler bei der Aktion')),
        );
      }
    }
  }
}
