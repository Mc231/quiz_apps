import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../achievements/flags_achievements_data_provider.dart';
import '../app/flags_quiz_app.dart';
import '../config/iap_config_production.dart';
import '../data/country_counts.dart';
import '../data/flags_categories.dart';
import '../data/flags_data_provider.dart';
import 'flags_quiz_dependencies.dart';

/// Provides a fully initialized [FlagsQuizApp] instance.
///
/// Handles Flutter binding initialization, shared services setup,
/// and creation of all app dependencies internally.
///
/// Example:
/// ```dart
/// void main() async {
///   runApp(await FlagsQuizAppProvider.provideApp());
/// }
/// ```
class FlagsQuizAppProvider {
  FlagsQuizAppProvider._();

  /// Provides a fully initialized [FlagsQuizApp].
  ///
  /// This method:
  /// 1. Ensures Flutter bindings are initialized
  /// 2. Initializes shared services (database, settings, etc.)
  /// 3. Loads secrets configuration from JSON
  /// 4. Loads country data for accurate question counts
  /// 5. Creates and initializes the achievements provider
  /// 6. Syncs achievements to catch any missed unlocks
  /// 7. Returns a configured [FlagsQuizApp] widget
  static Future<Widget> provideApp() async {
    final dependencies = await _initialize();
    return FlagsQuizApp(dependencies: dependencies);
  }

  /// Initializes all dependencies for the Flags Quiz app.
  static Future<FlagsQuizDependencies> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase before any Firebase services are used
    await Firebase.initializeApp();

    // Initialize shared services with timing and error reporting
    final initResult = await SharedServicesInitializer.initialize(
      config: SharedServicesConfig(
        onError: (serviceName, error, stack) {
          if (kDebugMode) {
            debugPrint('[SharedServices] Failed to init $serviceName: $error');
            debugPrint(stack.toString());
          }
        },
        onTiming: (stepName, duration) {
          if (kDebugMode) {
            debugPrint(
              '[SharedServices] $stepName: ${duration.inMilliseconds}ms',
            );
          }
        },
      ),
    );

    if (kDebugMode) {
      debugPrint('[SharedServices] $initResult');
      if (!initResult.isPerformant) {
        debugPrint(
          '[SharedServices] Warning: Initialization exceeded 500ms target',
        );
      }
    }

    // Load secrets from config file (falls back to empty config if not found)
    final secrets = await SecretsLoader.load(
      'config/secrets.json',
      onWarning: (message) {
        if (kDebugMode) {
          debugPrint('[Secrets] $message');
        }
      },
    );

    // Load country counts from JSON to display accurate question counts
    final countryCounts = await CountryCounts.load();

    // Get services from service locator
    final settingsService = sl.get<SettingsService>();
    final storageService = sl.get<StorageService>();
    final achievementService = sl.get<AchievementService>();
    final sessionRepository = sl.get<QuizSessionRepository>();

    // Create categories and data provider
    final categories = createFlagsCategories(countryCounts);
    const dataProvider = FlagsDataProvider();

    // Create achievements data provider and initialize at startup
    final achievementsProvider = FlagsAchievementsDataProvider(
      achievementService: achievementService,
      sessionRepository: sessionRepository,
    );
    await achievementsProvider.initialize();

    // Sync achievements on app start to catch any missed unlocks
    await achievementService.checkAll();

    // Initialize analytics with console logging for debugging
    final screenAnalyticsService = CompositeAnalyticsService(
      providers: [
        AnalyticsProviderConfig(
          provider: ConsoleAnalyticsService(),
          name: 'Console',
        ),
        AnalyticsProviderConfig(
          provider: FirebaseAnalyticsService(),
          name: 'Firebase',
        ),
      ],
    );
    await screenAnalyticsService.initialize();

    // Wrap with adapter to implement QuizAnalyticsService interface
    final quizAnalyticsService = QuizAnalyticsAdapter(screenAnalyticsService);

    // Create navigator observer for automatic screen tracking
    final navigatorObserver = AnalyticsNavigatorObserver(
      analyticsService: screenAnalyticsService,
    );

    // Initialize ads service with test IDs for development
    // Production IDs come from --dart-define-from-file=config/env.json
    final adsService = AdMobService(config: AdsConfig.test());
    await adsService.initialize();

    // Preload rewarded ad so it's ready when user needs it
    await adsService.loadRewardedAd();

    // Wrap with analytics tracking
    final analyticsAdsService = AnalyticsAdsService(
      adsService: adsService,
      analyticsService: screenAnalyticsService,
    );

    // Initialize IAP service
    // Toggle for testing: true = real store (license/sandbox testing), false = mock
    // ignore: dead_code - intentional feature flag for switching between mock and real
    const useRealIAPService = true;

    final IAPService iapService;
    // ignore: dead_code
    if (kDebugMode && !useRealIAPService) {
      // Mock service for UI development - simulates working store
      iapService = MockIAPService(
        config: IAPConfig.test(),
        simulatedDelay: const Duration(milliseconds: 300),
      );
    } else {
      // Real store for production and license/sandbox testing
      iapService = StoreIAPService(
        config: createProductionIAPConfig(),
      );
    }
    await iapService.initialize();

    // Connect remove_ads purchase to AdsService
    // Check if already purchased on startup
    if (iapService.isRemoveAdsPurchased) {
      analyticsAdsService.disableAds();
    }
    // Listen for future purchases
    iapService.onRemoveAdsPurchased.listen((purchased) {
      if (purchased) {
        analyticsAdsService.disableAds();
      }
    });

