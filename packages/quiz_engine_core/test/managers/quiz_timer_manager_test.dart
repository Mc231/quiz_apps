import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/business_logic/managers/quiz_timer_manager.dart';
import 'package:quiz_engine_core/src/model/config/quiz_mode_config.dart';

void main() {
  late QuizTimerManager manager;

  setUp(() {
    manager = QuizTimerManager();
  });

  tearDown(() {
    manager.dispose();
  });

  group('QuizTimerManager initialization', () {
    test('should start with null time values', () {
      expect(manager.questionTimeRemaining, isNull);
      expect(manager.totalTimeRemaining, isNull);
      expect(manager.isPaused, isFalse);
      expect(manager.hasQuestionTimer, isFalse);
      expect(manager.hasTotalTimer, isFalse);
    });

    test('should initialize with TimedMode question timer', () {
      manager.initialize(const TimedMode(
        timePerQuestion: 30,
        showAnswerFeedback: true,
      ));

      expect(manager.hasQuestionTimer, isTrue);
    });

    test('should initialize with TimedMode total timer', () {
      manager.initialize(const TimedMode(
        totalTimeLimit: 300,
        showAnswerFeedback: true,
      ));

      expect(manager.hasTotalTimer, isTrue);
      expect(manager.totalTimeRemaining, equals(300));
    });

    test('should initialize with SurvivalMode timers', () {
      manager.initialize(const SurvivalMode(
        lives: 3,
        timePerQuestion: 15,
        totalTimeLimit: 180,
        showAnswerFeedback: true,
      ));

      expect(manager.hasQuestionTimer, isTrue);
      expect(manager.hasTotalTimer, isTrue);
      expect(manager.totalTimeRemaining, equals(180));
    });

    test('should not set timers for StandardMode', () {
      manager.initialize(const StandardMode(showAnswerFeedback: true));

      expect(manager.hasQuestionTimer, isFalse);
      expect(manager.hasTotalTimer, isFalse);
    });

    test('should not set timers for EndlessMode', () {
      manager.initialize(const EndlessMode(showAnswerFeedback: true));

      expect(manager.hasQuestionTimer, isFalse);
      expect(manager.hasTotalTimer, isFalse);
    });
  });

  group('QuizTimerManager session stopwatch', () {
    // Note: Stopwatch tests don't use fakeAsync because Stopwatch uses real time.
    // We test the behavior/interface rather than elapsed time.

    test('should start session stopwatch', () {
      manager.startSession();
      // After starting, the stopwatch should be running
      // We can't reliably test elapsed time in unit tests
      expect(manager.sessionDurationSeconds, greaterThanOrEqualTo(0));
    });

    test('should stop session stopwatch', () {
      manager.startSession();
      manager.stopSession();
      final durationAtStop = manager.sessionDurationSeconds;
      // After stopping, duration should not increase
      expect(manager.sessionDurationSeconds, equals(durationAtStop));
    });

    test('should reset session stopwatch', () {
      manager.startSession();
      manager.stopSession();
      manager.resetSession();

      expect(manager.sessionDurationSeconds, equals(0));
    });
  });

  group('QuizTimerManager question stopwatch', () {
    test('should start and stop question stopwatch', () {
      manager.startQuestionStopwatch();

      final timeSpent = manager.stopQuestionStopwatch();
      expect(timeSpent, greaterThanOrEqualTo(0));
      expect(manager.questionTimeSpentSeconds, greaterThanOrEqualTo(0));
    });

    test('should reset on new question', () {
      manager.startQuestionStopwatch();
      manager.stopQuestionStopwatch();

      manager.startQuestionStopwatch();
      // Each call to startQuestionStopwatch resets the stopwatch
      expect(manager.questionTimeSpentSeconds, greaterThanOrEqualTo(0));
    });
  });

  group('QuizTimerManager question timer', () {
    test('should count down question time', () {
      fakeAsync((async) {
        int? lastQuestionTime;
        manager = QuizTimerManager(
          onTick: ({questionTimeRemaining, totalTimeRemaining}) {
            lastQuestionTime = questionTimeRemaining;
          },
        );
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          showAnswerFeedback: true,
        ));

        manager.startQuestionTimer();

        async.elapse(const Duration(seconds: 1));
        expect(manager.questionTimeRemaining, equals(29));
        expect(lastQuestionTime, equals(29));

        async.elapse(const Duration(seconds: 5));
        expect(manager.questionTimeRemaining, equals(24));
      });
    });

    test('should call onQuestionTimeout when time expires', () {
      fakeAsync((async) {
        int? timeoutTimeSpent;
        manager = QuizTimerManager(
          onQuestionTimeout: (timeSpent) {
            timeoutTimeSpent = timeSpent;
          },
        );
        manager.initialize(const TimedMode(
          timePerQuestion: 5,
          showAnswerFeedback: true,
        ));
        manager.startQuestionStopwatch();

        manager.startQuestionTimer();

        // Elapse 6 seconds: 5 to count down to 0, plus 1 for timeout detection
        async.elapse(const Duration(seconds: 6));

        expect(timeoutTimeSpent, isNotNull);
      });
    });

    test('should cancel question timer', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          showAnswerFeedback: true,
        ));
        manager.startQuestionTimer();

        async.elapse(const Duration(seconds: 5));
        manager.cancelQuestionTimer();

        final remainingAtCancel = manager.questionTimeRemaining;
        async.elapse(const Duration(seconds: 5));

        // Should not change after cancellation
        expect(manager.questionTimeRemaining, equals(remainingAtCancel));
      });
    });

    test('should reset question time for new question', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          showAnswerFeedback: true,
        ));
        manager.startQuestionTimer();

        async.elapse(const Duration(seconds: 10));
        expect(manager.questionTimeRemaining, equals(20));

        manager.cancelQuestionTimer();
        manager.resetQuestionTime();
        manager.startQuestionTimer();

        expect(manager.questionTimeRemaining, equals(30));
      });
    });
  });

  group('QuizTimerManager total timer', () {
    test('should count down total time', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          totalTimeLimit: 60,
          showAnswerFeedback: true,
        ));

        manager.startTotalTimer();

        async.elapse(const Duration(seconds: 10));
        expect(manager.totalTimeRemaining, equals(50));
      });
    });

    test('should call onTotalTimeExpired when time expires', () {
      fakeAsync((async) {
        var totalExpired = false;
        manager = QuizTimerManager(
          onTotalTimeExpired: () {
            totalExpired = true;
          },
        );
        manager.initialize(const TimedMode(
          totalTimeLimit: 5,
          showAnswerFeedback: true,
        ));

        manager.startTotalTimer();

        // Elapse 6 seconds: 5 to count down to 0, plus 1 for timeout detection
        async.elapse(const Duration(seconds: 6));

        expect(totalExpired, isTrue);
        expect(manager.totalTimeRemaining, equals(0));
      });
    });

    test('should cancel total timer', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          totalTimeLimit: 60,
          showAnswerFeedback: true,
        ));
        manager.startTotalTimer();

        async.elapse(const Duration(seconds: 10));
        manager.cancelTotalTimer();

        final remainingAtCancel = manager.totalTimeRemaining;
        async.elapse(const Duration(seconds: 10));

        expect(manager.totalTimeRemaining, equals(remainingAtCancel));
      });
    });
  });

  group('QuizTimerManager pause/resume', () {
    test('should pause both timers', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          totalTimeLimit: 300,
          showAnswerFeedback: true,
        ));
        manager.startQuestionTimer();
        manager.startTotalTimer();

        async.elapse(const Duration(seconds: 5));
        manager.pauseTimers();

        expect(manager.isPaused, isTrue);

        final questionTimeAtPause = manager.questionTimeRemaining;
        final totalTimeAtPause = manager.totalTimeRemaining;

        async.elapse(const Duration(seconds: 10));

        // Times should not change while paused
        expect(manager.questionTimeRemaining, equals(questionTimeAtPause));
        expect(manager.totalTimeRemaining, equals(totalTimeAtPause));
      });
    });

    test('should resume both timers', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          totalTimeLimit: 300,
          showAnswerFeedback: true,
        ));
        manager.startQuestionTimer();
        manager.startTotalTimer();

        async.elapse(const Duration(seconds: 5));
        manager.pauseTimers();

        final questionTimeAtPause = manager.questionTimeRemaining;
        final totalTimeAtPause = manager.totalTimeRemaining;

        manager.resumeTimers();

        expect(manager.isPaused, isFalse);

        async.elapse(const Duration(seconds: 5));

        expect(manager.questionTimeRemaining, equals(questionTimeAtPause! - 5));
        expect(manager.totalTimeRemaining, equals(totalTimeAtPause! - 5));
      });
    });

    test('should not double pause', () {
      manager.pauseTimers();
      expect(manager.isPaused, isTrue);

      manager.pauseTimers();
      expect(manager.isPaused, isTrue);
    });

    test('should not double resume', () {
      manager.pauseTimers();
      manager.resumeTimers();
      expect(manager.isPaused, isFalse);

      manager.resumeTimers();
      expect(manager.isPaused, isFalse);
    });

    test('should not start timers while paused', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          showAnswerFeedback: true,
        ));
        manager.pauseTimers();

        manager.startQuestionTimer();

        async.elapse(const Duration(seconds: 5));

        // Timer should not have started, so remaining should be initial value
        expect(manager.questionTimeRemaining, equals(30));
      });
    });
  });

  group('QuizTimerManager dispose and reset', () {
    test('should dispose all timers', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          totalTimeLimit: 300,
          showAnswerFeedback: true,
        ));
        manager.startSession();
        manager.startQuestionStopwatch();
        manager.startQuestionTimer();
        manager.startTotalTimer();

        async.elapse(const Duration(seconds: 5));
        manager.dispose();

        final questionTimeAtDispose = manager.questionTimeRemaining;
        final totalTimeAtDispose = manager.totalTimeRemaining;

        async.elapse(const Duration(seconds: 5));

        // Timers should not change after dispose
        expect(manager.questionTimeRemaining, equals(questionTimeAtDispose));
        expect(manager.totalTimeRemaining, equals(totalTimeAtDispose));
      });
    });

    test('should reset all state', () {
      fakeAsync((async) {
        manager.initialize(const TimedMode(
          timePerQuestion: 30,
          totalTimeLimit: 300,
          showAnswerFeedback: true,
        ));
        manager.startSession();
        manager.startQuestionTimer();
        manager.startTotalTimer();

        async.elapse(const Duration(seconds: 5));
        manager.reset();

        expect(manager.questionTimeRemaining, isNull);
        expect(manager.totalTimeRemaining, isNull);
        expect(manager.isPaused, isFalse);
        expect(manager.hasQuestionTimer, isFalse);
        expect(manager.hasTotalTimer, isFalse);
        expect(manager.sessionDurationSeconds, equals(0));
      });
    });
  });
}
