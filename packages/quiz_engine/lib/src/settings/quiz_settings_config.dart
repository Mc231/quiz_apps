import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

/// Configuration for which sections to show in the settings screen.
///
/// Note: The Quiz Behavior section with `showAnswerFeedback` toggle has been
/// removed. Answer feedback is now configured per-category/per-mode in
/// QuizCategory and QuizModeConfig.
class QuizSettingsConfig {
  /// Whether to show the Audio & Haptics section.
  final bool showAudioHapticsSection;

  /// Whether to show the sound effects toggle.
  final bool showSoundEffects;

  /// Whether to show the haptic feedback toggle.
  final bool showHapticFeedback;

  /// Whether to show the Appearance section.
  final bool showAppearanceSection;

  /// Whether to show the theme selector.
  final bool showThemeSelector;

  /// Whether to show the About section.
  final bool showAboutSection;

  /// Whether to show the about dialog item.
  final bool showAboutDialog;

  /// Whether to show the licenses item.
  final bool showLicenses;

  /// The URL to open when Privacy Policy is tapped.
  ///
  /// If null, the Privacy Policy item won't be shown.
  final String? privacyPolicyUrl;

  /// The URL to open when Terms of Service is tapped.
  ///
  /// If null, the Terms of Service item won't be shown.
  final String? termsOfServiceUrl;

  /// Whether to show the Advanced section.
  final bool showAdvancedSection;

  /// Whether to show the reset to defaults item.
  final bool showResetToDefaults;

  /// Whether to show the Data Export section.
  ///
  /// When enabled, shows a tile that allows users to export all their data
  /// to a JSON file (GDPR compliance). The service is created internally
  /// using the service locator.
  final bool showDataExport;

  /// Whether to show the Shop section.
  ///
  /// When enabled, shows:
  /// - Remove Ads purchase option (if enabled)
  /// - Bundle packs (if enabled)
  /// - Restore Purchases button (if enabled)
  ///
  /// Requires [IAPService] to be available via [QuizServicesProvider].
  final bool showShopSection;

  /// Whether to show the Remove Ads purchase option.
  ///
  /// Only shown if [showShopSection] is also true.
  /// Shows a tile to purchase "remove_ads" non-consumable product.
  final bool showRemoveAds;

  /// Whether to show bundle packs in the shop.
  ///
  /// Only shown if [showShopSection] is also true.
  /// Shows starter, value, and pro bundle cards.
  final bool showBundles;

  /// Whether to show the Restore Purchases button.
  ///
  /// Only shown if [showShopSection] is also true.
  /// Allows users to restore previous purchases.
  final bool showRestorePurchases;

  /// Whether to show the Account section.
  ///
  /// When enabled, shows:
  /// - Game service account (Game Center/Play Games)
  /// - Cloud sync status and controls
  /// - View Achievements/Leaderboards buttons
  ///
  /// Requires [GameService] and [CloudSaveService] to be provided.
  final bool showAccountSection;

  /// Whether to show the game service account tile.
  ///
  /// Only shown if [showAccountSection] is also true.
  final bool showGameServiceAccount;

  /// Whether to show the cloud sync tile.
  ///
  /// Only shown if [showAccountSection] is also true.
  final bool showCloudSync;

  /// Whether to show the View Achievements button.
  ///
  /// Only shown if [showAccountSection] is also true.
  /// Opens native achievements UI.
  final bool showViewAchievements;

  /// Whether to show the View Leaderboards button.
  ///
  /// Only shown if [showAccountSection] is also true.
  /// Opens native leaderboards UI.
  final bool showViewLeaderboards;

  /// Game service for account management.
  ///
  /// Required when [showAccountSection] is true.
  final GameService? gameService;

  /// Cloud save service for sync management.
  ///
  /// Required when [showCloudSync] is true.
  final CloudSaveService? cloudSaveService;

  /// Cloud achievement service for viewing achievements.
  ///
  /// Required when [showViewAchievements] is true.
  final CloudAchievementService? cloudAchievementService;

