import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ShareImageTemplateType', () {
    test('creates standard template', () {
      final template = ShareImageTemplateType.standard();
      expect(template, isA<StandardShareTemplate>());
    });

    test('creates achievement template', () {
      final template = ShareImageTemplateType.achievement(
        achievementName: 'Perfectionist',
        achievementIcon: '🏆',
      );
      expect(template, isA<AchievementShareTemplate>());
      expect((template as AchievementShareTemplate).achievementName,
          'Perfectionist');
      expect(template.achievementIcon, '🏆');
    });

    test('creates perfect score template', () {
      final template = ShareImageTemplateType.perfectScore();
      expect(template, isA<PerfectScoreShareTemplate>());
    });
  });

  group('ShareImageConfig', () {
    test('creates with defaults', () {
      const config = ShareImageConfig();

      expect(config.appName, isNull);
      expect(config.appLogoAsset, isNull);
      expect(config.width, 1080);
      expect(config.height, 1920);
      expect(config.useDarkTheme, isNull);
      expect(config.showQrCode, isFalse);
    });

    test('creates with custom values', () {
      const config = ShareImageConfig(
        appName: 'Flags Quiz',
        appLogoAsset: 'assets/logo.png',
        width: 1200,
        height: 1200,
        useDarkTheme: true,
        showQrCode: true,
        qrCodeData: 'https://example.com',
        customCallToAction: 'Try this!',
      );

      expect(config.appName, 'Flags Quiz');
      expect(config.appLogoAsset, 'assets/logo.png');
      expect(config.width, 1200);
      expect(config.height, 1200);
      expect(config.useDarkTheme, isTrue);
      expect(config.showQrCode, isTrue);
      expect(config.qrCodeData, 'https://example.com');
      expect(config.customCallToAction, 'Try this!');
    });

    test('aspectRatio is calculated correctly', () {
      const config = ShareImageConfig(width: 1080, height: 1920);
      expect(config.aspectRatio, closeTo(0.5625, 0.001));

      const squareConfig = ShareImageConfig(width: 1080, height: 1080);
      expect(squareConfig.aspectRatio, 1.0);
    });

    test('copyWith creates modified copy', () {
      const original = ShareImageConfig(
        appName: 'Original',
        width: 1080,
      );

      final copy = original.copyWith(appName: 'Updated');

      expect(copy.appName, 'Updated');
      expect(copy.width, 1080);
    });
  });

  group('ShareImageTemplate', () {
    late ShareResult shareResult;

    setUp(() {
      shareResult = ShareResult(
        score: 85.0,
        categoryName: 'European Flags',
        correctCount: 17,
        totalCount: 20,
        mode: 'standard',
        timestamp: DateTime.now(),
      );
    });

    Widget buildTestWidget({
      ShareResult? result,
      ShareImageTemplateType? templateType,
      ShareImageConfig? config,
      Size screenSize = const Size(1080, 1920),
    }) {
      final actualConfig = config ?? ShareImageConfig(
        width: screenSize.width,
        height: screenSize.height,
        appName: 'Test App',
      );

      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: ShareImageTemplate(
                  result: result ?? shareResult,
                  templateType: templateType ?? const StandardShareTemplate(),
                  config: actualConfig,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders standard template with score', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());

      // Check that score is displayed
      expect(find.text('85'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('European Flags'), findsOneWidget);
    });

    testWidgets('renders app name when provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(
        config: const ShareImageConfig(
          width: 1080,
          height: 1920,
          appName: 'Flags Quiz',
        ),
      ));

      expect(find.text('Flags Quiz'), findsWidgets);
    });

    testWidgets('renders mode badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('STANDARD'), findsOneWidget);
    });

    testWidgets('renders correct/total count', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('17/20'), findsOneWidget);
    });

    testWidgets('renders perfect score template with trophy icon', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final perfectResult = ShareResult.perfect(
        categoryName: 'World Capitals',
        totalCount: 25,
        mode: 'timed',
      );

      await tester.pumpWidget(buildTestWidget(
        result: perfectResult,
        templateType: ShareImageTemplateType.perfectScore(),
      ));

      // Perfect score template shows trophy icon
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('renders achievement template with badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final resultWithAchievement = shareResult.copyWith(
        achievementUnlocked: 'First Perfect',
      );

      await tester.pumpWidget(buildTestWidget(
        result: resultWithAchievement,
        templateType: ShareImageTemplateType.achievement(
          achievementName: 'First Perfect',
        ),
      ));

      // Achievement template shows achievement badge
      expect(find.byIcon(Icons.military_tech), findsOneWidget);
      expect(find.text('First Perfect'), findsOneWidget);
    });

    testWidgets('uses dark theme when specified', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(
        config: const ShareImageConfig(
          width: 1080,
          height: 1920,
          useDarkTheme: true,
        ),
      ));

      // Widget should render without errors in dark mode
      expect(find.byType(ShareImageTemplate), findsOneWidget);
    });

    testWidgets('uses light theme when specified', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(
        config: const ShareImageConfig(
          width: 1080,
          height: 1920,
          useDarkTheme: false,
        ),
      ));

      // Widget should render without errors in light mode
      expect(find.byType(ShareImageTemplate), findsOneWidget);
    });

    testWidgets('displays custom call to action', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(
        config: const ShareImageConfig(
          width: 1080,
          height: 1920,
          customCallToAction: 'Beat this score!',
        ),
      ));

      expect(find.text('Beat this score!'), findsOneWidget);
    });

    testWidgets('displays category icon when provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(
        config: ShareImageConfig(
          width: 1080,
          height: 1920,
          categoryIcon: const Icon(Icons.flag, key: Key('category_icon')),
        ),
      ));

      expect(find.byKey(const Key('category_icon')), findsOneWidget);
    });
  });

  group('ShareImagePreview', () {
    testWidgets('renders at scaled size', (tester) async {
      final generator = ShareImageGenerator();
      final result = ShareResult(
        score: 85.0,
        categoryName: 'Test',
        correctCount: 17,
        totalCount: 20,
        mode: 'standard',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShareImagePreview(
                generator: generator,
                result: result,
                config: const ShareImageConfig(
                  width: 1080,
                  height: 1920,
                ),
                previewScale: 0.2,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShareImagePreview), findsOneWidget);

      // Check the size is scaled
      final previewFinder = find.byType(ClipRRect);
      expect(previewFinder, findsOneWidget);

      final clipRRect = tester.widget<ClipRRect>(previewFinder);
      final sizedBox = clipRRect.child as SizedBox;
      expect(sizedBox.width, 1080 * 0.2);
      expect(sizedBox.height, 1920 * 0.2);
    });
  });
}
