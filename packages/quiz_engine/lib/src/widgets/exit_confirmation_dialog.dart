import 'package:flutter/material.dart';

/// A dialog that confirms whether the user wants to exit the quiz.
///
/// This dialog is shown when the user attempts to navigate back from the quiz screen
/// and the exit confirmation is enabled in the quiz configuration.
class ExitConfirmationDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The message shown in the dialog
  final String message;

  /// The text for the confirmation button (defaults to "Yes")
  final String? confirmButtonText;

  /// The text for the cancel button (defaults to "No")
  final String? cancelButtonText;

  const ExitConfirmationDialog({
    super.key,
    this.title = 'Exit Quiz?',
    this.message = 'Are you sure you want to exit? Your progress will be lost.',
    this.confirmButtonText,
    this.cancelButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Return false - don't exit
            Navigator.of(context).pop(false);
          },
          child: Text(
            cancelButtonText ?? 'No',
          ),
        ),
        TextButton(
          onPressed: () {
            // Return true - exit
            Navigator.of(context).pop(true);
          },
          child: Text(
            confirmButtonText ?? 'Yes',
          ),
        ),
      ],
    );
  }

  /// Shows the exit confirmation dialog and returns the user's choice.
  ///
  /// Returns `true` if the user confirms they want to exit, `false` otherwise.
  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
    String? confirmButtonText,
    String? cancelButtonText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ExitConfirmationDialog(
          title: title ?? 'Exit Quiz?',
          message: message ?? 'Are you sure you want to exit? Your progress will be lost.',
          confirmButtonText: confirmButtonText,
          cancelButtonText: cancelButtonText,
        );
      },
    );

    // If dialog is dismissed without a choice, default to not exiting
    return result ?? false;
  }
}