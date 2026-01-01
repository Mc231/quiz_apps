import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';

/// Template type for shareable images.
sealed class ShareImageTemplateType {
  const ShareImageTemplateType();

  /// Standard template with score display.
  factory ShareImageTemplateType.standard() = StandardShareTemplate;

  /// Template highlighting an unlocked achievement.
  factory ShareImageTemplateType.achievement({
    required String achievementName,
    String? achievementIcon,
  }) = AchievementShareTemplate;

  /// Special template for perfect scores.
  factory ShareImageTemplateType.perfectScore() = PerfectScoreShareTemplate;
}

/// Standard share template.
class StandardShareTemplate extends ShareImageTemplateType {
  const StandardShareTemplate();
}

/// Achievement share template.
class AchievementShareTemplate extends ShareImageTemplateType {
  const AchievementShareTemplate({
    required this.achievementName,
    this.achievementIcon,
  });

  /// Name of the achievement to display.
  final String achievementName;

  /// Optional icon for the achievement.
  final String? achievementIcon;
}

/// Perfect score share template.
class PerfectScoreShareTemplate extends ShareImageTemplateType {
  const PerfectScoreShareTemplate();
}

/// Configuration for share image template.
class ShareImageConfig {
  /// Creates a [ShareImageConfig].
  const ShareImageConfig({
    this.appName,
    this.appLogoAsset,
    this.categoryIcon,
    this.width = 1080,
    this.height = 1920,
    this.useDarkTheme,
    this.showQrCode = false,
    this.qrCodeData,
    this.customCallToAction,
  });

  /// App name to display on the image.
  final String? appName;

  /// Asset path for the app logo.
  final String? appLogoAsset;

  /// Widget to display as category icon.
  final Widget? categoryIcon;

  /// Width of the generated image in pixels.
  final double width;

  /// Height of the generated image in pixels.
  final double height;

  /// Whether to use dark theme. If null, follows system theme.
  final bool? useDarkTheme;

  /// Whether to show a QR code for app download.
  final bool showQrCode;

  /// Data to encode in QR code (e.g., app store URL).
  final String? qrCodeData;

  /// Custom call-to-action text.
  final String? customCallToAction;

  /// Aspect ratio of the image (width / height).
  double get aspectRatio => width / height;

  /// Creates a copy with the given fields replaced.
  ShareImageConfig copyWith({
    String? appName,
    String? appLogoAsset,
    Widget? categoryIcon,
    double? width,
    double? height,
    bool? useDarkTheme,
    bool? showQrCode,
    String? qrCodeData,
    String? customCallToAction,
  }) {
    return ShareImageConfig(
      appName: appName ?? this.appName,
      appLogoAsset: appLogoAsset ?? this.appLogoAsset,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      width: width ?? this.width,
      height: height ?? this.height,
      useDarkTheme: useDarkTheme ?? this.useDarkTheme,
      showQrCode: showQrCode ?? this.showQrCode,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      customCallToAction: customCallToAction ?? this.customCallToAction,
    );
  }
}

/// A widget that renders a shareable image template for quiz results.
///
/// This widget is designed to be captured as an image using
/// [ShareImageGenerator]. It displays the quiz score, category,
/// and other relevant information in an attractive format.
///
/// Example:
/// ```dart
/// ShareImageTemplate(
///   result: shareResult,
///   templateType: ShareImageTemplateType.standard(),
///   config: ShareImageConfig(
///     appName: 'Flags Quiz',
///     appLogoAsset: 'assets/logo.png',
///   ),
/// )
/// ```
class ShareImageTemplate extends StatelessWidget {
  /// Creates a [ShareImageTemplate].
  const ShareImageTemplate({
    super.key,
    required this.result,
    this.templateType = const StandardShareTemplate(),
    this.config = const ShareImageConfig(),
  });

  /// The quiz result data to display.
  final ShareResult result;

  /// The template type to use.
  final ShareImageTemplateType templateType;

  /// Configuration for the template.
  final ShareImageConfig config;

