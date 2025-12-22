library;

/// Export file for data provider implementations
///
/// These implementations use platform-specific packages (http, flutter services)
/// and should be used by apps to fetch quiz data from remote sources or local assets.

export 'quiz_data_provider.dart';
export 'http_quiz_data_provider.dart';
export 'cached_http_quiz_data_provider.dart';
