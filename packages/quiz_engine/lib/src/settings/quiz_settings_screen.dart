import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Source identifier for settings analytics events.
const String _settingsSource = 'settings_screen';

/// A configurable settings screen for quiz apps.
///
/// Uses [SettingsService] from [QuizServicesProvider] for persistence
/// and [QuizLocalizations] for all text.
///
/// Services are obtained from [QuizServicesProvider] via context.
///
/// Example:
/// ```dart
/// QuizSettingsScreen(
///   config: const QuizSettingsConfig(),
/// )
/// ```
class QuizSettingsScreen extends StatefulWidget {
  /// Configuration for which sections to show.
  final QuizSettingsConfig config;

  /// Optional app name override for about dialog.
  final String? appName;

  /// Creates a [QuizSettingsScreen].
  const QuizSettingsScreen({
    super.key,
    this.config = const QuizSettingsConfig(),
    this.appName,
  });

  @override
  State<QuizSettingsScreen> createState() => _QuizSettingsScreenState();
}

class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
  late QuizSettings _currentSettings;
  PackageInfo? _packageInfo;
  bool _isInitialized = false;

  /// Gets the settings service from context.
  SettingsService get _settingsService => context.settingsService;

  /// Gets the analytics service from context.
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeSettings();
      _logScreenView();
    }
  }

  void _initializeSettings() {
    _currentSettings = _settingsService.currentSettings;
    _settingsService.settingsStream.listen((settings) {
      if (mounted) {
        setState(() {
          _currentSettings = settings;
        });
      }
    });
  }

  void _logScreenView() {
    _analyticsService.logEvent(ScreenViewEvent.settings());
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
              await _settingsService.toggleSound();
              _analyticsService.logEvent(
                SettingsEvent.soundEffectsToggled(
                  enabled: value,
                  source: _settingsSource,
                ),
              );
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
              await _settingsService.toggleHaptic();
              _analyticsService.logEvent(
                SettingsEvent.hapticFeedbackToggled(
                  enabled: value,
                  source: _settingsSource,
                ),
              );
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

    // Data Export section
    if (widget.config.showDataExport) {
      widgets.add(_buildSectionHeader(l10n.dataAndPrivacy));
      widgets.add(_buildExportDataTile());
      widgets.add(const Divider());
    }

    // Shop section
    if (widget.config.showShopSection && _hasShopItems()) {
      widgets.add(_buildSectionHeader(l10n.shop));

      if (widget.config.showRemoveAds) {
        widgets.add(const RemoveAdsTile());
      }

      if (widget.config.showBundles) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.bundles,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        );
        // Build bundle cards dynamically from config
        final bundlePacks = context.resourceManager.config.bundlePacks;
        for (final bundle in bundlePacks) {
          widgets.add(
            BundlePackCard(
              productId: bundle.productId,
              title: bundle.name,
              description: bundle.description ?? '',
            ),
          );
        }
        widgets.add(const SizedBox(height: 8));
      }

      if (widget.config.showRestorePurchases) {
        widgets.add(const RestorePurchasesTile());
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

      if (widget.config.privacyPolicyUrl != null) {
        widgets.add(
          ListTile(
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.privacy_tip_outlined),
            onTap: () => _launchUrl(widget.config.privacyPolicyUrl!),
          ),
        );
      }

      if (widget.config.termsOfServiceUrl != null) {
        widgets.add(
          ListTile(
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.article_outlined),
            onTap: () => _launchUrl(widget.config.termsOfServiceUrl!),
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
        widget.config.showHapticFeedback;
  }

  bool _hasAppearanceItems() {
    return widget.config.showThemeSelector;
  }

  bool _hasAboutItems() {
    return (widget.config.showVersionInfo && _packageInfo != null) ||
        widget.config.showAboutDialog ||
        widget.config.showLicenses ||
        widget.config.privacyPolicyUrl != null ||
        widget.config.termsOfServiceUrl != null;
  }

  bool _hasAdvancedItems() {
    return widget.config.showResetToDefaults;
  }

  bool _hasShopItems() {
    return widget.config.showRemoveAds ||
        widget.config.showBundles ||
        widget.config.showRestorePurchases;
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

  Widget _buildExportDataTile() {
    // Create DataExportService using service locator
    final exportService = DataExportService(
      sessionDataSource: sl.get<QuizSessionDataSource>(),
      answerDataSource: sl.get<QuestionAnswerDataSource>(),
      statisticsDataSource: sl.get<StatisticsDataSource>(),
      settingsDataSource: sl.get<SettingsDataSource>(),
    );

    return ExportDataTile(
      exportService: exportService,
      config: const ExportDataTileConfig(showIcon: false),
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
    final previousTheme = _currentSettings.themeMode;
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
                await _settingsService.setThemeMode(value);
                _analyticsService.logEvent(
                  SettingsEvent.themeChanged(
                    newTheme: value.name,
                    previousTheme: previousTheme.name,
                    source: _settingsSource,
                  ),
                );
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
    // Track about screen view
    _analyticsService.logEvent(
      ScreenViewEvent.about(
        appVersion: _packageInfo?.version ?? 'unknown',
        buildNumber: _packageInfo?.buildNumber ?? 'unknown',
      ),
    );

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
    // Track licenses screen view
    _analyticsService.logEvent(ScreenViewEvent.licenses());

    showLicensePage(
      context: context,
      applicationName: widget.appName ?? _packageInfo?.appName,
      applicationVersion: _packageInfo?.version,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
              await _settingsService.resetToDefaults();
              _analyticsService.logEvent(
                SettingsEvent.resetConfirmed(
                  resetType: 'settings_only',
                  sessionsDeleted: 0,
                  achievementsReset: 0,
                ),
              );
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

/// A stateless content widget for settings screen.
///
/// This widget receives all data and callbacks externally, making it
/// suitable for use with a BLoC pattern via [SettingsBuilder].
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
///
/// Example:
/// ```dart
/// SettingsBuilder(
///   bloc: settingsBloc,
///   builder: (context, state) => SettingsContent(
///     settings: state.settings,
///     packageInfo: state.packageInfo,
///     config: config,
///     onToggleSound: () => bloc.add(SettingsEvent.toggleSound()),
///     onToggleHaptic: () => bloc.add(SettingsEvent.toggleHaptic()),
///     onChangeTheme: (theme) => bloc.add(SettingsEvent.changeTheme(theme)),
///     onResetToDefaults: () => bloc.add(SettingsEvent.resetToDefaults()),
///   ),
/// )
/// ```
class SettingsContent extends StatelessWidget {
  /// Creates a [SettingsContent].
  const SettingsContent({
    super.key,
    required this.settings,
    this.packageInfo,
    this.config = const QuizSettingsConfig(),
    this.appName,
    this.onToggleSound,
    this.onToggleHaptic,
    this.onChangeTheme,
    this.onResetToDefaults,
  });

  /// The current settings.
  final QuizSettings settings;

  /// Package info for version display.
  final PackageInfo? packageInfo;

  /// Configuration for which sections to show.
  final QuizSettingsConfig config;

  /// Optional app name override for about dialog.
  final String? appName;

  /// Callback when sound is toggled.
  final VoidCallback? onToggleSound;

  /// Callback when haptic is toggled.
  final VoidCallback? onToggleHaptic;

  /// Callback when theme is changed.
  final void Function(AppThemeMode theme)? onChangeTheme;

  /// Callback when reset to defaults is confirmed.
  final VoidCallback? onResetToDefaults;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    final body = ListView(
      children: _buildSettingsList(context, l10n),
    );

    if (!config.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(config.title ?? l10n.settings),
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
    if (config.showAudioHapticsSection && _hasAudioHapticsItems()) {
      widgets.add(_buildSectionHeader(context, l10n.audioAndHaptics));

      if (config.showSoundEffects) {
        widgets.add(
          SwitchListTile(
            title: Text(l10n.soundEffects),
            subtitle: Text(l10n.soundEffectsDescription),
            value: settings.soundEnabled,
            onChanged: onToggleSound != null
                ? (value) {
                    onToggleSound!();
                    context.screenAnalyticsService.logEvent(
                      SettingsEvent.soundEffectsToggled(
                        enabled: value,
                        source: _settingsSource,
                      ),
                    );
                  }
                : null,
          ),
        );
      }

      if (config.showHapticFeedback) {
        widgets.add(
          SwitchListTile(
            title: Text(l10n.hapticFeedback),
            subtitle: Text(l10n.hapticFeedbackDescription),
            value: settings.hapticEnabled,
            onChanged: onToggleHaptic != null
                ? (value) {
                    onToggleHaptic!();
                    context.screenAnalyticsService.logEvent(
                      SettingsEvent.hapticFeedbackToggled(
                        enabled: value,
                        source: _settingsSource,
                      ),
                    );
                  }
                : null,
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Appearance Section
    if (config.showAppearanceSection && _hasAppearanceItems()) {
      widgets.add(_buildSectionHeader(context, l10n.appearance));

      if (config.showThemeSelector) {
        widgets.add(
          ListTile(
            title: Text(l10n.theme),
            subtitle: Text(_getThemeModeText(settings.themeMode, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, l10n),
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Data Export section
    if (config.showDataExport) {
      widgets.add(_buildSectionHeader(context, l10n.dataAndPrivacy));
      widgets.add(_buildExportDataTile());
      widgets.add(const Divider());
    }

    // Shop section
    if (config.showShopSection && _hasShopItems()) {
      widgets.add(_buildSectionHeader(context, l10n.shop));

      if (config.showRemoveAds) {
        widgets.add(const RemoveAdsTile());
      }

      if (config.showBundles) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.bundles,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        );
        // Build bundle cards dynamically from config
        final bundlePacks = context.resourceManager.config.bundlePacks;
        for (final bundle in bundlePacks) {
          widgets.add(
            BundlePackCard(
              productId: bundle.productId,
              title: bundle.name,
              description: bundle.description ?? '',
            ),
          );
        }
        widgets.add(const SizedBox(height: 8));
      }

      if (config.showRestorePurchases) {
        widgets.add(const RestorePurchasesTile());
      }

      widgets.add(const Divider());
    }

    // Custom sections before About
    if (config.customSectionsBeforeAbout != null) {
      widgets.addAll(config.customSectionsBeforeAbout!(context));
    }

    // About Section
    if (config.showAboutSection && _hasAboutItems()) {
      widgets.add(_buildSectionHeader(context, l10n.about));

      if (config.showVersionInfo && packageInfo != null) {
        widgets.add(
          ListTile(
            title: Text(l10n.version),
            subtitle: Text(
              '${packageInfo!.version} (${packageInfo!.buildNumber})',
            ),
          ),
        );
      }

      if (config.showAboutDialog) {
        widgets.add(
          ListTile(
            title: Text(l10n.aboutThisApp),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showAboutDialog(context, l10n),
          ),
        );
      }

      if (config.showLicenses) {
        widgets.add(
          ListTile(
            title: Text(l10n.openSourceLicenses),
            trailing: const Icon(Icons.description_outlined),
            onTap: () => _showLicenses(context),
          ),
        );
      }

      if (config.privacyPolicyUrl != null) {
        widgets.add(
          ListTile(
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.privacy_tip_outlined),
            onTap: () => _launchUrl(config.privacyPolicyUrl!),
          ),
        );
      }

      if (config.termsOfServiceUrl != null) {
        widgets.add(
          ListTile(
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.article_outlined),
            onTap: () => _launchUrl(config.termsOfServiceUrl!),
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Advanced Section
    if (config.showAdvancedSection && _hasAdvancedItems()) {
      widgets.add(_buildSectionHeader(context, l10n.advanced));

      if (config.showResetToDefaults) {
        widgets.add(
          ListTile(
            title: Text(l10n.resetToDefaults),
            subtitle: Text(l10n.resetToDefaultsDescription),
            trailing: const Icon(Icons.restore),
            onTap: () => _showResetDialog(context, l10n),
          ),
        );
      }

      widgets.add(const Divider());
    }

    // Custom sections at the end
    if (config.customSections != null) {
      widgets.addAll(config.customSections!(context));
    }

    return widgets;
  }

  bool _hasAudioHapticsItems() {
    return config.showSoundEffects ||
        config.showHapticFeedback;
  }

  bool _hasAppearanceItems() {
    return config.showThemeSelector;
  }

  bool _hasAboutItems() {
    return (config.showVersionInfo && packageInfo != null) ||
        config.showAboutDialog ||
        config.showLicenses ||
        config.privacyPolicyUrl != null ||
        config.termsOfServiceUrl != null;
  }

  bool _hasAdvancedItems() {
    return config.showResetToDefaults;
  }

  bool _hasShopItems() {
    return config.showRemoveAds ||
        config.showBundles ||
        config.showRestorePurchases;
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildExportDataTile() {
    // Create DataExportService using service locator
    final exportService = DataExportService(
      sessionDataSource: sl.get<QuizSessionDataSource>(),
      answerDataSource: sl.get<QuestionAnswerDataSource>(),
      statisticsDataSource: sl.get<StatisticsDataSource>(),
      settingsDataSource: sl.get<SettingsDataSource>(),
    );

    return ExportDataTile(
      exportService: exportService,
      config: const ExportDataTileConfig(showIcon: false),
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

  void _showThemeDialog(BuildContext context, QuizLocalizations l10n) {
    final previousTheme = settings.themeMode;
    final analyticsService = context.screenAnalyticsService;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<AppThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value == null) return;
                onChangeTheme?.call(value);
                analyticsService.logEvent(
                  SettingsEvent.themeChanged(
                    newTheme: value.name,
                    previousTheme: previousTheme.name,
                    source: _settingsSource,
                  ),
                );
                Navigator.pop(dialogContext);
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, QuizLocalizations l10n) {
    // Track about screen view
    context.screenAnalyticsService.logEvent(
      ScreenViewEvent.about(
        appVersion: packageInfo?.version ?? 'unknown',
        buildNumber: packageInfo?.buildNumber ?? 'unknown',
      ),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.about),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (packageInfo != null) ...[
                Text(
                  appName ?? packageInfo!.appName,
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('${l10n.version}: ${packageInfo!.version}'),
                Text('${l10n.build}: ${packageInfo!.buildNumber}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    // Track licenses screen view
    context.screenAnalyticsService.logEvent(ScreenViewEvent.licenses());

    showLicensePage(
      context: context,
      applicationName: appName ?? packageInfo?.appName,
      applicationVersion: packageInfo?.version,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showResetDialog(BuildContext context, QuizLocalizations l10n) {
    final analyticsService = context.screenAnalyticsService;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              onResetToDefaults?.call();
              analyticsService.logEvent(
                SettingsEvent.resetConfirmed(
                  resetType: 'settings_only',
                  sessionsDeleted: 0,
                  achievementsReset: 0,
                ),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsResetToDefaults)),
              );
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}
