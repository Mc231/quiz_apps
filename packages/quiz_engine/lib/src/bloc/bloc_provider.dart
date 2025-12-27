import 'package:flutter/cupertino.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

/// A Flutter widget that provides a BLoC to its descendants.
///
/// The `BlocProvider` class is a generic widget that manages the lifecycle
/// of a BLoC instance. It provides the BLoC to its child widget and any
/// descendants through the widget tree, facilitating the use of the BLoC
/// pattern in a Flutter application. This widget ensures that the BLoC
/// is properly disposed of when it is no longer needed.
///
/// The `BlocProvider` widget should be used at a level in the widget tree
/// where the BLoC needs to be accessed by multiple widgets.
///
/// Example usage:
/// ```dart
/// BlocProvider(
///   bloc: CounterBloc(),
///   child: MyCounterWidget(),
/// )
/// ```
///
/// Descendant widgets can access the BLoC instance using the `BlocProvider.of` method:
/// ```dart
/// final bloc = BlocProvider.of<CounterBloc>(context);
/// ```
class BlocProvider<T extends Bloc> extends StatefulWidget {
  /// The child widget that can access the provided BLoC.
  final Widget child;

  /// The BLoC instance to be provided to the widget tree.
  final T bloc;

  /// Whether to dispose the BLoC when this widget is disposed.
  ///
  /// Defaults to `true`. Set to `false` if the BLoC lifecycle is managed
  /// elsewhere (e.g., in a service locator or parent widget).
  final bool disposeBloc;

  /// Creates a `BlocProvider` widget.
  ///
  /// [bloc] is the BLoC instance that will be provided to the widget tree.
  /// [child] is the widget that will be the root of the widget subtree that can access the BLoC.
  /// [disposeBloc] controls whether to dispose the BLoC when this widget is disposed.
  const BlocProvider({
    super.key,
    required this.bloc,
    required this.child,
    this.disposeBloc = true,
  });

  /// Creates a `BlocProvider` that doesn't dispose the BLoC.
  ///
  /// Use this when the BLoC lifecycle is managed elsewhere.
  ///
  /// Example:
  /// ```dart
  /// BlocProvider.value(
  ///   bloc: existingBloc,
  ///   child: MyWidget(),
  /// )
  /// ```
  const BlocProvider.value({
    super.key,
    required this.bloc,
    required this.child,
  }) : disposeBloc = false;

  /// Retrieves the BLoC instance from the nearest ancestor `BlocProvider` of the specified type.
  ///
  /// This static method searches the widget tree for a `BlocProvider` of type [T]
  /// and returns the BLoC instance. It should be called within the build method
  /// of a widget that is a descendant of a `BlocProvider`.
  ///
  /// Throws an error if no ancestor `BlocProvider` of the specified type is found.
  ///
  /// Example usage:
  /// ```dart
  /// final bloc = BlocProvider.of<CounterBloc>(context);
  /// ```
  static T of<T extends Bloc>(BuildContext context) {
    final BlocProvider<T>? provider = context.findAncestorWidgetOfExactType();
    assert(
      provider != null,
      'No BlocProvider<$T> found in context. '
      'Make sure to wrap your widget tree with a BlocProvider<$T>.',
    );
    return provider!.bloc;
  }

  /// Retrieves the BLoC instance from the nearest ancestor `BlocProvider`,
  /// or returns `null` if not found.
  ///
  /// This is a safer alternative to [of] when the BLoC may not be available.
  ///
  /// Example usage:
  /// ```dart
  /// final bloc = BlocProvider.maybeOf<CounterBloc>(context);
  /// if (bloc != null) {
  ///   // Use the bloc
  /// }
  /// ```
  static T? maybeOf<T extends Bloc>(BuildContext context) {
    final BlocProvider<T>? provider = context.findAncestorWidgetOfExactType();
    return provider?.bloc;
  }

  @override
  State createState() => _BlocProviderState();
}

class _BlocProviderState extends State<BlocProvider> {
  @override
  Widget build(BuildContext context) => widget.child;

  /// Disposes the BLoC when the widget is removed from the widget tree.
  ///
  /// This method ensures that the BLoC's `dispose` method is called
  /// to release any resources and prevent memory leaks.
  /// Only disposes if [disposeBloc] is true.
  @override
  void dispose() {
    if (widget.disposeBloc) {
      widget.bloc.dispose();
    }
    super.dispose();
  }
}

/// Extension methods for accessing BLoCs from BuildContext.
extension BlocProviderExtension on BuildContext {
  /// Gets a BLoC of type [T] from the widget tree.
  ///
  /// Throws an error if no BlocProvider<T> is found.
  ///
  /// Example:
  /// ```dart
  /// final bloc = context.bloc<CounterBloc>();
  /// ```
  T bloc<T extends Bloc>() => BlocProvider.of<T>(this);

  /// Gets a BLoC of type [T] from the widget tree, or null if not found.
  ///
  /// Example:
  /// ```dart
  /// final bloc = context.maybeBloc<CounterBloc>();
  /// ```
  T? maybeBloc<T extends Bloc>() => BlocProvider.maybeOf<T>(this);
}
