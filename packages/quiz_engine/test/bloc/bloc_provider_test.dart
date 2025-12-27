import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/bloc/bloc_provider.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

/// Test BLoC for provider tests.
class TestBloc extends Bloc {
  bool isDisposed = false;
  final String name;

  TestBloc({this.name = 'default'});

  @override
  void dispose() {
    isDisposed = true;
  }
}

void main() {
  group('BlocProvider', () {
    testWidgets('provides bloc to child', (tester) async {
      final bloc = TestBloc(name: 'provided');

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            bloc: bloc,
            child: Builder(
              builder: (context) {
                final retrievedBloc = BlocProvider.of<TestBloc>(context);
                return Text(retrievedBloc.name);
              },
            ),
          ),
        ),
      );

      expect(find.text('provided'), findsOneWidget);
    });

    testWidgets('disposes bloc when removed', (tester) async {
      final bloc = TestBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            bloc: bloc,
            child: const Text('Child'),
          ),
        ),
      );

      expect(bloc.isDisposed, isFalse);

      await tester.pumpWidget(const MaterialApp(home: Text('New')));

      expect(bloc.isDisposed, isTrue);
    });

    testWidgets('does not dispose bloc when disposeBloc is false', (tester) async {
      final bloc = TestBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            bloc: bloc,
            disposeBloc: false,
            child: const Text('Child'),
          ),
        ),
      );

      expect(bloc.isDisposed, isFalse);

      await tester.pumpWidget(const MaterialApp(home: Text('New')));

      expect(bloc.isDisposed, isFalse);
    });

    group('BlocProvider.value', () {
      testWidgets('provides bloc without disposing', (tester) async {
        final bloc = TestBloc(name: 'value');

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<TestBloc>.value(
              bloc: bloc,
              child: Builder(
                builder: (context) {
                  final retrievedBloc = BlocProvider.of<TestBloc>(context);
                  return Text(retrievedBloc.name);
                },
              ),
            ),
          ),
        );

        expect(find.text('value'), findsOneWidget);

        await tester.pumpWidget(const MaterialApp(home: Text('New')));

        expect(bloc.isDisposed, isFalse);
      });
    });

    group('of', () {
      testWidgets('returns bloc when found', (tester) async {
        final bloc = TestBloc(name: 'found');

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<TestBloc>(
              bloc: bloc,
              child: Builder(
                builder: (context) {
                  final retrievedBloc = BlocProvider.of<TestBloc>(context);
                  return Text(retrievedBloc.name);
                },
              ),
            ),
          ),
        );

        expect(find.text('found'), findsOneWidget);
      });

      testWidgets('throws assertion when bloc not found', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // This should throw an assertion error
                try {
                  BlocProvider.of<TestBloc>(context);
                  return const Text('Found');
                } catch (e) {
                  return const Text('Not Found');
                }
              },
            ),
          ),
        );

        expect(find.text('Not Found'), findsOneWidget);
      });
    });

    group('maybeOf', () {
      testWidgets('returns bloc when found', (tester) async {
        final bloc = TestBloc(name: 'maybe');

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<TestBloc>(
              bloc: bloc,
              child: Builder(
                builder: (context) {
                  final retrievedBloc = BlocProvider.maybeOf<TestBloc>(context);
                  return Text(retrievedBloc?.name ?? 'null');
                },
              ),
            ),
          ),
        );

        expect(find.text('maybe'), findsOneWidget);
      });

      testWidgets('returns null when bloc not found', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final retrievedBloc = BlocProvider.maybeOf<TestBloc>(context);
                return Text(retrievedBloc?.name ?? 'null');
              },
            ),
          ),
        );

        expect(find.text('null'), findsOneWidget);
      });
    });
  });

  group('BlocProviderExtension', () {
    testWidgets('bloc<T>() returns bloc from context', (tester) async {
      final bloc = TestBloc(name: 'extension');

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            bloc: bloc,
            child: Builder(
              builder: (context) {
                final retrievedBloc = context.bloc<TestBloc>();
                return Text(retrievedBloc.name);
              },
            ),
          ),
        ),
      );

      expect(find.text('extension'), findsOneWidget);
    });

    testWidgets('maybeBloc<T>() returns bloc or null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final retrievedBloc = context.maybeBloc<TestBloc>();
              return Text(retrievedBloc?.name ?? 'null');
            },
          ),
        ),
      );

      expect(find.text('null'), findsOneWidget);
    });
  });
}
