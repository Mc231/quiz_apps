import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import '../bloc/bloc_provider.dart';

/// Callback type for background time changes.
typedef BackgroundTimeCallback = void Function(Duration backgroundDuration);

/// A widget that handles app lifecycle changes for quiz timers.
///
/// This widget automatically pauses/resumes quiz timers when the app
/// goes to background or returns to foreground. It gets the QuizBloc
/// from the nearest BlocProvider in the widget tree.
///
/// Additionally, it tracks background time and can optionally log analytics
/// events for quiz pause/resume.
///
/// Usage:
/// ```dart
/// BlocProvider(
///   bloc: quizBloc,
///   child: QuizLifecycleHandler(
///     analyticsService: analyticsService, // Optional
///     onBackgroundTimeChanged: (duration) {
///       print('Was in background for $duration');
///     },
///     child: QuizWidget(...),
///   ),
/// )
/// ```
class QuizLifecycleHandler extends StatefulWidget {
  /// The child widget (typically the quiz screen)
  final Widget child;

  /// Optional analytics service for logging pause/resume events.
  final AnalyticsService analyticsService;

  /// Callback when the app returns from background with the duration.
  final BackgroundTimeCallback? onBackgroundTimeChanged;

  /// The quiz ID for analytics events.
  final String? quizId;

  /// The quiz name for analytics events.
  final String? quizName;

  const QuizLifecycleHandler({
    super.key,
    required this.child,
    required this.analyticsService,
    this.onBackgroundTimeChanged,
    this.quizId,
    this.quizName,
  });

  @override
  State<QuizLifecycleHandler> createState() => _QuizLifecycleHandlerState();
}

class _QuizLifecycleHandlerState extends State<QuizLifecycleHandler>
    with WidgetsBindingObserver {
  late QuizBloc _bloc;
  StreamSubscription<QuizState>? _stateSubscription;

  /// Timestamp when the app went to background.
  DateTime? _backgroundStartTime;

  /// Total accumulated background time during this quiz session.
  Duration _totalBackgroundTime = Duration.zero;

  /// Cached quiz progress for analytics.
  int _currentQuestion = 0;
  int _totalQuestions = 0;

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

    // Subscribe to state stream to cache progress info for analytics
    _stateSubscription?.cancel();
    _stateSubscription = _bloc.stream.listen(_onStateChanged);
  }

  void _onStateChanged(QuizState state) {
    // Cache progress info from state for analytics
    switch (state) {
      case QuestionState():
        _currentQuestion = state.progress;
        _totalQuestions = state.total;
      case AnswerFeedbackState():
        _currentQuestion = state.progress;
        _totalQuestions = state.total;
      case LoadingState():
      case QuizCompletedState():
        // Don't update progress for these states
        break;
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background or becoming inactive (e.g., incoming call)
        _onAppBackgrounded();
      case AppLifecycleState.resumed:
        // App returning to foreground
        _onAppForegrounded();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is detached or hidden, pause timers
        _onAppBackgrounded();
    }
  }

  void _onAppBackgrounded() {
    // Only record start time if not already backgrounded
    _backgroundStartTime ??= DateTime.now();

    _bloc.pauseTimers();

    // Log analytics event if service is provided
    _logPauseEvent();
  }

  void _onAppForegrounded() {
    final backgroundDuration = _calculateBackgroundDuration();

    if (backgroundDuration != null) {
      _totalBackgroundTime += backgroundDuration;
      widget.onBackgroundTimeChanged?.call(backgroundDuration);
    }

    _backgroundStartTime = null;
    _bloc.resumeTimers();

    // Log analytics event if service is provided
    if (backgroundDuration != null) {
      _logResumeEvent(backgroundDuration);
    }
  }

  Duration? _calculateBackgroundDuration() {
    if (_backgroundStartTime == null) return null;
    return DateTime.now().difference(_backgroundStartTime!);
  }

  void _logPauseEvent() {
    if (widget.quizId == null || widget.quizName == null) return;

    widget.analyticsService.logEvent(
      QuizEvent.paused(
        quizId: widget.quizId!,
        quizName: widget.quizName!,
        currentQuestion: _currentQuestion,
        totalQuestions: _totalQuestions,
      ),
    );
  }

  void _logResumeEvent(Duration pauseDuration) {
    if (widget.quizId == null || widget.quizName == null) return;

    widget.analyticsService.logEvent(
      QuizEvent.resumed(
        quizId: widget.quizId!,
        quizName: widget.quizName!,
        currentQuestion: _currentQuestion,
        totalQuestions: _totalQuestions,
        pauseDuration: pauseDuration,
      ),
    );
  }

  /// Returns the current background duration if the app is backgrounded.
  Duration? get currentBackgroundDuration => _calculateBackgroundDuration();

  /// Returns the total accumulated background time during this quiz session.
  Duration get totalBackgroundTime => _totalBackgroundTime;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
