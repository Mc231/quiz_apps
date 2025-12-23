import 'base_config.dart';

/// Configuration for quiz session storage behavior.
///
/// Controls when and how quiz sessions are persisted to storage.
class StorageConfig extends BaseConfig {
  /// Whether storage is enabled for this quiz.
  final bool enabled;

  /// Whether to save individual question answers during the quiz.
  ///
  /// If true, each answer is saved immediately after the user submits.
  /// If false, all answers are saved only at quiz completion.
  final bool saveAnswersDuringQuiz;

  /// Whether to update statistics in real-time during the quiz.
  ///
  /// If true, statistics are updated after each question.
  /// If false, statistics are updated only at quiz completion.
  final bool updateStatsRealtime;

  /// Whether to allow session recovery for interrupted quizzes.
  ///
  /// If true, the app can offer to resume an interrupted session.
  final bool allowSessionRecovery;

  /// Maximum age in hours for recoverable sessions.
  ///
  /// Sessions older than this will not be offered for recovery.
  final int sessionRecoveryMaxAgeHours;

  /// Unique quiz type identifier for statistics grouping.
  ///
  /// Examples: "flags", "capitals", "math"
  final String? quizType;

  /// Optional category within the quiz type.
  ///
  /// Examples: "europe", "asia", "easy", "hard"
  final String? quizCategory;

  /// Display name for the quiz (shown in history/stats).
  final String? quizName;

  /// App version string to record with sessions.
  final String appVersion;

  @override
  final int version;

  const StorageConfig({
    this.enabled = true,
    this.saveAnswersDuringQuiz = true,
    this.updateStatsRealtime = false,
    this.allowSessionRecovery = true,
    this.sessionRecoveryMaxAgeHours = 24,
    this.quizType,
    this.quizCategory,
    this.quizName,
    this.appVersion = '1.0.0',
    this.version = 1,
  });

  /// Configuration with storage disabled.
  static const disabled = StorageConfig(enabled: false);

  /// Default configuration with standard settings.
  static const defaultConfig = StorageConfig();

  @override
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'enabled': enabled,
      'saveAnswersDuringQuiz': saveAnswersDuringQuiz,
      'updateStatsRealtime': updateStatsRealtime,
      'allowSessionRecovery': allowSessionRecovery,
      'sessionRecoveryMaxAgeHours': sessionRecoveryMaxAgeHours,
      'quizType': quizType,
      'quizCategory': quizCategory,
      'quizName': quizName,
      'appVersion': appVersion,
    };
  }

  factory StorageConfig.fromMap(Map<String, dynamic> map) {
    return StorageConfig(
      version: map['version'] as int? ?? 1,
      enabled: map['enabled'] as bool? ?? true,
      saveAnswersDuringQuiz: map['saveAnswersDuringQuiz'] as bool? ?? true,
      updateStatsRealtime: map['updateStatsRealtime'] as bool? ?? false,
      allowSessionRecovery: map['allowSessionRecovery'] as bool? ?? true,
      sessionRecoveryMaxAgeHours:
          map['sessionRecoveryMaxAgeHours'] as int? ?? 24,
      quizType: map['quizType'] as String?,
      quizCategory: map['quizCategory'] as String?,
      quizName: map['quizName'] as String?,
      appVersion: map['appVersion'] as String? ?? '1.0.0',
    );
  }

  StorageConfig copyWith({
    bool? enabled,
    bool? saveAnswersDuringQuiz,
    bool? updateStatsRealtime,
    bool? allowSessionRecovery,
    int? sessionRecoveryMaxAgeHours,
    String? quizType,
    String? quizCategory,
    String? quizName,
    String? appVersion,
  }) {
    return StorageConfig(
      enabled: enabled ?? this.enabled,
      saveAnswersDuringQuiz:
          saveAnswersDuringQuiz ?? this.saveAnswersDuringQuiz,
      updateStatsRealtime: updateStatsRealtime ?? this.updateStatsRealtime,
      allowSessionRecovery: allowSessionRecovery ?? this.allowSessionRecovery,
      sessionRecoveryMaxAgeHours:
          sessionRecoveryMaxAgeHours ?? this.sessionRecoveryMaxAgeHours,
      quizType: quizType ?? this.quizType,
      quizCategory: quizCategory ?? this.quizCategory,
      quizName: quizName ?? this.quizName,
      appVersion: appVersion ?? this.appVersion,
      version: version,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StorageConfig &&
        other.enabled == enabled &&
        other.saveAnswersDuringQuiz == saveAnswersDuringQuiz &&
        other.updateStatsRealtime == updateStatsRealtime &&
        other.allowSessionRecovery == allowSessionRecovery &&
        other.sessionRecoveryMaxAgeHours == sessionRecoveryMaxAgeHours &&
        other.quizType == quizType &&
        other.quizCategory == quizCategory &&
        other.quizName == quizName &&
        other.appVersion == appVersion;
  }

  @override
  int get hashCode {
    return Object.hash(
      enabled,
      saveAnswersDuringQuiz,
      updateStatsRealtime,
      allowSessionRecovery,
      sessionRecoveryMaxAgeHours,
      quizType,
      quizCategory,
      quizName,
      appVersion,
    );
  }

  @override
  String toString() {
    return 'StorageConfig(enabled: $enabled, quizType: $quizType, quizName: $quizName)';
  }
}
