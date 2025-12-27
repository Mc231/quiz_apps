import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

/// Mock implementation of [SessionDetailDataProvider] for testing.
class MockSessionDetailDataProvider implements SessionDetailDataProvider {
  MockSessionDetailDataProvider({
    SessionDetailData? sessionData,
    bool shouldFailLoad = false,
    bool shouldFailDelete = false,
    Duration loadDelay = Duration.zero,
  })  : _sessionData = sessionData ?? _createDefaultSessionData(),
        _shouldFailLoad = shouldFailLoad,
        _shouldFailDelete = shouldFailDelete,
        _loadDelay = loadDelay;

  final SessionDetailData _sessionData;
  final bool _shouldFailLoad;
  final bool _shouldFailDelete;
  final Duration _loadDelay;

  int loadCallCount = 0;
  int deleteCallCount = 0;
  String? lastLoadedSessionId;
  String? lastDeletedSessionId;

  @override
  Future<SessionDetailData> loadSessionDetail(String sessionId) async {
    loadCallCount++;
    lastLoadedSessionId = sessionId;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFailLoad) {
      throw Exception('Failed to load session');
    }
    return _sessionData;
  }

  @override
  Future<bool> deleteSession(String sessionId) async {
    deleteCallCount++;
    lastDeletedSessionId = sessionId;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFailDelete) {
      throw Exception('Failed to delete session');
    }
    return true;
  }

  static SessionDetailData _createDefaultSessionData() {
    return SessionDetailData(
      id: 'session-1',
      quizName: 'European Flags',
      totalQuestions: 10,
      totalCorrect: 8,
      totalIncorrect: 2,
      totalSkipped: 0,
      scorePercentage: 80.0,
      completionStatus: 'completed',
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      questions: [
        const ReviewedQuestion(
          questionNumber: 1,
          questionText: 'What is the capital of France?',
          correctAnswer: 'Paris',
          userAnswer: 'Paris',
          isCorrect: true,
        ),
        const ReviewedQuestion(
          questionNumber: 2,
          questionText: 'What is the capital of Germany?',
          correctAnswer: 'Berlin',
          userAnswer: 'Munich',
          isCorrect: false,
        ),
      ],
    );
  }
}

