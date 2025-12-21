import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:quiz_engine_core/src/bloc/bloc.dart';

/// A simple mock BLoC for testing.
class MockBloc extends Bloc {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  group('BlocProvider Tests', () {
    testWidgets('provides the correct bloc instance', (WidgetTester tester) async {
      // Given
      final mockBloc = MockBloc();

      // When
      await tester.pumpWidget(
        BlocProvider<MockBloc>(
          bloc: mockBloc,
          child: Builder(
            builder: (context) {
              final retrievedBloc = BlocProvider.of<MockBloc>(context);
              expect(retrievedBloc, equals(mockBloc));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('disposes the bloc when the provider is removed', (WidgetTester tester) async {
      // Given
      final mockBloc = MockBloc();

      await tester.pumpWidget(
        BlocProvider<MockBloc>(
          bloc: mockBloc,
          child: const SizedBox(),
        ),
      );

      // When
      await tester.pumpWidget(const SizedBox());

      // Then
      expect(mockBloc.disposed, isTrue);
    });

    testWidgets('allows nested BlocProviders with different types', (WidgetTester tester) async {
      // Given
      final outerBloc = MockBloc();
      final innerBloc = MockBloc();

      // When
      await tester.pumpWidget(
        BlocProvider<MockBloc>(
          bloc: outerBloc,
          child: BlocProvider<Bloc>(
            bloc: innerBloc,
            child: Builder(
              builder: (context) {
                final retrievedOuterBloc = BlocProvider.of<MockBloc>(context);
                final retrievedInnerBloc = BlocProvider.of<Bloc>(context);

                // Then
                expect(retrievedOuterBloc, equals(outerBloc));
                expect(retrievedInnerBloc, equals(innerBloc));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });
}