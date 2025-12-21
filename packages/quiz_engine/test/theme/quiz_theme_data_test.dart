import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  group('QuizThemeData', () {
    test('creates instance with default values', () {
      const theme = QuizThemeData();

      expect(theme.buttonColor, Colors.black);
      expect(theme.buttonTextColor, Colors.white);
      expect(theme.buttonBorderColor, Colors.transparent);
      expect(theme.buttonBorderWidth, 0);
      expect(theme.buttonBorderRadius, const BorderRadius.all(Radius.circular(8)));
      expect(theme.buttonPadding, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      expect(theme.correctAnswerColor, Colors.green);
      expect(theme.incorrectAnswerColor, Colors.red);
      expect(theme.selectedAnswerColor, Colors.blue);
      expect(theme.progressBackgroundColor, Colors.grey);
      expect(theme.progressForegroundColor, Colors.blue);
      expect(theme.livesColor, Colors.red);
      expect(theme.hintsColor, Colors.orange);
      expect(theme.timerNormalColor, Colors.blue);
      expect(theme.timerWarningColor, Colors.orange);
      expect(theme.timerCriticalColor, Colors.red);
      expect(theme.starFilledColor, Colors.amber);
      expect(theme.starEmptyColor, Colors.grey);
    });

    test('creates light theme', () {
      final theme = QuizThemeData.light();

      expect(theme.buttonColor, Colors.black);
      expect(theme.buttonTextColor, Colors.white);
    });

    test('creates dark theme', () {
      final theme = QuizThemeData.dark();

      expect(theme.buttonColor, Colors.white);
      expect(theme.buttonTextColor, Colors.black);
      expect(theme.progressBackgroundColor, const Color(0xFF424242));
      expect(theme.progressForegroundColor, Colors.lightBlueAccent);
    });

    test('copyWith creates new instance with updated values', () {
      const original = QuizThemeData();

      final updated = original.copyWith(
        buttonColor: Colors.red,
        buttonTextColor: Colors.yellow,
        correctAnswerColor: Colors.cyan,
      );

      expect(updated.buttonColor, Colors.red);
      expect(updated.buttonTextColor, Colors.yellow);
      expect(updated.correctAnswerColor, Colors.cyan);
      // Original values remain unchanged for non-copied fields
      expect(updated.incorrectAnswerColor, Colors.red);
      expect(updated.buttonBorderColor, Colors.transparent);
    });

    test('copyWith with no parameters returns identical copy', () {
      const original = QuizThemeData();
      final copy = original.copyWith();

      expect(copy.buttonColor, original.buttonColor);
      expect(copy.buttonTextColor, original.buttonTextColor);
      expect(copy.correctAnswerColor, original.correctAnswerColor);
    });

    test('equality operator works correctly', () {
      const theme1 = QuizThemeData();
      const theme2 = QuizThemeData();
      const theme3 = QuizThemeData(buttonColor: Colors.red);

      expect(theme1, equals(theme2));
      expect(theme1, isNot(equals(theme3)));
    });

    test('hashCode is consistent', () {
      const theme1 = QuizThemeData();
      const theme2 = QuizThemeData();
      const theme3 = QuizThemeData(buttonColor: Colors.red);

      expect(theme1.hashCode, equals(theme2.hashCode));
      expect(theme1.hashCode, isNot(equals(theme3.hashCode)));
    });

    test('custom theme configuration', () {
      final customTheme = QuizThemeData(
        buttonColor: Colors.purple,
        buttonTextColor: Colors.white,
        buttonBorderColor: Colors.purpleAccent,
        buttonBorderWidth: 2,
        buttonBorderRadius: const BorderRadius.all(Radius.circular(12)),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        correctAnswerColor: const Color(0xFF00FF00),
        incorrectAnswerColor: const Color(0xFFFF0000),
      );

      expect(customTheme.buttonColor, Colors.purple);
      expect(customTheme.buttonTextColor, Colors.white);
      expect(customTheme.buttonBorderColor, Colors.purpleAccent);
      expect(customTheme.buttonBorderWidth, 2);
      expect(customTheme.buttonBorderRadius, const BorderRadius.all(Radius.circular(12)));
      expect(customTheme.buttonPadding, const EdgeInsets.symmetric(horizontal: 24, vertical: 12));
      expect(customTheme.correctAnswerColor, const Color(0xFF00FF00));
      expect(customTheme.incorrectAnswerColor, const Color(0xFFFF0000));
    });
  });
}