  /// Leaderboard service for viewing leaderboards.
  ///
  /// Required when [showViewLeaderboards] is true.
  final LeaderboardService? leaderboardService;

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
    this.showHapticFeedback = true,
    this.showAppearanceSection = true,
    this.showThemeSelector = true,
    this.showAboutSection = true,
    this.showAboutDialog = true,
    this.showLicenses = true,
    this.privacyPolicyUrl,
    this.termsOfServiceUrl,
    this.showAdvancedSection = true,
    this.showResetToDefaults = true,
    this.showDataExport = false,
    this.showShopSection = true,
    this.showRemoveAds = true,
    this.showBundles = true,
    this.showRestorePurchases = true,
    this.showAccountSection = false,
    this.showGameServiceAccount = true,
    this.showCloudSync = true,
    this.showViewAchievements = true,
    this.showViewLeaderboards = true,
    this.gameService,
    this.cloudSaveService,
    this.cloudAchievementService,
    this.leaderboardService,
    this.showAppBar = true,
    this.title,
    this.customSections,
    this.customSectionsBeforeAbout,
  });

  /// Creates a minimal configuration with only essential settings.
  const QuizSettingsConfig.minimal()
      : showAudioHapticsSection = true,
        showSoundEffects = true,
        showHapticFeedback = true,
        showAppearanceSection = true,
        showThemeSelector = true,
        showAboutSection = false,
        showAboutDialog = false,
        showLicenses = false,
        privacyPolicyUrl = null,
        termsOfServiceUrl = null,
        showAdvancedSection = false,
        showResetToDefaults = false,
        showDataExport = false,
        showShopSection = false,
        showRemoveAds = false,
        showBundles = false,
        showRestorePurchases = false,
        showAccountSection = false,
        showGameServiceAccount = false,
        showCloudSync = false,
        showViewAchievements = false,
        showViewLeaderboards = false,
        gameService = null,
        cloudSaveService = null,
        cloudAchievementService = null,
        leaderboardService = null,
        showAppBar = true,
        title = null,
        customSections = null,
        customSectionsBeforeAbout = null;

  /// Creates a copy with the given fields replaced.
  QuizSettingsConfig copyWith({
    bool? showAudioHapticsSection,
    bool? showSoundEffects,
    bool? showHapticFeedback,
    bool? showAppearanceSection,
    bool? showThemeSelector,
    bool? showAboutSection,
    bool? showAboutDialog,
    bool? showLicenses,
    String? privacyPolicyUrl,
    String? termsOfServiceUrl,
    bool? showAdvancedSection,
    bool? showResetToDefaults,
    bool? showDataExport,
    bool? showShopSection,
    bool? showRemoveAds,
    bool? showBundles,
    bool? showRestorePurchases,
    bool? showAccountSection,
    bool? showGameServiceAccount,
    bool? showCloudSync,
    bool? showViewAchievements,
    bool? showViewLeaderboards,
    GameService? gameService,
    CloudSaveService? cloudSaveService,
    CloudAchievementService? cloudAchievementService,
    LeaderboardService? leaderboardService,
    bool? showAppBar,
    String? title,
    List<Widget> Function(BuildContext context)? customSections,
    List<Widget> Function(BuildContext context)? customSectionsBeforeAbout,
  }) {
    return QuizSettingsConfig(
      showAudioHapticsSection:
          showAudioHapticsSection ?? this.showAudioHapticsSection,
      showSoundEffects: showSoundEffects ?? this.showSoundEffects,
      showHapticFeedback: showHapticFeedback ?? this.showHapticFeedback,
      showAppearanceSection:
          showAppearanceSection ?? this.showAppearanceSection,
      showThemeSelector: showThemeSelector ?? this.showThemeSelector,
      showAboutSection: showAboutSection ?? this.showAboutSection,
      showAboutDialog: showAboutDialog ?? this.showAboutDialog,
      showLicenses: showLicenses ?? this.showLicenses,
      privacyPolicyUrl: privacyPolicyUrl ?? this.privacyPolicyUrl,
      termsOfServiceUrl: termsOfServiceUrl ?? this.termsOfServiceUrl,
      showAdvancedSection: showAdvancedSection ?? this.showAdvancedSection,
      showResetToDefaults: showResetToDefaults ?? this.showResetToDefaults,
      showDataExport: showDataExport ?? this.showDataExport,
      showShopSection: showShopSection ?? this.showShopSection,
      showRemoveAds: showRemoveAds ?? this.showRemoveAds,
      showBundles: showBundles ?? this.showBundles,
      showRestorePurchases: showRestorePurchases ?? this.showRestorePurchases,
      showAccountSection: showAccountSection ?? this.showAccountSection,
      showGameServiceAccount:
          showGameServiceAccount ?? this.showGameServiceAccount,
      showCloudSync: showCloudSync ?? this.showCloudSync,
      showViewAchievements: showViewAchievements ?? this.showViewAchievements,
      showViewLeaderboards: showViewLeaderboards ?? this.showViewLeaderboards,
      gameService: gameService ?? this.gameService,
      cloudSaveService: cloudSaveService ?? this.cloudSaveService,
      cloudAchievementService:
          cloudAchievementService ?? this.cloudAchievementService,
      leaderboardService: leaderboardService ?? this.leaderboardService,
      showAppBar: showAppBar ?? this.showAppBar,
      title: title ?? this.title,
      customSections: customSections ?? this.customSections,
      customSectionsBeforeAbout:
          customSectionsBeforeAbout ?? this.customSectionsBeforeAbout,
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
