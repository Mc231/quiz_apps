import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import 'widgets/achievement_notification.dart';

/// Controller for managing achievement unlock notifications.
///
/// Handles displaying notifications as overlays and queuing multiple
/// achievements when they are unlocked in quick succession.
///
/// Example:
/// ```dart
/// // Create controller
/// final controller = AchievementNotificationController();
///
/// // Initialize with overlay state
/// controller.attach(Overlay.of(context));
///
/// // Show achievement notification
/// controller.show(unlockedAchievement);
///
/// // Dispose when done
/// controller.dispose();
/// ```
class AchievementNotificationController {
  /// Creates an [AchievementNotificationController].
  AchievementNotificationController({
    this.style = const AchievementNotificationStyle(),
    this.hapticService,
    this.audioService,
    this.analyticsService,
    this.maxQueueSize = 10,
    this.position = AchievementNotificationPosition.top,
  });

  /// Style for notifications.
  final AchievementNotificationStyle style;

  /// Optional haptic service for feedback.
  final HapticService? hapticService;

  /// Optional audio service for sound effects.
  final AudioService? audioService;

  /// Optional analytics service for tracking notification events.
  final AnalyticsService? analyticsService;

  /// Maximum number of achievements to queue.
  final int maxQueueSize;

  /// Position where notifications appear.
  final AchievementNotificationPosition position;

  OverlayState? _overlayState;
  OverlayEntry? _currentEntry;
  final Queue<Achievement> _queue = Queue<Achievement>();
  bool _isShowing = false;
  bool _isDisposed = false;
  DateTime? _currentNotificationShownAt;

  /// Stream of achievement unlock events.
  ///
  /// Emits when an achievement notification is shown.
  Stream<Achievement> get onShow => _showController.stream;
  final _showController = StreamController<Achievement>.broadcast();

  /// Stream of achievement dismiss events.
  ///
  /// Emits when an achievement notification is dismissed.
  Stream<Achievement> get onDismiss => _dismissController.stream;
  final _dismissController = StreamController<Achievement>.broadcast();

  /// Number of achievements waiting in the queue.
  int get queueLength => _queue.length;

  /// Whether a notification is currently being displayed.
  bool get isShowing => _isShowing;

  /// Attaches the controller to an overlay.
  ///
  /// This must be called before [show] can be used.
  void attach(OverlayState overlayState) {
    _overlayState = overlayState;
  }

  /// Shows an achievement notification.
  ///
  /// If a notification is already showing, the achievement is added
  /// to the queue and will be shown after the current one is dismissed.
  ///
  /// Returns true if the achievement was shown or queued successfully.
  bool show(Achievement achievement) {
    if (_isDisposed) return false;

    if (_overlayState == null) {
      debugPrint(
        'AchievementNotificationController: No overlay attached. '
        'Call attach() before showing notifications.',
      );
      return false;
    }

    if (_isShowing) {
      // Queue the achievement if not already showing
      if (_queue.length < maxQueueSize) {
        _queue.add(achievement);
        return true;
      }
      return false;
    }

    _showAchievement(achievement);
    return true;
  }

  /// Shows multiple achievements.
  ///
  /// Queues all achievements and shows them one by one.
  void showAll(List<Achievement> achievements) {
    for (final achievement in achievements) {
      show(achievement);
    }
  }

  /// Dismisses the current notification immediately.
  void dismiss() {
    _removeCurrentEntry();
    _showNextInQueue();
  }

  /// Clears all queued achievements without showing them.
  void clearQueue() {
    _queue.clear();
  }

  /// Disposes of the controller and its resources.
  void dispose() {
    _isDisposed = true;
    _removeCurrentEntry();
    _queue.clear();
    _showController.close();
    _dismissController.close();
  }

  void _showAchievement(Achievement achievement) {
    _isShowing = true;
    _currentNotificationShownAt = DateTime.now();
    _showController.add(achievement);

    // Track notification shown event
    analyticsService?.logEvent(
      AchievementEvent.notificationShown(
        achievementId: achievement.id,
        achievementName: achievement.id, // Name requires context
        pointsAwarded: achievement.points,
        displayDuration: style.displayDuration,
      ),
    );

    _currentEntry = OverlayEntry(
      builder: (context) => _buildNotificationOverlay(context, achievement),
    );

    _overlayState!.insert(_currentEntry!);
  }

