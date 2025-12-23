import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';

/// Configuration for which sections to show in the settings screen.
class QuizSettingsConfig {
  /// Whether to show the Audio & Haptics section.
  final bool showAudioHapticsSection;

  /// Whether to show the sound effects toggle.
  final bool showSoundEffects;

  /// Whether to show the background music toggle.
  final bool showBackgroundMusic;

  /// Whether to show the haptic feedback toggle.
  final bool showHapticFeedback;

  /// Whether to show the Quiz Behavior section.
  final bool showQuizBehaviorSection;

  /// Whether to show the answer feedback toggle.
  final bool showAnswerFeedback;

  /// Whether to show the Appearance section.
  final bool showAppearanceSection;

  /// Whether to show the theme selector.
  final bool showThemeSelector;

  /// Whether to show the About section.
  final bool showAboutSection;

  /// Whether to show the version info.
  final bool showVersionInfo;

  /// Whether to show the about dialog item.
  final bool showAboutDialog;

  /// Whether to show the licenses item.
  final bool showLicenses;

  /// Whether to show the Advanced section.
  final bool showAdvancedSection;

  /// Whether to show the reset to defaults item.
  final bool showResetToDefaults;

  /// Whether to show the app bar.
  final bool showAppBar;

  /// Custom app bar title. If null, uses localized "Settings".
  final String? title;

  /// Custom sections to add at the end of the settings list.
  final List<Widget> Function(BuildContext context)? customSections;

  /// Custom sections to add before the About section.
  final List<Widget> Function(BuildContext context)? customSectionsBeforeAbout;

  /// Creates a [QuizSettingsConfig].
  const QuizSettingsConfig({
    this.showAudioHapticsSection = true,
    this.showSoundEffects = true,
    this.showBackgroundMusic = true,
    this.showHapticFeedback = true,
    this.showQuizBehaviorSection = true,
    this.showAnswerFeedback = true,
    this.showAppearanceSection = true,
    this.showThemeSelector = true,
    this.showAboutSection = true,
    this.showVersionInfo = true,
    this.showAboutDialog = true,
    this.showLicenses = true,
    this.showAdvancedSection = true,
    this.showResetToDefaults = true,
    this.showAppBar = true,
    this.title,
    this.customSections,
    this.customSectionsBeforeAbout,
  });

  /// Creates a minimal configuration with only essential settings.
  const QuizSettingsConfig.minimal()
      : showAudioHapticsSection = true,
        showSoundEffects = true,
        showBackgroundMusic = false,
        showHapticFeedback = true,
        showQuizBehaviorSection = false,
        showAnswerFeedback = false,
        showAppearanceSection = true,
        showThemeSelector = true,
        showAboutSection = false,
        showVersionInfo = false,
        showAboutDialog = false,
        showLicenses = false,
        showAdvancedSection = false,
        showResetToDefaults = false,
        showAppBar = true,
        title = null,
        customSections = null,
        customSectionsBeforeAbout = null;

  /// Creates a copy with the given fields replaced.
  QuizSettingsConfig copyWith({
    bool? showAudioHapticsSection,
    bool? showSoundEffects,
    bool? showBackgroundMusic,
    bool? showHapticFeedback,
    bool? showQuizBehaviorSection,
    bool? showAnswerFeedback,
    bool? showAppearanceSection,
    bool? showThemeSelector,
    bool? showAboutSection,
    bool? showVersionInfo,
    bool? showAboutDialog,
    bool? showLicenses,
    bool? showAdvancedSection,
    bool? showResetToDefaults,
    bool? showAppBar,
    String? title,
    List<Widget> Function(BuildContext context)? customSections,
    List<Widget> Function(BuildContext context)? customSectionsBeforeAbout,
  }) {
    return QuizSettingsConfig(
      showAudioHapticsSection:
          showAudioHapticsSection ?? this.showAudioHapticsSection,
      showSoundEffects: showSoundEffects ?? this.showSoundEffects,
      showBackgroundMusic: showBackgroundMusic ?? this.showBackgroundMusic,
      showHapticFeedback: showHapticFeedback ?? this.showHapticFeedback,
      showQuizBehaviorSection:
          showQuizBehaviorSection ?? this.showQuizBehaviorSection,
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
      showAppearanceSection:
          showAppearanceSection ?? this.showAppearanceSection,
      showThemeSelector: showThemeSelector ?? this.showThemeSelector,
      showAboutSection: showAboutSection ?? this.showAboutSection,
      showVersionInfo: showVersionInfo ?? this.showVersionInfo,
      showAboutDialog: showAboutDialog ?? this.showAboutDialog,
      showLicenses: showLicenses ?? this.showLicenses,
      showAdvancedSection: showAdvancedSection ?? this.showAdvancedSection,
      showResetToDefaults: showResetToDefaults ?? this.showResetToDefaults,
      showAppBar: showAppBar ?? this.showAppBar,
      title: title ?? this.title,
      customSections: customSections ?? this.customSections,
      customSectionsBeforeAbout:
          customSectionsBeforeAbout ?? this.customSectionsBeforeAbout,
    );
  }
}

