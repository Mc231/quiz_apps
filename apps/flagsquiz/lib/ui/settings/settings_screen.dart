import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_services/shared_services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings screen for the Flags Quiz app
class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late QuizSettings _currentSettings;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settingsService.currentSettings;
    _loadPackageInfo();

    widget.settingsService.settingsStream.listen((settings) {
      if (mounted) {
        setState(() {
          _currentSettings = settings;
        });
      }
    });
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.couldNotOpenUrl(url))),
        );
      }
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: _packageInfo?.appName ?? 'Flags Quiz',
      applicationVersion: _packageInfo?.version ?? '1.0.0',
    );
  }

  void _showAboutDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.about),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_packageInfo != null) ...[
                Text(
                  _packageInfo!.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('${loc.version}: ${_packageInfo!.version}'),
                Text('${loc.build}: ${_packageInfo!.buildNumber}'),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(loc.audioAndHaptics),
          SwitchListTile(
            title: Text(loc.soundEffects),
            subtitle: Text(loc.soundEffectsDescription),
            value: _currentSettings.soundEnabled,
            onChanged: (value) async {
              await widget.settingsService.toggleSound();
            },
          ),
          SwitchListTile(
            title: Text(loc.backgroundMusic),
            subtitle: Text(loc.backgroundMusicDescription),
            value: _currentSettings.musicEnabled,
            onChanged: (value) async {
              await widget.settingsService.toggleMusic();
            },
          ),
          SwitchListTile(
            title: Text(loc.hapticFeedback),
            subtitle: Text(loc.hapticFeedbackDescription),
            value: _currentSettings.hapticEnabled,
            onChanged: (value) async {
              await widget.settingsService.toggleHaptic();
            },
          ),
          const Divider(),
          _buildSectionHeader(loc.quizBehavior),
          SwitchListTile(
            title: Text(loc.showAnswerFeedback),
            subtitle: Text(loc.showAnswerFeedbackDescription),
            value: _currentSettings.showAnswerFeedback,
            onChanged: (value) async {
              await widget.settingsService.toggleAnswerFeedback();
            },
          ),
          const Divider(),
          _buildSectionHeader(loc.appearance),
          ListTile(
            title: Text(loc.theme),
            subtitle: Text(_getThemeModeText(_currentSettings.themeMode, loc)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),
          const Divider(),
          _buildSectionHeader(loc.about),
          if (_packageInfo != null)
            ListTile(
              title: Text(loc.version),
              subtitle: Text(
                '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
              ),
            ),
          ListTile(
            title: Text(loc.aboutThisApp),
            trailing: const Icon(Icons.info_outline),
            onTap: _showAboutDialog,
          ),
          ListTile(
            title: Text(loc.openSourceLicenses),
            trailing: const Icon(Icons.description_outlined),
            onTap: _showLicenses,
          ),
          const Divider(),
          _buildSectionHeader(loc.advanced),
          ListTile(
            title: Text(loc.resetToDefaults),
            subtitle: Text(loc.resetToDefaultsDescription),
            trailing: const Icon(Icons.restore),
            onTap: () => _showResetDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getThemeModeText(AppThemeMode mode, AppLocalizations loc) {
    switch (mode) {
      case AppThemeMode.light:
        return loc.themeLight;
      case AppThemeMode.dark:
        return loc.themeDark;
      case AppThemeMode.system:
        return loc.themeSystem;
    }
  }

  void _showThemeDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: deprecated_member_use
            RadioListTile<AppThemeMode>(
              title: Text(loc.themeLight),
              value: AppThemeMode.light,
              // ignore: deprecated_member_use
              groupValue: _currentSettings.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) async {
                if (value != null) {
                  await widget.settingsService.setThemeMode(value);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<AppThemeMode>(
              title: Text(loc.themeDark),
              value: AppThemeMode.dark,
              // ignore: deprecated_member_use
              groupValue: _currentSettings.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) async {
                if (value != null) {
                  await widget.settingsService.setThemeMode(value);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<AppThemeMode>(
              title: Text(loc.themeSystem),
              value: AppThemeMode.system,
              // ignore: deprecated_member_use
              groupValue: _currentSettings.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) async {
                if (value != null) {
                  await widget.settingsService.setThemeMode(value);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.resetSettings),
        content: Text(loc.resetSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () async {
              await widget.settingsService.resetToDefaults();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.settingsResetToDefaults)),
                );
              }
            },
            child: Text(loc.reset),
          ),
        ],
      ),
    );
  }
}