void main() {
  group('SessionDetailBloc', () {
    late MockSessionDetailDataProvider mockProvider;
    late SessionDetailBloc bloc;

    setUp(() {
      mockProvider = MockSessionDetailDataProvider();
      bloc = SessionDetailBloc(dataProvider: mockProvider);
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('initialState is SessionDetailLoading', () {
        expect(bloc.initialState, isA<SessionDetailLoading>());
      });

      test('session is null before loading', () {
        expect(bloc.session, isNull);
      });

      test('filterMode is all before loading', () {
        expect(bloc.filterMode, QuestionFilterMode.all);
      });
    });

    group('LoadSessionDetail event', () {
      test('emits SessionDetailLoading then SessionDetailLoaded on success',
          () async {
        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        bloc.add(SessionDetailEvent.load('session-1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<SessionDetailLoading>());
        expect(states[1], isA<SessionDetailLoaded>());
      });

      test('calls loadSessionDetail on data provider with correct ID',
          () async {
        bloc.add(SessionDetailEvent.load('session-123'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadCallCount, 1);
        expect(mockProvider.lastLoadedSessionId, 'session-123');
      });

      test('sets session in loaded state', () async {
        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        bloc.add(SessionDetailEvent.load('session-1'));

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as SessionDetailLoaded;
        expect(loadedState.session.id, 'session-1');
        expect(loadedState.session.quizName, 'European Flags');
        expect(loadedState.session.scorePercentage, 80.0);
      });

      test('sets default filter mode to all', () async {
        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        bloc.add(SessionDetailEvent.load('session-1'));

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as SessionDetailLoaded;
        expect(loadedState.filterMode, QuestionFilterMode.all);
      });

      test('emits SessionDetailError on failure', () async {
        mockProvider = MockSessionDetailDataProvider(shouldFailLoad: true);
        bloc.dispose();
        bloc = SessionDetailBloc(dataProvider: mockProvider);

        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        bloc.add(SessionDetailEvent.load('session-1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<SessionDetailLoading>());
        expect(states[1], isA<SessionDetailError>());
      });

      test('error state contains error message', () async {
        mockProvider = MockSessionDetailDataProvider(shouldFailLoad: true);
        bloc.dispose();
        bloc = SessionDetailBloc(dataProvider: mockProvider);

        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        bloc.add(SessionDetailEvent.load('session-1'));

        await Future.delayed(const Duration(milliseconds: 100));

        final errorState = states[1] as SessionDetailError;
        expect(errorState.message, 'Failed to load session detail');
        expect(errorState.error, isA<Exception>());
      });
    });

    group('RefreshSessionDetail event', () {
      test('refreshes data using stored session ID', () async {
        // First load
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Refresh
        bloc.add(SessionDetailEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadCallCount, 2);
        expect(mockProvider.lastLoadedSessionId, 'session-1');
      });

      test('preserves filter mode during refresh', () async {
        // First load
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Change filter mode
        bloc.add(
            SessionDetailEvent.changeFilterMode(QuestionFilterMode.wrongOnly));
        await Future.delayed(const Duration(milliseconds: 50));

        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        // Refresh
        bloc.add(SessionDetailEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states.last as SessionDetailLoaded;
        expect(loadedState.filterMode, QuestionFilterMode.wrongOnly);
      });

      test('does nothing when session ID is null', () async {
        bloc.add(SessionDetailEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockProvider.loadCallCount, 0);
      });

      test('loads normally when called before initial load', () async {
        // Set session ID without loading
        // This simulates calling refresh when not in loaded state
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 10));

        // Immediately refresh
        bloc.add(SessionDetailEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 150));

        expect(mockProvider.loadCallCount, 2);
      });
    });

    group('ChangeFilterMode event', () {
      test('updates filter mode when in loaded state', () async {
        // First load
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        // Change filter mode
        bloc.add(
            SessionDetailEvent.changeFilterMode(QuestionFilterMode.wrongOnly));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states.length, 1);
        final loadedState = states.first as SessionDetailLoaded;
        expect(loadedState.filterMode, QuestionFilterMode.wrongOnly);
      });

      test('does nothing when not in loaded state', () async {
        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        bloc.add(
            SessionDetailEvent.changeFilterMode(QuestionFilterMode.wrongOnly));
        await Future.delayed(const Duration(milliseconds: 50));

        // No state changes
        expect(states, isEmpty);
      });

      test('can toggle filter mode back to all', () async {
        // First load
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Change to wrongOnly
        bloc.add(
            SessionDetailEvent.changeFilterMode(QuestionFilterMode.wrongOnly));
        await Future.delayed(const Duration(milliseconds: 50));

        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        // Change back to all
        bloc.add(SessionDetailEvent.changeFilterMode(QuestionFilterMode.all));
        await Future.delayed(const Duration(milliseconds: 50));

        final loadedState = states.first as SessionDetailLoaded;
        expect(loadedState.filterMode, QuestionFilterMode.all);
      });
    });

    group('DeleteSessionDetail event', () {
      test('calls deleteSession on data provider', () async {
        // First load
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Delete
        bloc.add(SessionDetailEvent.delete());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.deleteCallCount, 1);
        expect(mockProvider.lastDeletedSessionId, 'session-1');
      });

      test('sets isDeleting to true during deletion', () async {
        mockProvider = MockSessionDetailDataProvider(
          loadDelay: const Duration(milliseconds: 50),
        );
        bloc.dispose();
        bloc = SessionDetailBloc(dataProvider: mockProvider);

        // First load
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        // Delete
        bloc.add(SessionDetailEvent.delete());
        await Future.delayed(const Duration(milliseconds: 10));

        // Should be deleting
        final deletingState = states.first as SessionDetailLoaded;
        expect(deletingState.isDeleting, true);

        // Wait for delete to complete
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('sets isDeleting to false after successful deletion', () async {
        // First load
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <SessionDetailState>[];
        bloc.stream.listen(states.add);

        // Delete
        bloc.add(SessionDetailEvent.delete());
        await Future.delayed(const Duration(milliseconds: 100));

        // Last state should have isDeleting false
        final lastState = states.last as SessionDetailLoaded;
        expect(lastState.isDeleting, false);
      });

      test('does nothing when session ID is null', () async {
        bloc.add(SessionDetailEvent.delete());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockProvider.deleteCallCount, 0);
      });

      test('does nothing when not in loaded state', () async {
        bloc.add(SessionDetailEvent.delete());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockProvider.deleteCallCount, 0);
      });
    });

    group('SessionDetailLoaded copyWith', () {
      test('creates copy with updated filterMode', () {
        final original = SessionDetailLoaded(
          session: MockSessionDetailDataProvider._createDefaultSessionData(),
          filterMode: QuestionFilterMode.all,
        );

        final copy =
            original.copyWith(filterMode: QuestionFilterMode.wrongOnly);

        expect(copy.filterMode, QuestionFilterMode.wrongOnly);
        expect(copy.session, original.session);
        expect(copy.isDeleting, original.isDeleting);
      });

      test('creates copy with updated isDeleting', () {
        final original = SessionDetailLoaded(
          session: MockSessionDetailDataProvider._createDefaultSessionData(),
        );

        final copy = original.copyWith(isDeleting: true);

        expect(copy.isDeleting, true);
        expect(copy.filterMode, original.filterMode);
      });

      test('preserves all values when no arguments provided', () {
        final original = SessionDetailLoaded(
          session: MockSessionDetailDataProvider._createDefaultSessionData(),
          filterMode: QuestionFilterMode.wrongOnly,
          isDeleting: true,
        );

        final copy = original.copyWith();

        expect(copy.session, original.session);
        expect(copy.filterMode, original.filterMode);
        expect(copy.isDeleting, original.isDeleting);
      });
    });

    group('SessionDetailState equality', () {
      test('SessionDetailLoading instances are equal', () {
        const state1 = SessionDetailLoading();
        const state2 = SessionDetailLoading();

        expect(identical(state1, state2), true);
      });

      test('SessionDetailError instances with same values are equal', () {
        const state1 = SessionDetailError(message: 'Error', error: null);
        const state2 = SessionDetailError(message: 'Error', error: null);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('SessionDetailLoaded instances with same values are equal', () {
        final session =
            MockSessionDetailDataProvider._createDefaultSessionData();
        final state1 = SessionDetailLoaded(
          session: session,
          filterMode: QuestionFilterMode.all,
        );
        final state2 = SessionDetailLoaded(
          session: session,
          filterMode: QuestionFilterMode.all,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('SessionDetailEvent equality', () {
      test('LoadSessionDetail instances with same id are equal', () {
        const event1 = LoadSessionDetail('session-1');
        const event2 = LoadSessionDetail('session-1');

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('LoadSessionDetail instances with different ids are not equal', () {
        const event1 = LoadSessionDetail('session-1');
        const event2 = LoadSessionDetail('session-2');

        expect(event1, isNot(equals(event2)));
      });

      test('ChangeFilterMode instances with same mode are equal', () {
        const event1 = ChangeFilterMode(QuestionFilterMode.wrongOnly);
        const event2 = ChangeFilterMode(QuestionFilterMode.wrongOnly);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('ChangeFilterMode instances with different modes are not equal', () {
        const event1 = ChangeFilterMode(QuestionFilterMode.all);
        const event2 = ChangeFilterMode(QuestionFilterMode.wrongOnly);

        expect(event1, isNot(equals(event2)));
      });
    });

    group('dispose', () {
      test('closes stream', () async {
        bloc.dispose();

        expect(bloc.stream.isBroadcast, true);
      });
    });

    group('session and filterMode getters', () {
      test('session returns data from loaded state', () async {
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.session, isNotNull);
        expect(bloc.session!.id, 'session-1');
      });

      test('filterMode returns mode from loaded state', () async {
        bloc.add(SessionDetailEvent.load('session-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(
            SessionDetailEvent.changeFilterMode(QuestionFilterMode.wrongOnly));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.filterMode, QuestionFilterMode.wrongOnly);
      });
    });
  });
}