/// A configurable settings screen for quiz apps.
///
/// Uses [SettingsService] from shared_services for persistence
/// and [QuizLocalizations] for all text.
///
/// Example:
/// ```dart
/// QuizSettingsScreen(
///   settingsService: settingsService,
///   config: const QuizSettingsConfig(),
/// )
/// ```
class QuizSettingsScreen extends StatefulWidget {
  /// The settings service for reading and updating settings.
  final SettingsService settingsService;

  /// Configuration for which sections to show.
  final QuizSettingsConfig config;

  /// Optional app name override for about dialog.
  final String? appName;

  /// Creates a [QuizSettingsScreen].
  const QuizSettingsScreen({
    super.key,
    required this.settingsService,
    this.config = const QuizSettingsConfig(),
    this.appName,
  });

  @override
  State<QuizSettingsScreen> createState() => _QuizSettingsScreenState();
}

class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
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
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
        });
      }
    } catch (e) {
      // Package info not available
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    final body = ListView(
      children: _buildSettingsList(context, l10n),
    );

    if (!widget.config.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.title ?? l10n.settings),
      ),
      body: body,
    );
  }

  List<Widget> _buildSettingsList(
    BuildContext context,
    QuizLocalizations l10n,
  ) {
    final widgets = <Widget>[];

    // Audio & Haptics Section
    if (widget.config.showAudioHapticsSection && _hasAudioHapticsItems()) {
      widgets.add(_buildSectionHeader(l10n.audioAndHaptics));

      if (widget.config.showSoundEffects) {
        widgets.add(
          SwitchListTile(
            title: Text(l10n.soundEffects),
            subtitle: Text(l10n.soundEffectsDescription),
            value: _currentSettings.soundEnabled,
            onChanged: (value) async {
              await widget.settingsService.toggleSound();
            },
          ),
        );
      }

      if (widget.config.showBackgroundMusic) {
        widgets.add(
          SwitchListTile(
            title: Text(l10n.backgroundMusic),
            subtitle: Text(l10n.backgroundMusicDescription),
            value: _currentSettings.musicEnabled,
            onChanged: (value) async {
              await widget.settingsService.toggleMusic();
            },
          ),
        );
      }

      if (widget.config.showHapticFeedback) {
        widgets.add(
          SwitchListTile(
            title: Text(l10n.hapticFeedback),
            subtitle: Text(l10n.hapticFeedbackDescription),
            value: _currentSettings.hapticEnabled,
            onChanged: (value) async {
              await widget.settingsService.toggleHaptic();
            },
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Quiz Behavior Section
    if (widget.config.showQuizBehaviorSection && _hasQuizBehaviorItems()) {
      widgets.add(_buildSectionHeader(l10n.quizBehavior));

      if (widget.config.showAnswerFeedback) {
        widgets.add(
          SwitchListTile(
            title: Text(l10n.showAnswerFeedback),
            subtitle: Text(l10n.showAnswerFeedbackDescription),
            value: _currentSettings.showAnswerFeedback,
            onChanged: (value) async {
              await widget.settingsService.toggleAnswerFeedback();
            },
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Appearance Section
    if (widget.config.showAppearanceSection && _hasAppearanceItems()) {
      widgets.add(_buildSectionHeader(l10n.appearance));

      if (widget.config.showThemeSelector) {
        widgets.add(
          ListTile(
            title: Text(l10n.theme),
            subtitle: Text(_getThemeModeText(_currentSettings.themeMode, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(l10n),
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Custom sections before About
    if (widget.config.customSectionsBeforeAbout != null) {
      widgets.addAll(widget.config.customSectionsBeforeAbout!(context));
    }

    // About Section
    if (widget.config.showAboutSection && _hasAboutItems()) {
      widgets.add(_buildSectionHeader(l10n.about));

      if (widget.config.showVersionInfo && _packageInfo != null) {
        widgets.add(
          ListTile(
            title: Text(l10n.version),
            subtitle: Text(
              '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
            ),
          ),
        );
      }

      if (widget.config.showAboutDialog) {
        widgets.add(
          ListTile(
            title: Text(l10n.aboutThisApp),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showAboutDialog(l10n),
          ),
        );
      }

      if (widget.config.showLicenses) {
        widgets.add(
          ListTile(
            title: Text(l10n.openSourceLicenses),
            trailing: const Icon(Icons.description_outlined),
            onTap: _showLicenses,
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Advanced Section
    if (widget.config.showAdvancedSection && _hasAdvancedItems()) {
      widgets.add(_buildSectionHeader(l10n.advanced));

      if (widget.config.showResetToDefaults) {
        widgets.add(
          ListTile(
            title: Text(l10n.resetToDefaults),
            subtitle: Text(l10n.resetToDefaultsDescription),
            trailing: const Icon(Icons.restore),
            onTap: () => _showResetDialog(l10n),
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Custom sections at the end
    if (widget.config.customSections != null) {
      widgets.addAll(widget.config.customSections!(context));
    }

    return widgets;
  }

  bool _hasAudioHapticsItems() {
    return widget.config.showSoundEffects ||
        widget.config.showBackgroundMusic ||
        widget.config.showHapticFeedback;
  }

  bool _hasQuizBehaviorItems() {
    return widget.config.showAnswerFeedback;
  }

  bool _hasAppearanceItems() {
    return widget.config.showThemeSelector;
  }

  bool _hasAboutItems() {
    return (widget.config.showVersionInfo && _packageInfo != null) ||
        widget.config.showAboutDialog ||
        widget.config.showLicenses;
  }

  bool _hasAdvancedItems() {
    return widget.config.showResetToDefaults;
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

  String _getThemeModeText(AppThemeMode mode, QuizLocalizations l10n) {
    switch (mode) {
      case AppThemeMode.light:
        return l10n.themeLight;
      case AppThemeMode.dark:
        return l10n.themeDark;
      case AppThemeMode.system:
        return l10n.themeSystem;
    }
  }

  void _showThemeDialog(QuizLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<AppThemeMode>(
              groupValue: _currentSettings.themeMode,
              onChanged: (value) async {
                if (value == null) return;
                await widget.settingsService.setThemeMode(value);
                if (mounted) Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeLight),
                    value: AppThemeMode.light,
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeDark),
                    value: AppThemeMode.dark,
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeSystem),
                    value: AppThemeMode.system,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(QuizLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_packageInfo != null) ...[
                Text(
                  widget.appName ?? _packageInfo!.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('${l10n.version}: ${_packageInfo!.version}'),
                Text('${l10n.build}: ${_packageInfo!.buildNumber}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: widget.appName ?? _packageInfo?.appName,
      applicationVersion: _packageInfo?.version,
    );
  }

  void _showResetDialog(QuizLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await widget.settingsService.resetToDefaults();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settingsResetToDefaults)),
                );
              }
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}

/// A helper widget for building custom settings sections.
///
/// Example:
/// ```dart
/// SettingsSection(
///   header: 'My Custom Section',
///   children: [
///     SwitchListTile(...),
///     ListTile(...),
///   ],
/// )
/// ```
class SettingsSection extends StatelessWidget {
  /// The section header text.
  final String header;

  /// The settings items in this section.
  final List<Widget> children;

  /// Whether to show a divider after the section.
  final bool showDivider;

  /// Creates a [SettingsSection].
  const SettingsSection({
    super.key,
    required this.header,
    required this.children,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            header,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        if (showDivider) const Divider(),
      ],
    );
  }
}
