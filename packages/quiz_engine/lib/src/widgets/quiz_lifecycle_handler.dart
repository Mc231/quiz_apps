import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import '../bloc/bloc_provider.dart';

/// A widget that handles app lifecycle changes for quiz timers.
///
/// This widget automatically pauses/resumes quiz timers when the app
/// goes to background or returns to foreground. It gets the QuizBloc
/// from the nearest BlocProvider in the widget tree.
///
/// Usage:
/// ```dart
/// BlocProvider(
///   bloc: quizBloc,
///   child: QuizLifecycleHandler(
///     child: QuizWidget(...),
///   ),
/// )
/// ```
class QuizLifecycleHandler extends StatefulWidget {
  /// The child widget (typically the quiz screen)
  final Widget child;

  const QuizLifecycleHandler({
    super.key,
    required this.child,
  });

  @override
  State<QuizLifecycleHandler> createState() => _QuizLifecycleHandlerState();
}

class _QuizLifecycleHandlerState extends State<QuizLifecycleHandler>
    with WidgetsBindingObserver {
  late QuizBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the bloc from BlocProvider
    _bloc = BlocProvider.of<QuizBloc>(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background or becoming inactive (e.g., incoming call)
        _bloc.pauseTimers();
      case AppLifecycleState.resumed:
        // App returning to foreground
        _bloc.resumeTimers();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is detached or hidden, pause timers
        _bloc.pauseTimers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}