import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/bloc/practice/practice_bloc.dart';
import 'package:quiz_engine/src/bloc/practice/practice_event.dart';
import 'package:quiz_engine/src/bloc/practice/practice_state.dart';
import 'package:quiz_engine/src/models/practice_data_provider.dart';

/// Mock implementation of [PracticeBlocDataProvider] for testing.
class MockPracticeBlocDataProvider implements PracticeBlocDataProvider {
  MockPracticeBlocDataProvider({
    PracticeTabData? data,
    bool shouldFail = false,
    Duration loadDelay = Duration.zero,
  })  : _data = data ?? _createDefaultData(),
        _shouldFail = shouldFail,
        _loadDelay = loadDelay;

  final PracticeTabData _data;
  final bool _shouldFail;
  final Duration _loadDelay;

  int loadCallCount = 0;
  int completeCallCount = 0;
  List<String> lastCorrectQuestionIds = [];

  @override
  Future<PracticeTabData> loadPracticeData() async {
    loadCallCount++;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFail) {
      throw Exception('Failed to load practice data');
    }
    return _data;
  }

  @override
  Future<void> onPracticeSessionCompleted(
    List<String> correctQuestionIds,
  ) async {
    completeCallCount++;
    lastCorrectQuestionIds = correctQuestionIds;
  }

  static PracticeTabData _createDefaultData() {
    return const PracticeTabData(
      practiceQuestions: [],
      allQuestions: [],
      practiceQuestionIds: {'q1', 'q2', 'q3'},
    );
  }
}

