/// Services module exports.
///
/// This barrel file exports all service-related classes for the quiz engine:
/// - [QuizServices] - The immutable container for all core services
/// - [QuizServicesProvider] - InheritedWidget for providing services down the tree
/// - [QuizServicesContext] - Extension for convenient context-based access
/// - [QuizServicesScope] - Widget for scoped service overrides
library;

export 'quiz_services.dart';
export 'quiz_services_context.dart';
export 'quiz_services_provider.dart';
export 'quiz_services_scope.dart';
