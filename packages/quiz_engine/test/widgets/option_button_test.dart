import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  testWidgets('Option button has a title', (WidgetTester tester) async {
    // Given
    final title = 'Title';
    // When
    await tester.pumpWidget(
      MaterialApp(
          home: OptionButton(title: title, onClickListener: () {})),
    );
    await tester.pump();
    // Then
    final titleFinder = find.text(title);
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Option button click works', (WidgetTester tester) async {
    // Given
    var buttonClicked = false;
    await tester.pumpWidget(MaterialApp(
        home: OptionButton(
            title: '',
            onClickListener: () {
              buttonClicked = true;
            })));
    await tester.pump();
    // When
    await tester.tap(find.byType(OptionButton));
    // Then
    expect(buttonClicked, equals(true));
  });
}