void main() {
  group('PracticeBloc', () {
    late MockPracticeBlocDataProvider mockProvider;
    late PracticeBloc bloc;

    setUp(() {
      mockProvider = MockPracticeBlocDataProvider();
      bloc = PracticeBloc(dataProvider: mockProvider);
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('initial state is PracticeLoading', () {
        expect(bloc.initialState, isA<PracticeLoading>());
      });

      test('data getter returns null when not loaded', () {
        expect(bloc.data, isNull);
      });

      test('questionCount getter returns null when not loaded', () {
        expect(bloc.questionCount, isNull);
      });

      test('hasQuestions returns false when not loaded', () {
        expect(bloc.hasQuestions, isFalse);
      });
    });

    group('LoadPractice event', () {
      test('emits PracticeReady after loading', () async {
        bloc.add(PracticeEvent.load());

        final readyState =
            await bloc.stream.firstWhere((s) => s is PracticeReady);

        expect(readyState, isA<PracticeReady>());
      });

      test('calls loadPracticeData on provider', () async {
        bloc.add(PracticeEvent.load());

        await bloc.stream.firstWhere((s) => s is PracticeReady);

        expect(mockProvider.loadCallCount, equals(1));
      });

      test('ready state contains practice data', () async {
        bloc.add(PracticeEvent.load());

        final readyState = await bloc.stream
            .firstWhere((s) => s is PracticeReady) as PracticeReady;

        expect(readyState.data, isNotNull);
        expect(readyState.data.practiceQuestionIds, contains('q1'));
      });

      test('data getter returns value after load', () async {
        bloc.add(PracticeEvent.load());

        await bloc.stream.firstWhere((s) => s is PracticeReady);

        expect(bloc.data, isNotNull);
      });

      test('emits PracticeError on failure', () async {
        mockProvider = MockPracticeBlocDataProvider(shouldFail: true);
        bloc = PracticeBloc(dataProvider: mockProvider);

        bloc.add(PracticeEvent.load());

        final errorState =
            await bloc.stream.firstWhere((s) => s is PracticeError);

        expect(errorState, isA<PracticeError>());
        expect((errorState as PracticeError).message,
            contains('Failed to load practice data'));
      });
    });

    group('RefreshPractice event', () {
      test('reloads data when already loaded', () async {
        bloc.add(PracticeEvent.load());
        await bloc.stream.firstWhere((s) => s is PracticeReady);

        bloc.add(PracticeEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockProvider.loadCallCount, equals(2));
      });

      test('sets isRefreshing to true during refresh', () async {
        mockProvider = MockPracticeBlocDataProvider(
          loadDelay: const Duration(milliseconds: 100),
        );
        bloc = PracticeBloc(dataProvider: mockProvider);

        bloc.add(PracticeEvent.load());
        await bloc.stream.firstWhere((s) => s is PracticeReady);

        final states = <PracticeState>[];
        bloc.stream.listen(states.add);

        bloc.add(PracticeEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(
          states.any((s) => s is PracticeReady && s.isRefreshing == true),
          isTrue,
        );
      });

      test('does regular load if not yet loaded', () async {
        bloc.add(PracticeEvent.refresh());

        final readyState =
            await bloc.stream.firstWhere((s) => s is PracticeReady);

        expect(readyState, isA<PracticeReady>());
      });
    });

    group('PracticeSessionComplete event', () {
      test('emits PracticeComplete state', () async {
        bloc.add(PracticeEvent.load());
        await bloc.stream.firstWhere((s) => s is PracticeReady);

        bloc.add(PracticeEvent.complete(
          correctCount: 8,
          needMorePracticeCount: 2,
          correctQuestionIds: ['q1', 'q2'],
        ));

        final completeState =
            await bloc.stream.firstWhere((s) => s is PracticeComplete);

        expect(completeState, isA<PracticeComplete>());
        expect((completeState as PracticeComplete).correctCount, equals(8));
        expect(completeState.needMorePracticeCount, equals(2));
      });

      test('calls onPracticeSessionCompleted on provider', () async {
        bloc.add(PracticeEvent.load());
        await bloc.stream.firstWhere((s) => s is PracticeReady);

        bloc.add(PracticeEvent.complete(
          correctCount: 5,
          needMorePracticeCount: 3,
          correctQuestionIds: ['q1', 'q2', 'q3'],
        ));

        await bloc.stream.firstWhere((s) => s is PracticeComplete);

        expect(mockProvider.completeCallCount, equals(1));
        expect(mockProvider.lastCorrectQuestionIds, equals(['q1', 'q2', 'q3']));
      });

      test('correctCount getter returns value after complete', () async {
        bloc.add(PracticeEvent.load());
        await bloc.stream.firstWhere((s) => s is PracticeReady);

        bloc.add(PracticeEvent.complete(
          correctCount: 7,
          needMorePracticeCount: 1,
          correctQuestionIds: [],
        ));

        await bloc.stream.firstWhere((s) => s is PracticeComplete);

        expect(bloc.correctCount, equals(7));
        expect(bloc.needMorePracticeCount, equals(1));
      });
    });

    group('ResetPractice event', () {
      test('reloads practice data', () async {
        bloc.add(PracticeEvent.load());
        await bloc.stream.firstWhere((s) => s is PracticeReady);

        bloc.add(PracticeEvent.complete(
          correctCount: 5,
          needMorePracticeCount: 0,
          correctQuestionIds: [],
        ));
        await bloc.stream.firstWhere((s) => s is PracticeComplete);

        bloc.add(PracticeEvent.reset());
        final readyState =
            await bloc.stream.firstWhere((s) => s is PracticeReady);

        expect(readyState, isA<PracticeReady>());
        expect(mockProvider.loadCallCount, equals(2));
      });
    });
  });

  group('PracticeState', () {
    test('PracticeLoading equality', () {
      const loading1 = PracticeLoading();
      const loading2 = PracticeLoading();

      expect(loading1, equals(loading2));
    });

    test('PracticeReady equality', () {
      const data = PracticeTabData(
        practiceQuestions: [],
        allQuestions: [],
        practiceQuestionIds: {'q1'},
      );

      const ready1 = PracticeReady(data: data);
      const ready2 = PracticeReady(data: data);
      const ready3 = PracticeReady(data: data, isRefreshing: true);

      expect(ready1, equals(ready2));
      expect(ready1, isNot(equals(ready3)));
    });

    test('PracticeReady copyWith creates correct copy', () {
      const data = PracticeTabData(
        practiceQuestions: [],
        allQuestions: [],
        practiceQuestionIds: {'q1'},
      );

      const original = PracticeReady(data: data, isRefreshing: false);

      final copied = original.copyWith(isRefreshing: true);

      expect(copied.data, equals(original.data));
      expect(copied.isRefreshing, isTrue);
    });

    test('PracticeReady questionCount getter', () {
      const data = PracticeTabData(
        practiceQuestions: [],
        allQuestions: [],
        practiceQuestionIds: {'q1', 'q2', 'q3'},
      );

      const ready = PracticeReady(data: data);

      // questionCount comes from practiceQuestions.length, not practiceQuestionIds
      expect(ready.questionCount, equals(0));
    });

    test('PracticeComplete equality', () {
      const complete1 = PracticeComplete(
        correctCount: 5,
        needMorePracticeCount: 3,
      );
      const complete2 = PracticeComplete(
        correctCount: 5,
        needMorePracticeCount: 3,
      );
      const complete3 = PracticeComplete(
        correctCount: 4,
        needMorePracticeCount: 4,
      );

      expect(complete1, equals(complete2));
      expect(complete1, isNot(equals(complete3)));
    });

    test('PracticeComplete totalCount', () {
      const complete = PracticeComplete(
        correctCount: 7,
        needMorePracticeCount: 3,
      );

      expect(complete.totalCount, equals(10));
    });

    test('PracticeComplete isAllCorrect', () {
      const allCorrect = PracticeComplete(
        correctCount: 10,
        needMorePracticeCount: 0,
      );
      const notAllCorrect = PracticeComplete(
        correctCount: 8,
        needMorePracticeCount: 2,
      );

      expect(allCorrect.isAllCorrect, isTrue);
      expect(notAllCorrect.isAllCorrect, isFalse);
    });

    test('PracticeError equality', () {
      const error1 = PracticeError(message: 'Error 1');
      const error2 = PracticeError(message: 'Error 1');
      const error3 = PracticeError(message: 'Error 2');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('factory constructors create correct types', () {
      const data = PracticeTabData(
        practiceQuestions: [],
        allQuestions: [],
        practiceQuestionIds: {},
      );

      expect(PracticeState.loading(), isA<PracticeLoading>());
      expect(PracticeState.ready(data: data), isA<PracticeReady>());
      expect(
        PracticeState.complete(correctCount: 5, needMorePracticeCount: 3),
        isA<PracticeComplete>(),
      );
      expect(
        PracticeState.error(message: 'Error'),
        isA<PracticeError>(),
      );
    });
  });

  group('PracticeEvent', () {
    test('LoadPractice equality', () {
      const load1 = LoadPractice();
      const load2 = LoadPractice();

      expect(load1.hashCode, equals(load2.hashCode));
    });

    test('RefreshPractice equality', () {
      const refresh1 = RefreshPractice();
      const refresh2 = RefreshPractice();

      expect(refresh1.hashCode, equals(refresh2.hashCode));
    });

    test('PracticeSessionComplete equality', () {
      const complete1 = PracticeSessionComplete(
        correctCount: 5,
        needMorePracticeCount: 3,
        correctQuestionIds: ['q1', 'q2'],
      );
      const complete2 = PracticeSessionComplete(
        correctCount: 5,
        needMorePracticeCount: 3,
        correctQuestionIds: ['q1', 'q2'],
      );
      const complete3 = PracticeSessionComplete(
        correctCount: 5,
        needMorePracticeCount: 3,
        correctQuestionIds: ['q1', 'q3'],
      );

      expect(complete1, equals(complete2));
      expect(complete1.hashCode, equals(complete2.hashCode));
      expect(complete1, isNot(equals(complete3)));
    });

    test('ResetPractice equality', () {
      const reset1 = ResetPractice();
      const reset2 = ResetPractice();

      expect(reset1.hashCode, equals(reset2.hashCode));
    });

    test('factory constructors create correct types', () {
      expect(PracticeEvent.load(), isA<LoadPractice>());
      expect(PracticeEvent.refresh(), isA<RefreshPractice>());
      expect(
        PracticeEvent.complete(
          correctCount: 5,
          needMorePracticeCount: 3,
          correctQuestionIds: [],
        ),
        isA<PracticeSessionComplete>(),
      );
      expect(PracticeEvent.reset(), isA<ResetPractice>());
    });
  });
}
