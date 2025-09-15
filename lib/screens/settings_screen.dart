import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/app_links.dart';
import '../widgets/gradient_background.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/premium_test_provider.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/password_change_screen.dart';
import '../screens/premium_upgrade_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account-Einstellungen
          _buildSection(
            title: l10n.account,
            icon: Icons.person,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: Text(
                  l10n.editProfile,
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: Text(
                  l10n.editProfile,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: AppColors.primary),
                title: Text(
                  l10n.changePasswordTitle,
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: Text(
                  l10n.changePasswordTitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordChangeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sprache & Region
          _buildSection(
            title: '${l10n.language} & Region',
            icon: Icons.language,
            children: [
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.flag, color: AppColors.primary),
                    title: Text(
                      l10n.language,
                      style: const TextStyle(color: AppColors.textOnWhite),
                    ),
                    subtitle: Text(
                      'Aktuell: ${languageProvider.getLanguageName(languageProvider.currentLocale.languageCode)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: _showLanguageSelector,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Premium & Abonnement
          _buildSection(
            title: 'Premium & Abonnement',
            icon: Icons.star,
            children: [
              ListTile(
                leading: const Icon(Icons.upgrade, color: AppColors.primary),
                title: const Text(
                  'Premium werden',
                  style: TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'Alle Features freischalten',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumUpgradeScreen(),
                    ),
                  );
                },
              ),
              if (Provider.of<PremiumTestProvider>(context, listen: false)
                  .isPremiumTestEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.science, color: Colors.blue),
                  title: const Text(
                    'Premium-Testmodus',
                    style: TextStyle(color: AppColors.textOnWhite),
                  ),
                  subtitle: const Text(
                    'Für Entwickler: Premium simulieren',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: _togglePremiumTestMode,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // App & Benachrichtigungen
          _buildSection(
            title: 'App & Benachrichtigungen',
            icon: Icons.notifications,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.brightness_6,
                        color: AppColors.primary),
                    title: Text(
                      l10n.theme,
                      style: const TextStyle(color: AppColors.textOnWhite),
                    ),
                    subtitle: Text(
                      themeProvider.themeMode == ThemeMode.dark
                          ? 'Dunkel'
                          : themeProvider.themeMode == ThemeMode.light
                              ? 'Hell'
                              : 'System',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active,
                    color: AppColors.primary),
                title: Text(
                  l10n.pushNotifications,
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'Chats, Matches, Updates',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  _showNotificationSettings();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Support & Hilfe
          _buildSection(
            title: '${l10n.support} & ${l10n.help}',
            icon: Icons.help,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.help_outline, color: AppColors.primary),
                title: Text(
                  '${l10n.help}-Center',
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'FAQ und Anleitungen',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  // Capture BuildContext before async operation
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  launchUrl(Uri.parse(AppLinks.helpUrl)).catchError((error) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Hilfe-Center konnte nicht geöffnet werden'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return false; // Return value for catchError
                  });
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.support_agent, color: AppColors.primary),
                title: Text(
                  l10n.contactSupport,
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'E-Mail oder Chat-Support',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  _contactSupport();
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, color: AppColors.primary),
                title: const Text(
                  'Fehler melden',
                  style: TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'Bug oder Problem melden',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  _reportBug();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Über die App
          _buildSection(
            title: l10n.aboutApp,
            icon: Icons.info,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text(
                  'App-Info',
                  style: TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'Version, Lizenz, Credits',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  _showAppInfo();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.privacy_tip, color: AppColors.primary),
                title: Text(
                  l10n.privacyPolicy,
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'Datenschutzerklärung',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  launchUrl(Uri.parse(AppLinks.privacyUrl));
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.description, color: AppColors.primary),
                title: Text(
                  l10n.termsOfService,
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'AGB und Richtlinien',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  launchUrl(Uri.parse(AppLinks.termsUrl));
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Abmelden
          _buildSection(
            title: l10n.account,
            icon: Icons.logout,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: AppColors.textOnWhite),
                ),
                subtitle: const Text(
                  'Aus der App abmelden',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnWhite,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sprache auswählen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('Deutsch', 'de'),
              _buildLanguageOption('English', 'en'),
              _buildLanguageOption('Français', 'fr'),
              _buildLanguageOption('Italiano', 'it'),
              _buildLanguageOption('Português', 'pt'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String name, String code) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isSelected = languageProvider.currentLocale.languageCode == code;
        return ListTile(
          title: Text(
            name,
            style: const TextStyle(color: AppColors.textOnWhite),
          ),
          trailing: isSelected
              ? const Icon(Icons.check, color: AppColors.primary)
              : null,
          onTap: () {
            languageProvider.setLanguage(code);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _togglePremiumTestMode() {
    final premiumTestProvider =
        Provider.of<PremiumTestProvider>(context, listen: false);
    premiumTestProvider.togglePremiumTestMode();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(premiumTestProvider.isPremiumTestMode
            ? 'Premium-Testmodus aktiviert'
            : 'Premium-Testmodus deaktiviert'),
        backgroundColor: premiumTestProvider.isPremiumTestMode
            ? Colors.green
            : AppColors.primary,
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App-Info'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Swap&Shop',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Version: 1.0.0'),
              Text('Build: 2024.12.19'),
              SizedBox(height: 8),
              Text('© 2024 Ramon Bieri'),
              Text('Alle Rechte vorbehalten'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abmelden'),
          content:
              const Text('Möchten Sie sich wirklich aus der App abmelden?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Abmelden'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Abmelden: $e')),
        );
      }
    }
  }

  void _contactSupport() {
    // Capture BuildContext before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppLinks.supportEmail,
      queryParameters: {
        'subject': 'Support Request - Swap&Shop App',
        'body': 'Hallo Support-Team,\n\nIch benötige Hilfe bei folgendem Problem:\n\n\n\n---\nApp-Version: 1.0.0\nGerät: ${Theme.of(context).platform}\n',
      },
    );
    
    launchUrl(emailUri).catchError((error) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('E-Mail-Client konnte nicht geöffnet werden'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; // Return value for catchError
    });
  }

  void _reportBug() {
    // Capture BuildContext before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final Uri bugReportUri = Uri(
      scheme: 'mailto',
      path: AppLinks.bugReportEmail,
      queryParameters: {
        'subject': 'Bug Report - Swap&Shop App',
        'body': 'Hallo Entwickler-Team,\n\nIch habe folgenden Bug gefunden:\n\nBeschreibung:\n\nSchritte zum Reproduzieren:\n1.\n2.\n3.\n\nErwartetes Verhalten:\n\nTatsächliches Verhalten:\n\n---\nApp-Version: 1.0.0\nGerät: ${Theme.of(context).platform}\n',
      },
    );
    
    launchUrl(bugReportUri).catchError((error) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('E-Mail-Client konnte nicht geöffnet werden'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; // Return value for catchError
    });
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Benachrichtigungen'),
          content: const Text('Benachrichtigungs-Einstellungen werden in einer zukünftigen Version verfügbar sein.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }
}