  @override
  Widget build(BuildContext context) {
    final isDark = config.useDarkTheme ??
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Theme(
      data: isDark ? _buildDarkTheme() : _buildLightTheme(),
      child: Builder(
        builder: (context) {
          return Container(
            width: config.width,
            height: config.height,
            decoration: BoxDecoration(
              gradient: _buildBackgroundGradient(context, isDark),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    // App branding
                    _buildHeader(context),
                    const Spacer(flex: 1),
                    // Main content based on template type
                    Expanded(
                      flex: 4,
                      child: _buildMainContent(context),
                    ),
                    const Spacer(flex: 1),
                    // Call to action
                    _buildCallToAction(context),
                    const SizedBox(height: 24),
                    // Footer with app name
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 120,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
        bodyLarge: TextStyle(
          fontSize: 24,
          color: Colors.black54,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 120,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyLarge: TextStyle(
          fontSize: 24,
          color: Colors.white70,
        ),
      ),
    );
  }

  LinearGradient _buildBackgroundGradient(BuildContext context, bool isDark) {
    return switch (templateType) {
      PerfectScoreShareTemplate() => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A237E),
                  const Color(0xFF311B92),
                  const Color(0xFF4A148C),
                ]
              : [
                  const Color(0xFFFFD700),
                  const Color(0xFFFFA500),
                  const Color(0xFFFF8C00),
                ],
        ),
      AchievementShareTemplate() => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1B5E20),
                  const Color(0xFF2E7D32),
                  const Color(0xFF388E3C),
                ]
              : [
                  const Color(0xFF81C784),
                  const Color(0xFF66BB6A),
                  const Color(0xFF4CAF50),
                ],
        ),
      StandardShareTemplate() => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0D47A1),
                  const Color(0xFF1565C0),
                  const Color(0xFF1976D2),
                ]
              : [
                  const Color(0xFF64B5F6),
                  const Color(0xFF42A5F5),
                  const Color(0xFF2196F3),
                ],
        ),
    };
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (config.appLogoAsset != null) ...[
          Image.asset(
            config.appLogoAsset!,
            width: 64,
            height: 64,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 16),
        ],
        if (config.appName != null)
          Text(
            config.appName!,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return switch (templateType) {
      PerfectScoreShareTemplate() => _buildPerfectScoreContent(context),
      AchievementShareTemplate(:final achievementName) =>
        _buildAchievementContent(context, achievementName),
      StandardShareTemplate() => _buildStandardContent(context),
    };
  }

  Widget _buildStandardContent(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizEngineLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Category name with icon
        if (config.categoryIcon != null) ...[
          SizedBox(
            width: 120,
            height: 120,
            child: config.categoryIcon,
          ),
          const SizedBox(height: 24),
        ],
        Text(
          result.categoryName,
          style: theme.textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        // Large score display
        _ScoreCircle(
          score: result.scorePercent,
          size: 280,
          strokeWidth: 16,
        ),
        const SizedBox(height: 32),
        // Questions answered
        Text(
          '${result.correctCount}/${result.totalCount} ${l10n?.correct ?? 'correct'}',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Mode badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            result.mode.toUpperCase(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerfectScoreContent(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizEngineLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Trophy/Star icon
        const Icon(
          Icons.emoji_events,
          size: 120,
          color: Colors.amber,
        ),
        const SizedBox(height: 24),
        // Perfect score text
        Text(
          l10n?.sharePerfectScore ?? 'PERFECT SCORE!',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Category
        Text(
          result.categoryName,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        // Score circle
        _ScoreCircle(
          score: 100,
          size: 240,
          strokeWidth: 16,
          isPerfect: true,
        ),
        const SizedBox(height: 32),
        // All questions correct
        Text(
          '${result.totalCount}/${result.totalCount} ${l10n?.correct ?? 'correct'}',
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildAchievementContent(
      BuildContext context, String achievementName) {
    final theme = Theme.of(context);
    final l10n = QuizEngineLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Achievement badge
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.military_tech,
            size: 96,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        // Achievement unlocked text
        Text(
          l10n?.shareAchievementUnlocked ?? 'ACHIEVEMENT UNLOCKED',
          style: theme.textTheme.titleLarge?.copyWith(
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Achievement name
        Text(
          achievementName,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: Colors.amber,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        // Score display (smaller)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ScoreCircle(
              score: result.scorePercent,
              size: 160,
              strokeWidth: 12,
            ),
            const SizedBox(width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.categoryName,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.correctCount}/${result.totalCount}',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizEngineLocalizations.of(context);

    final ctaText = config.customCallToAction ??
        l10n?.shareCallToAction ??
        'Can you beat my score?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Text(
        ctaText,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    if (config.appName == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          config.appName!,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Animated circular score display.
class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({
    required this.score,
    required this.size,
    this.strokeWidth = 12,
    this.isPerfect = false,
  });

  final int score;
  final double size;
  final double strokeWidth;
  final bool isPerfect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progressColor = isPerfect
        ? Colors.amber
        : _getScoreColor(score);

    final backgroundColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.1);

    // Calculate proportional font sizes based on circle size
    final scoreFontSize = size * 0.35;
    final percentFontSize = size * 0.15;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation(backgroundColor),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(progressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: scoreFontSize,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                  height: 1.0,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  fontSize: percentFontSize,
                  fontWeight: FontWeight.w500,
                  color: progressColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          // Glow effect for perfect scores
          if (isPerfect)
            Container(
              width: size - strokeWidth * 2,
              height: size - strokeWidth * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.lightGreen;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
