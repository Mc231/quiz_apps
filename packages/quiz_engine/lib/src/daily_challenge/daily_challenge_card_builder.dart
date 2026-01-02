import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import 'daily_challenge_card.dart';

/// A builder widget that manages loading daily challenge status
/// and renders a [DailyChallengeCard].
///
/// This widget handles:
/// - Loading today's challenge from the service
/// - Watching status updates from the service
/// - Showing appropriate loading/error states
///
/// Example:
/// ```dart
/// DailyChallengeCardBuilder(
///   service: dailyChallengeService,
///   onStartChallenge: (challenge) => navigateToChallenge(challenge),
///   onViewResults: (result) => navigateToResults(result),
/// )
/// ```
class DailyChallengeCardBuilder extends StatefulWidget {
  /// Creates a [DailyChallengeCardBuilder].
  const DailyChallengeCardBuilder({
    super.key,
    required this.service,
    this.onStartChallenge,
    this.onViewResults,
    this.style = const DailyChallengeCardStyle(),
    this.loadingWidget,
    this.errorBuilder,
  });

  /// The daily challenge service.
  ///
  /// The service is pre-configured with available categories, rotation
  /// strategy, question count, and time limit.
  final DailyChallengeService service;

  /// Callback when user wants to start the challenge.
  final void Function(DailyChallenge challenge)? onStartChallenge;

  /// Callback when user wants to view completed results.
  final void Function(DailyChallengeResult result)? onViewResults;

  /// Style configuration for the card.
  final DailyChallengeCardStyle style;

  /// Widget to show while loading.
  final Widget? loadingWidget;

  /// Builder for error state.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<DailyChallengeCardBuilder> createState() =>
      _DailyChallengeCardBuilderState();
}

class _DailyChallengeCardBuilderState extends State<DailyChallengeCardBuilder> {
  DailyChallengeStatus? _status;
  bool _isLoading = true;
  Object? _error;
  StreamSubscription<DailyChallengeStatus>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  @override
  void didUpdateWidget(DailyChallengeCardBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      _statusSubscription?.cancel();
      _loadChallenge();
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get or create today's challenge (service handles category selection)
      await widget.service.getTodaysChallenge();

      // Watch status updates
      _statusSubscription?.cancel();
      _statusSubscription = widget.service.watchTodayStatus().listen(
        (status) {
          if (mounted) {
            setState(() {
              _status = status;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = error;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const SizedBox(
            height: 100,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ??
          const SizedBox.shrink();
    }

    final status = _status;
    if (status == null) {
      return const SizedBox.shrink();
    }

    // Hide card if completed and hideWhenCompleted is enabled
    if (status.isCompleted && widget.style.hideWhenCompleted) {
      return const SizedBox.shrink();
    }

    return DailyChallengeCard(
      status: status,
      style: widget.style,
      onTap: widget.onStartChallenge != null
          ? () => widget.onStartChallenge!(status.challenge)
          : null,
      onViewResults: status.result != null && widget.onViewResults != null
          ? () => widget.onViewResults!(status.result!)
          : null,
    );
  }
}
