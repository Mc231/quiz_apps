/// Resource management module for quiz apps.
///
/// This module provides a complete solution for managing game resources
/// (lives, hints, skips) with support for:
/// - Daily free limits with midnight reset
/// - Permanent purchased resources
/// - Rewarded ad integration
/// - In-app purchase integration via [IAPService]
///
/// ## Getting Started
///
/// ```dart
/// // 1. Create configuration
/// final config = ResourceConfig.standard();
///
/// // 2. Create repository
/// final repository = InMemoryResourceRepository();
/// // or: SqliteResourceRepository(database)
///
/// // 3. Create manager
/// final manager = ResourceManager(
///   config: config,
///   repository: repository,
/// );
///
/// // 4. Initialize
/// await manager.initialize();
///
/// // 5. Use resources
/// if (manager.isAvailable(ResourceType.lives())) {
///   await manager.useResource(ResourceType.lives());
/// }
/// ```
///
/// ## Adding Monetization
///
/// When ready to add ads or purchases, provide the service implementations:
///
/// ```dart
/// final manager = ResourceManager(
///   config: config,
///   repository: repository,
///   adProvider: MyAdMobProvider(),     // Implement AdRewardProvider
///   iapService: StoreIAPService(...),  // Use IAPService from iap_exports
/// );
/// ```
library;

export 'providers/ad_reward_provider.dart';
export 'resource_config.dart';
export 'resource_inventory.dart';
export 'resource_manager.dart';
export 'resource_repository.dart';
export 'resource_type.dart';
export 'sqlite_resource_repository.dart';
