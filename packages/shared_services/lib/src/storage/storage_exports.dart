/// Storage module exports.
///
/// This file exports all public APIs for the storage module.
library;

// Database
export 'database/app_database.dart';
export 'database/database_config.dart';
export 'database/database_initializer.dart';

// Table definitions
export 'database/tables/daily_statistics_table.dart';
export 'database/tables/practice_progress_table.dart';
export 'database/tables/question_answers_table.dart';
export 'database/tables/quiz_sessions_table.dart';
export 'database/tables/settings_table.dart';
export 'database/tables/statistics_tables.dart';
export 'database/tables/streak_table.dart';

// Models
export 'models/daily_statistics.dart';
export 'models/global_statistics.dart';
export 'models/paginated_result.dart';
export 'models/practice_question.dart';
export 'models/question_answer.dart';
export 'models/quiz_session.dart';
export 'models/quiz_type_statistics.dart';
export 'models/streak_data.dart';
export 'models/user_settings_model.dart';

// Data Sources
export 'data_sources/data_sources_exports.dart';

// Repositories
export 'repositories/repositories_exports.dart';

// Storage Service
export 'storage_service.dart';

// Quiz Storage Adapter
export 'quiz_storage_adapter.dart';

// Export Services
export 'services/data_export_service.dart';
export 'services/session_export_service.dart';
