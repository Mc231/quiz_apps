import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

/// Helper to wrap widget with localizations for share tests.
Widget wrapWithShareLocalizations(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      QuizLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: child,
  );
}

/// Mock share service for testing.
class MockShareService implements ShareService {
  MockShareService({
    this.canShareText = true,
    this.canShareImages = false,
    this.shareResult = const ShareOperationSuccess(),
  });

  final bool canShareText;
  final bool canShareImages;
  final ShareOperationResult shareResult;

  int shareTextCallCount = 0;
  int shareImageCallCount = 0;
  ShareResult? lastSharedResult;

  @override
  ShareConfig get config => const ShareConfig(appName: 'Test App');

  @override
  bool canShare() => canShareText;

  @override
  bool canShareImage() => canShareImages;

  @override
  Future<ShareOperationResult> shareText(ShareResult result) async {
    shareTextCallCount++;
    lastSharedResult = result;
    return shareResult;
  }

  @override
  Future<ShareOperationResult> shareImage(
    ShareResult result, {
    required Uint8List imageData,
    String? text,
  }) async {
    shareImageCallCount++;
    lastSharedResult = result;
    return shareResult;
  }

  @override
  String generateShareText(ShareResult result) {
    return 'I scored ${result.scorePercent}% on ${result.categoryName}!';
  }

  @override
  String generateShortShareText(ShareResult result) {
    return '${result.scorePercent}% on ${result.categoryName}';
  }

  @override
  void dispose() {}
}

