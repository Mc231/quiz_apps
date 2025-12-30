import 'package:shared_services/shared_services.dart';

/// Production IAP configuration for FlagsQuiz.
///
/// Product IDs must match exactly what's configured in
/// App Store Connect and Google Play Console.
///
/// See docs/IAP_SETUP_GUIDE.md for store setup instructions.
IAPConfig createProductionIAPConfig() {
  return const IAPConfig(
    consumableProducts: [
      // Lives
      IAPProduct.definition(
        id: 'com.flagsquiz.lives_small',
        type: IAPProductType.consumable,
        title: '5 Lives',
        description: 'Get 5 extra lives',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.lives_medium',
        type: IAPProductType.consumable,
        title: '15 Lives',
        description: 'Get 15 extra lives',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.lives_large',
        type: IAPProductType.consumable,
        title: '50 Lives',
        description: 'Get 50 extra lives',
      ),
      // 50/50 Hints
      IAPProduct.definition(
        id: 'com.flagsquiz.fifty_fifty_small',
        type: IAPProductType.consumable,
        title: '5 50/50 Hints',
        description: 'Get 5 fifty-fifty hints',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.fifty_fifty_medium',
        type: IAPProductType.consumable,
        title: '15 50/50 Hints',
        description: 'Get 15 fifty-fifty hints',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.fifty_fifty_large',
        type: IAPProductType.consumable,
        title: '50 50/50 Hints',
        description: 'Get 50 fifty-fifty hints',
      ),
      // Skips
      IAPProduct.definition(
        id: 'com.flagsquiz.skips_small',
        type: IAPProductType.consumable,
        title: '5 Skips',
        description: 'Get 5 skips',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.skips_medium',
        type: IAPProductType.consumable,
        title: '15 Skips',
        description: 'Get 15 skips',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.skips_large',
        type: IAPProductType.consumable,
        title: '50 Skips',
        description: 'Get 50 skips',
      ),
      // Bundles (consumable because they grant resources)
      IAPProduct.definition(
        id: 'com.flagsquiz.bundle_starter',
        type: IAPProductType.consumable,
        title: 'Starter Pack',
        description: '5 lives + 5 fifty-fifty + 5 skips',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.bundle_value',
        type: IAPProductType.consumable,
        title: 'Value Pack',
        description: '15 lives + 15 fifty-fifty + 15 skips',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.bundle_pro',
        type: IAPProductType.consumable,
        title: 'Pro Pack',
        description: '50 lives + 50 fifty-fifty + 50 skips',
      ),
    ],
    nonConsumableProducts: [
      IAPProduct.definition(
        id: 'com.flagsquiz.remove_ads',
        type: IAPProductType.nonConsumable,
        title: 'Remove Ads',
        description: 'Remove all advertisements permanently',
      ),
    ],
    subscriptionProducts: [
      IAPProduct.definition(
        id: 'com.flagsquiz.premium_monthly',
        type: IAPProductType.subscription,
        title: 'Premium Monthly',
        description: 'Unlimited lives, no ads - monthly',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.premium_yearly',
        type: IAPProductType.subscription,
        title: 'Premium Yearly',
        description: 'Unlimited lives, no ads - yearly (save 58%)',
      ),
    ],
  );
}

/// Production resource packs for FlagsQuiz.
///
/// Product IDs must match the IAPConfig and store configurations.
List<ResourcePack> createProductionResourcePacks() {
  return const [
    // Lives packs
    ResourcePack(
      id: 'lives_small',
      type: LivesResource(),
      amount: 5,
      productId: 'com.flagsquiz.lives_small',
    ),
    ResourcePack(
      id: 'lives_medium',
      type: LivesResource(),
      amount: 15,
      productId: 'com.flagsquiz.lives_medium',
    ),
    ResourcePack(
      id: 'lives_large',
      type: LivesResource(),
      amount: 50,
      productId: 'com.flagsquiz.lives_large',
    ),
    // 50/50 Hint packs
    ResourcePack(
      id: 'fifty_fifty_small',
      type: FiftyFiftyResource(),
      amount: 5,
      productId: 'com.flagsquiz.fifty_fifty_small',
    ),
    ResourcePack(
      id: 'fifty_fifty_medium',
      type: FiftyFiftyResource(),
      amount: 15,
      productId: 'com.flagsquiz.fifty_fifty_medium',
    ),
    ResourcePack(
      id: 'fifty_fifty_large',
      type: FiftyFiftyResource(),
      amount: 50,
      productId: 'com.flagsquiz.fifty_fifty_large',
    ),
    // Skip packs
    ResourcePack(
      id: 'skips_small',
      type: SkipResource(),
      amount: 5,
      productId: 'com.flagsquiz.skips_small',
    ),
    ResourcePack(
      id: 'skips_medium',
      type: SkipResource(),
      amount: 15,
      productId: 'com.flagsquiz.skips_medium',
    ),
    ResourcePack(
      id: 'skips_large',
      type: SkipResource(),
      amount: 50,
      productId: 'com.flagsquiz.skips_large',
    ),
  ];
}

/// Production bundle packs for FlagsQuiz.
///
/// Product IDs must match the IAPConfig and store configurations.
List<BundlePack> createProductionBundlePacks() {
  return [
    BundlePack(
      id: 'bundle_starter',
      productId: 'com.flagsquiz.bundle_starter',
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
      productId: 'com.flagsquiz.bundle_value',
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
      productId: 'com.flagsquiz.bundle_pro',
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
