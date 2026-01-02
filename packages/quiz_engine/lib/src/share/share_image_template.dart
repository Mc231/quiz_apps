import 'dart:math' as math;

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

/// Text style with shadow for better visibility on gradients.
TextStyle _shadowedTextStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.bold,
  Color color = Colors.white,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    shadows: const [
      Shadow(
        color: Colors.black45,
        blurRadius: 8,
        offset: Offset(2, 2),
      ),
      Shadow(
        color: Colors.black26,
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );
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
    return Container(
      width: config.width,
      height: config.height,
      decoration: BoxDecoration(
        gradient: _buildBackgroundGradient(),
      ),
      child: Stack(
        children: [
          // Decorative background elements
          _buildBackgroundDecorations(),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
              child: Column(
                children: [
                  // App branding at top
                  _buildHeader(context),
                  const SizedBox(height: 48),
                  // Main content based on template type
                  Expanded(
                    child: _buildMainContent(context),
                  ),
                  const SizedBox(height: 32),
                  // Call to action
                  _buildCallToAction(context),
                  const SizedBox(height: 32),
                  // Footer with app name
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _buildBackgroundGradient() {
    return switch (templateType) {
      PerfectScoreShareTemplate() => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E),
            Color(0xFF283593),
            Color(0xFF3949AB),
          ],
        ),
      AchievementShareTemplate() => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF43A047),
          ],
        ),
      StandardShareTemplate() => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1565C0),
            Color(0xFF1976D2),
          ],
        ),
    };
  }

  Widget _buildBackgroundDecorations() {
    final random = math.Random(42); // Fixed seed for consistent pattern

    return Stack(
      children: [
        // Large decorative circles
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Scattered stars/sparkles
        for (int i = 0; i < 20; i++)
          Positioned(
            left: random.nextDouble() * config.width,
            top: random.nextDouble() * config.height,
            child: Icon(
              i % 3 == 0 ? Icons.star : Icons.auto_awesome,
              size: 16 + random.nextDouble() * 24,
              color: Colors.white.withValues(alpha: 0.1 + random.nextDouble() * 0.15),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (config.appName == null && config.appLogoAsset == null) {
      return const SizedBox(height: 32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.appLogoAsset != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                config.appLogoAsset!,
                width: 48,
                height: 48,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.flag,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (config.appName != null)
            Text(
              config.appName!,
              style: _shadowedTextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
        ],
      ),
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
    final l10n = QuizEngineLocalizations.of(context);
    final starRating = _getStarRating(result.scorePercent);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Category icon (flag)
        if (config.categoryIcon != null) ...[
          Container(
            width: 200,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: config.categoryIcon,
          ),
          const SizedBox(height: 32),
        ],
        // Category name
        Text(
          result.categoryName,
          style: _shadowedTextStyle(fontSize: 56, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Mode badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Text(
            result.mode.toUpperCase(),
            style: _shadowedTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ).copyWith(letterSpacing: 3),
          ),
        ),
        const SizedBox(height: 48),
        // Large score display
        _ScoreCircle(
          score: result.scorePercent,
          size: 320,
          strokeWidth: 20,
        ),
        const SizedBox(height: 32),
        // Star rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  i < starRating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 64,
                  color: i < starRating ? Colors.amber : Colors.white.withValues(alpha: 0.3),
                  shadows: const [
                    Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        // Questions answered
        Text(
          '${result.correctCount}/${result.totalCount} ${l10n?.correct ?? 'Correct'}',
          style: _shadowedTextStyle(fontSize: 36, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPerfectScoreContent(BuildContext context) {
    final l10n = QuizEngineLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Trophy with glow
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.emoji_events,
              size: 140,
              color: Colors.amber,
              shadows: [
                Shadow(color: Colors.black38, blurRadius: 16, offset: Offset(4, 4)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Perfect score text
        Text(
          l10n?.sharePerfectScore ?? 'PERFECT SCORE!',
          style: _shadowedTextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ).copyWith(letterSpacing: 2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Category with icon
        if (config.categoryIcon != null) ...[
          Container(
            width: 160,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: config.categoryIcon,
          ),
          const SizedBox(height: 20),
        ],
        Text(
          result.categoryName,
          style: _shadowedTextStyle(fontSize: 44),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        // Score circle with golden glow
        _ScoreCircle(
          score: 100,
          size: 280,
          strokeWidth: 18,
          isPerfect: true,
        ),
        const SizedBox(height: 32),
        // 3 golden stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.star_rounded,
                  size: 72,
                  color: Colors.amber,
                  shadows: [
                    Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        // All questions correct
        Text(
          '${result.totalCount}/${result.totalCount} ${l10n?.correct ?? 'Correct'}',
          style: _shadowedTextStyle(fontSize: 36, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAchievementContent(
      BuildContext context, String achievementName) {
    final l10n = QuizEngineLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Achievement badge with glow
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.6),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                ),
              ),
              child: const Icon(
                Icons.military_tech,
                size: 110,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        // Achievement unlocked text
        Text(
          l10n?.shareAchievementUnlocked ?? 'ACHIEVEMENT UNLOCKED',
          style: _shadowedTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ).copyWith(letterSpacing: 3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Achievement name
        Text(
          achievementName,
          style: _shadowedTextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        // Score and category row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ScoreCircle(
              score: result.scorePercent,
              size: 180,
              strokeWidth: 14,
            ),
            const SizedBox(width: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (config.categoryIcon != null) ...[
                  Container(
                    width: 100,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: config.categoryIcon,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  result.categoryName,
                  style: _shadowedTextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.correctCount}/${result.totalCount}',
                  style: _shadowedTextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    final l10n = QuizEngineLocalizations.of(context);

    final ctaText = config.customCallToAction ??
        l10n?.shareCallToAction ??
        'Can you beat my score?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        ctaText,
        style: _shadowedTextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ).copyWith(fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (config.appName == null) return const SizedBox.shrink();

    return Text(
      config.appName!,
      style: _shadowedTextStyle(fontSize: 24, fontWeight: FontWeight.w500)
          .copyWith(color: Colors.white.withValues(alpha: 0.8)),
    );
  }

  int _getStarRating(int score) {
    if (score >= 90) return 3;
    if (score >= 70) return 2;
    if (score >= 50) return 1;
    return 0;
  }
}

/// Circular score display with enhanced visuals.
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
    final progressColor = isPerfect ? Colors.amber : _getScoreColor(score);
    final backgroundColor = Colors.white.withValues(alpha: 0.2);

    // Calculate proportional font sizes based on circle size
    final scoreFontSize = size * 0.32;
    final percentFontSize = size * 0.12;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: progressColor.withValues(alpha: isPerfect ? 0.4 : 0.25),
            blurRadius: isPerfect ? 40 : 24,
            spreadRadius: isPerfect ? 8 : 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with glass effect
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: backgroundColor,
                width: strokeWidth / 2,
              ),
            ),
          ),
          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CircleProgressPainter(
                progress: score / 100,
                strokeWidth: strokeWidth,
                color: progressColor,
                backgroundColor: backgroundColor,
              ),
            ),
          ),
          // Inner glass circle
          Container(
            width: size - strokeWidth * 2.5,
            height: size - strokeWidth * 2.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
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
                  color: Colors.white,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: progressColor.withValues(alpha: 0.6),
                      blurRadius: 16,
                    ),
                    const Shadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  fontSize: percentFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50); // Green
    if (score >= 70) return const Color(0xFF8BC34A); // Light Green
    if (score >= 50) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}

/// Custom painter for the circular progress arc.
class _CircleProgressPainter extends CustomPainter {
  _CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          color.withValues(alpha: 0.8),
          color,
          color.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      strokeWidth != oldDelegate.strokeWidth ||
      color != oldDelegate.color;
}