    // Define purchaseable resource packs
    // Product IDs must match IAPConfig used by the IAP service
    // When useRealIAPService is true, use production IDs to match StoreIAPService
    final purchasePacks = useRealIAPService
        ? createProductionResourcePacks()
        // ignore: dead_code
        : _createTestResourcePacks();

    // Define bundle packs with their resource contents
    final bundlePacks = useRealIAPService
        ? createProductionBundlePacks()
        // ignore: dead_code
        : _createTestBundlePacks();

    // Create resource config with purchase packs and bundles
    final resourceConfig = ResourceConfig(
      dailyFreeLimits: {
        ResourceType.lives(): 5,
        ResourceType.fiftyFifty(): 3,
        ResourceType.skip(): 2,
      },
      adRewardAmounts: {
        ResourceType.lives(): 1,
        ResourceType.fiftyFifty(): 1,
        ResourceType.skip(): 1,
      },
      purchasePacks: purchasePacks,
      bundlePacks: bundlePacks,
      enableAds: true,
      enablePurchases: true,
    );

    // Create and initialize resource manager with SQLite persistence and ad support
    final resourceManager = ResourceManager(
      config: resourceConfig,
      adProvider: AdMobRewardProvider(analyticsAdsService),
      iapService: iapService,
      repository: SqliteResourceRepository(sl.get<AppDatabase>()),
      analyticsService: screenAnalyticsService,
    );
    await resourceManager.initialize();

    // Initialize rate app service
    final rateAppService = RateAppService(
      config: const RateAppConfig(
        minCompletedQuizzes: 5,
        minDaysSinceInstall: 3,
        minScorePercentage: 70,
        cooldownDays: 30,
        maxLifetimePrompts: 3,
        maxDeclines: 2,
        useLoveDialog: true,
        feedbackEmail: 'support@flagsquiz.app',
      ),
    );
    await rateAppService.initialize();

    // Bundle all services together
    final services = QuizServices(
      settingsService: settingsService,
      storageService: storageService,
      achievementService: achievementService,
      screenAnalyticsService: screenAnalyticsService,
      quizAnalyticsService: quizAnalyticsService,
      resourceManager: resourceManager,
      adsService: analyticsAdsService,
      iapService: iapService,
      rateAppService: rateAppService,
    );

    return FlagsQuizDependencies(
      services: services,
      secrets: secrets,
      achievementsProvider: achievementsProvider,
      dataProvider: dataProvider,
      categories: categories,
      navigatorObserver: navigatorObserver,
    );
  }

  /// Test resource packs matching IAPConfig.test() product IDs.
  ///
  /// Used in debug mode with MockIAPService.
  static List<ResourcePack> _createTestResourcePacks() {
    return const [
      // Lives packs
      ResourcePack(
        id: 'lives_small',
        type: LivesResource(),
        amount: 5,
        productId: 'lives_small',
      ),
      ResourcePack(
        id: 'lives_medium',
        type: LivesResource(),
        amount: 15,
        productId: 'lives_medium',
      ),
      ResourcePack(
        id: 'lives_large',
        type: LivesResource(),
        amount: 50,
        productId: 'lives_large',
      ),
      // 50/50 Hint packs
      ResourcePack(
        id: 'fifty_fifty_small',
        type: FiftyFiftyResource(),
        amount: 5,
        productId: 'fifty_fifty_small',
      ),
      ResourcePack(
        id: 'fifty_fifty_medium',
        type: FiftyFiftyResource(),
        amount: 15,
        productId: 'fifty_fifty_medium',
      ),
      ResourcePack(
        id: 'fifty_fifty_large',
        type: FiftyFiftyResource(),
        amount: 50,
        productId: 'fifty_fifty_large',
      ),
      // Skip packs
      ResourcePack(
        id: 'skips_small',
        type: SkipResource(),
        amount: 5,
        productId: 'skips_small',
      ),
      ResourcePack(
        id: 'skips_medium',
        type: SkipResource(),
        amount: 15,
        productId: 'skips_medium',
      ),
      ResourcePack(
        id: 'skips_large',
        type: SkipResource(),
        amount: 50,
        productId: 'skips_large',
      ),
    ];
  }

  /// Test bundle packs matching IAPConfig.test() product IDs.
  ///
  /// Used in debug mode with MockIAPService.
  static List<BundlePack> _createTestBundlePacks() {
    return [
      BundlePack(
        id: 'bundle_starter',
        productId: 'bundle_starter',
        name: 'Starter Pack',
        description: '5 lives + 5 hints + 5 skips',
        contents: {
          ResourceType.lives(): 5,
          ResourceType.fiftyFifty(): 5,
          ResourceType.skip(): 5,
        },
      ),
      BundlePack(
        id: 'bundle_value',
        productId: 'bundle_value',
        name: 'Value Pack',
        description: '15 lives + 15 hints + 15 skips',
        contents: {
          ResourceType.lives(): 15,
          ResourceType.fiftyFifty(): 15,
          ResourceType.skip(): 15,
        },
      ),
      BundlePack(
        id: 'bundle_pro',
        productId: 'bundle_pro',
        name: 'Pro Pack',
        description: '50 lives + 50 hints + 50 skips',
        contents: {
          ResourceType.lives(): 50,
          ResourceType.fiftyFifty(): 50,
          ResourceType.skip(): 50,
        },
      ),
    ];
  }
}