void main() {
  late ShareResult testResult;

  setUp(() {
    testResult = ShareResult.fromQuizCompletion(
      correctCount: 17,
      totalCount: 20,
      categoryName: 'European Flags',
      mode: 'standard',
    );
  });

  group('ShareBottomSheet', () {
    testWidgets('displays share title', (tester) async {
      final shareService = MockShareService();

      await tester.pumpWidget(
        wrapWithShareLocalizations(
          Scaffold(
            body: ShareBottomSheet(
              result: testResult,
              shareService: shareService,
            ),
          ),
        ),
      );

      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('shows text share option when available', (tester) async {
      final shareService = MockShareService(canShareText: true);

      await tester.pumpWidget(
        wrapWithShareLocalizations(
          Scaffold(
            body: ShareBottomSheet(
              result: testResult,
              shareService: shareService,
            ),
          ),
        ),
      );

      expect(find.text('Share as Text'), findsOneWidget);
      expect(find.text('Share your score as a message'), findsOneWidget);
    });

    testWidgets('hides text share option when disabled in config', (tester) async {
      final shareService = MockShareService(canShareText: false);

      await tester.pumpWidget(
        wrapWithShareLocalizations(
          Scaffold(
            body: ShareBottomSheet(
              result: testResult,
              shareService: shareService,
              config: const ShareBottomSheetConfig(showTextOption: false),
            ),
          ),
        ),
      );

      expect(find.text('Share as Text'), findsNothing);
    });

    testWidgets('shows unavailable message when sharing not available',
        (tester) async {
      final shareService = MockShareService(
        canShareText: false,
        canShareImages: false,
      );

      await tester.pumpWidget(
        wrapWithShareLocalizations(
          Scaffold(
            body: ShareBottomSheet(
              result: testResult,
              shareService: shareService,
            ),
          ),
        ),
      );

      expect(
        find.text('Sharing is not available on this device'),
        findsOneWidget,
      );
    });

    testWidgets('calls shareText when text option is tapped', (tester) async {
      final shareService = MockShareService(
        shareResult: const ShareOperationSuccess(),
      );

      await tester.pumpWidget(
        wrapWithShareLocalizations(
          Scaffold(
            body: ShareBottomSheet(
              result: testResult,
              shareService: shareService,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Share as Text'));
      await tester.pump();

      expect(shareService.shareTextCallCount, equals(1));
      expect(shareService.lastSharedResult?.categoryName, equals('European Flags'));
    });

    testWidgets('shows cancel button', (tester) async {
      final shareService = MockShareService();

      await tester.pumpWidget(
        wrapWithShareLocalizations(
          Scaffold(
            body: ShareBottomSheet(
              result: testResult,
              shareService: shareService,
            ),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('ShareBottomSheet.show returns null when cancelled',
        (tester) async {
      final shareService = MockShareService();
      ShareOperationResult? result;

      await tester.pumpWidget(
        wrapWithShareLocalizations(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ShareBottomSheet.show(
                    context: context,
                    result: testResult,
                    shareService: shareService,
                  );
                },
                child: const Text('Open Share'),
              ),
            ),
          ),
        ),
      );

      // Open the bottom sheet
      await tester.tap(find.text('Open Share'));
      await tester.pumpAndSettle();

      // Dismiss by tapping cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });

  group('ShareResult', () {
    test('fromQuizCompletion calculates score correctly', () {
      final result = ShareResult.fromQuizCompletion(
        correctCount: 15,
        totalCount: 20,
        categoryName: 'Test',
        mode: 'standard',
      );

      expect(result.score, equals(75.0));
      expect(result.scorePercent, equals(75));
      expect(result.isPerfect, isFalse);
    });

    test('isPerfect returns true for 100% score', () {
      final result = ShareResult.fromQuizCompletion(
        correctCount: 20,
        totalCount: 20,
        categoryName: 'Test',
        mode: 'standard',
      );

      expect(result.isPerfect, isTrue);
    });

    test('fromAchievement creates correct result', () {
      final result = ShareResult.fromAchievement(
        achievementId: 'ach-1',
        achievementName: 'First Quiz',
        achievementTier: 'bronze',
        pointsAwarded: 100,
      );

      expect(result.mode, equals('achievement'));
      expect(result.achievementUnlocked, equals('First Quiz'));
      expect(result.hasAchievement, isTrue);
    });

    test('hasAchievement returns true when achievement is set', () {
      final result = ShareResult.fromQuizCompletion(
        correctCount: 20,
        totalCount: 20,
        categoryName: 'Test',
        mode: 'standard',
        achievementUnlocked: 'Perfectionist',
      );

      expect(result.hasAchievement, isTrue);
      expect(result.achievementUnlocked, equals('Perfectionist'));
    });

    test('isNewBest returns true when score exceeds bestScore', () {
      final result = ShareResult.fromQuizCompletion(
        correctCount: 18,
        totalCount: 20,
        categoryName: 'Test',
        mode: 'standard',
        bestScore: 85.0,
      );

      expect(result.isNewBest, isTrue);
    });

    test('isNewBest returns false when score is lower than bestScore', () {
      final result = ShareResult.fromQuizCompletion(
        correctCount: 15,
        totalCount: 20,
        categoryName: 'Test',
        mode: 'standard',
        bestScore: 80.0,
      );

      expect(result.isNewBest, isFalse);
    });

    test('formattedTime formats duration correctly', () {
      final result = ShareResult.fromQuizCompletion(
        correctCount: 15,
        totalCount: 20,
        categoryName: 'Test',
        mode: 'standard',
        timeTaken: const Duration(minutes: 2, seconds: 30),
      );

      expect(result.formattedTime, equals('2:30'));
    });
  });

  group('ShareBottomSheetConfig', () {
    test('default config allows both options', () {
      const config = ShareBottomSheetConfig();

      expect(config.showTextOption, isTrue);
      expect(config.showImageOption, isTrue);
    });

    test('can disable text option', () {
      const config = ShareBottomSheetConfig(showTextOption: false);

      expect(config.showTextOption, isFalse);
    });

    test('can disable image option', () {
      const config = ShareBottomSheetConfig(showImageOption: false);

      expect(config.showImageOption, isFalse);
    });
  });
}