  Widget _buildNotificationOverlay(BuildContext context, Achievement achievement) {
    return Positioned(
      top: position == AchievementNotificationPosition.top ? 0 : null,
      bottom: position == AchievementNotificationPosition.bottom ? 0 : null,
      left: 0,
      right: 0,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: AchievementNotification(
            achievement: achievement,
            style: style,
            hapticService: hapticService,
            audioService: audioService,
            analyticsService: analyticsService,
            shownAt: _currentNotificationShownAt,
            onDismiss: () => _onNotificationDismissed(achievement),
          ),
        ),
      ),
    );
  }

  void _onNotificationDismissed(Achievement achievement) {
    _dismissController.add(achievement);
    _removeCurrentEntry();
    _showNextInQueue();
  }

  void _removeCurrentEntry() {
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;
  }

  void _showNextInQueue() {
    if (_queue.isNotEmpty && !_isDisposed) {
      final next = _queue.removeFirst();
      // Small delay between notifications
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_isDisposed) {
          _showAchievement(next);
        }
      });
    }
  }
}

/// Position where achievement notifications appear.
enum AchievementNotificationPosition {
  /// Notifications appear at the top of the screen.
  top,

  /// Notifications appear at the bottom of the screen.
  bottom,
}

/// A widget that provides [AchievementNotificationController] to its descendants.
///
/// This widget automatically attaches the controller to the overlay and
/// provides it via [AchievementNotifications.of(context)].
///
/// Example:
/// ```dart
/// AchievementNotifications(
///   controller: myController,
///   child: MyApp(),
/// )
///
/// // Later in the tree:
/// AchievementNotifications.of(context).show(achievement);
/// ```
class AchievementNotifications extends StatefulWidget {
  /// Creates an [AchievementNotifications] widget.
  const AchievementNotifications({
    super.key,
    required this.child,
    this.controller,
    this.style = const AchievementNotificationStyle(),
    this.hapticService,
    this.audioService,
    this.analyticsService,
    this.position = AchievementNotificationPosition.top,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Optional external controller. If not provided, one is created internally.
  final AchievementNotificationController? controller;

  /// Style for notifications.
  final AchievementNotificationStyle style;

  /// Optional haptic service.
  final HapticService? hapticService;

  /// Optional audio service.
  final AudioService? audioService;

  /// Optional analytics service.
  final AnalyticsService? analyticsService;

  /// Position where notifications appear.
  final AchievementNotificationPosition position;

  /// Gets the controller from the closest [AchievementNotifications] ancestor.
  static AchievementNotificationController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_AchievementNotificationsState>();
    if (state == null) {
      throw FlutterError(
        'AchievementNotifications.of() called with a context that does not '
        'contain an AchievementNotifications widget.\n'
        'Ensure that the context passed to AchievementNotifications.of() '
        'is a descendant of an AchievementNotifications widget.',
      );
    }
    return state._controller;
  }

  /// Gets the controller from the closest [AchievementNotifications] ancestor,
  /// or null if none exists.
  static AchievementNotificationController? maybeOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_AchievementNotificationsState>();
    return state?._controller;
  }

  @override
  State<AchievementNotifications> createState() =>
      _AchievementNotificationsState();
}

class _AchievementNotificationsState extends State<AchievementNotifications> {
  late AchievementNotificationController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = AchievementNotificationController(
        style: widget.style,
        hapticService: widget.hapticService,
        audioService: widget.audioService,
        analyticsService: widget.analyticsService,
        position: widget.position,
      );
      _ownsController = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Attach to overlay when available
    final overlay = Overlay.maybeOf(context);
    if (overlay != null) {
      _controller.attach(overlay);
    }
  }

  @override
  void didUpdateWidget(AchievementNotifications oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      _initController();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension for showing achievement notifications from BuildContext.
extension AchievementNotificationContext on BuildContext {
  /// Shows an achievement notification using the nearest controller.
  ///
  /// Returns false if no controller is available in the widget tree.
  bool showAchievementNotification(Achievement achievement) {
    final controller = AchievementNotifications.maybeOf(this);
    if (controller != null) {
      return controller.show(achievement);
    }
    return false;
  }
}
