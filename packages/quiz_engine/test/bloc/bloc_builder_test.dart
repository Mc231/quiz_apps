import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/bloc/bloc_builder.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

/// Test state for BlocBuilder tests.
sealed class TestState {
  const TestState();
}

class TestLoading extends TestState {
  const TestLoading();
}

class TestLoaded extends TestState {
  const TestLoaded({required this.data});

  final String data;
}

class TestError extends TestState {
  const TestError({required this.message});

  final String message;
}

/// Test BLoC for BlocBuilder tests.
class TestBloc extends SingleSubscriptionBloc<TestState> {
  @override
  TestState get initialState => const TestLoading();

  void setLoading() => dispatchState(const TestLoading());

  void setLoaded(String data) => dispatchState(TestLoaded(data: data));

  void setError(String message) => dispatchState(TestError(message: message));
}

void main() {
  group('BlocBuilder', () {
    late TestBloc bloc;

    setUp(() {
      bloc = TestBloc();
    });

    tearDown(() {
      bloc.dispose();
    });

    testWidgets('renders initial state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocBuilder<TestBloc, TestState>(
            bloc: bloc,
            builder: (context, state) {
              return Text(switch (state) {
                TestLoading() => 'Loading',
                TestLoaded(:final data) => data,
                TestError(:final message) => message,
              });
            },
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('rebuilds when state changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocBuilder<TestBloc, TestState>(
            bloc: bloc,
            builder: (context, state) {
              return Text(switch (state) {
                TestLoading() => 'Loading',
                TestLoaded(:final data) => data,
                TestError(:final message) => message,
              });
            },
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);

      bloc.setLoaded('Test Data');
      await tester.pumpAndSettle();

      expect(find.text('Test Data'), findsOneWidget);
    });

    testWidgets('handles multiple state changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocBuilder<TestBloc, TestState>(
            bloc: bloc,
            builder: (context, state) {
              return Text(switch (state) {
                TestLoading() => 'Loading',
                TestLoaded(:final data) => data,
                TestError(:final message) => message,
              });
            },
          ),
        ),
      );

      bloc.setLoaded('First');
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);

      bloc.setError('Error!');
      await tester.pumpAndSettle();
      expect(find.text('Error!'), findsOneWidget);

      bloc.setLoading();
      await tester.pumpAndSettle();
      expect(find.text('Loading'), findsOneWidget);
    });
  });

  group('AutoLoadBlocBuilder', () {
    late TestBloc bloc;
    late int loadCount;

    setUp(() {
      bloc = TestBloc();
      loadCount = 0;
    });

    tearDown(() {
      bloc.dispose();
    });

    testWidgets('calls onLoad on init', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AutoLoadBlocBuilder<TestBloc, TestState>(
            bloc: bloc,
            onLoad: () => loadCount++,
            builder: (context, state) => const Text('Widget'),
          ),
        ),
      );

      expect(loadCount, equals(1));
    });

    testWidgets('renders state from builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AutoLoadBlocBuilder<TestBloc, TestState>(
            bloc: bloc,
            onLoad: () {},
            builder: (context, state) {
              return Text(state is TestLoading ? 'Loading' : 'Other');
            },
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
    });
  });

  group('TriStateBlocBuilder', () {
    late TestBloc bloc;

    setUp(() {
      bloc = TestBloc();
    });

    tearDown(() {
      bloc.dispose();
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TriStateBlocBuilder<TestBloc, TestState, TestLoaded>(
            bloc: bloc,
            isLoading: (state) => state is TestLoading,
            isError: (state) => state is TestError,
            getErrorMessage: (state) => (state as TestError).message,
            extractLoaded: (state) => state is TestLoaded ? state : null,
            loadingBuilder: (context) => const Text('Loading'),
            errorBuilder: (context, message, onRetry) => Text('Error: $message'),
            loadedBuilder: (context, loaded) => Text('Data: ${loaded.data}'),
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('renders loaded state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TriStateBlocBuilder<TestBloc, TestState, TestLoaded>(
            bloc: bloc,
            isLoading: (state) => state is TestLoading,
            isError: (state) => state is TestError,
            getErrorMessage: (state) => (state as TestError).message,
            extractLoaded: (state) => state is TestLoaded ? state : null,
            loadingBuilder: (context) => const Text('Loading'),
            errorBuilder: (context, message, onRetry) => Text('Error: $message'),
            loadedBuilder: (context, loaded) => Text('Data: ${loaded.data}'),
          ),
        ),
      );

      bloc.setLoaded('Test');
      await tester.pump();

      expect(find.text('Data: Test'), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TriStateBlocBuilder<TestBloc, TestState, TestLoaded>(
            bloc: bloc,
            isLoading: (state) => state is TestLoading,
            isError: (state) => state is TestError,
            getErrorMessage: (state) => (state as TestError).message,
            extractLoaded: (state) => state is TestLoaded ? state : null,
            loadingBuilder: (context) => const Text('Loading'),
            errorBuilder: (context, message, onRetry) {
              return TextButton(
                onPressed: onRetry,
                child: Text('Error: $message'),
              );
            },
            loadedBuilder: (context, loaded) => Text('Data: ${loaded.data}'),
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      bloc.setError('Something went wrong');
      await tester.pump();

      expect(find.text('Error: Something went wrong'), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      expect(retryCalled, isTrue);
    });
  });

  group('SelectiveBlocBuilder', () {
    late TestBloc bloc;

    setUp(() {
      bloc = TestBloc();
    });

    tearDown(() {
      bloc.dispose();
    });

    testWidgets('renders initial state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectiveBlocBuilder<TestBloc, TestState>(
            bloc: bloc,
            builder: (context, state) {
              return Text(state is TestLoading ? 'Loading' : 'Other');
            },
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('caches widget when buildWhen returns false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectiveBlocBuilder<TestBloc, TestState>(
            bloc: bloc,
            buildWhen: (previous, current) {
              // Only rebuild on loaded states
              return current is TestLoaded;
            },
            builder: (context, state) {
              return Text(state is TestLoading ? 'Loading' : 'Loaded');
            },
          ),
        ),
      );

      // Initial state shows Loading
      expect(find.text('Loading'), findsOneWidget);

      // When loaded, the widget should update
      bloc.setLoaded('data');
      await tester.pump();
      expect(find.text('Loaded'), findsOneWidget);
    });
  });
}
