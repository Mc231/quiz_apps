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
      // Lives - Continue playing after wrong answers
      IAPProduct.definition(
        id: 'com.flagsquiz.lives_small',
        type: IAPProductType.consumable,
        title: '5 Lives',
        description: 'Continue playing after 5 wrong answers. Each life lets you recover from one mistake.',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.lives_medium',
        type: IAPProductType.consumable,
        title: '15 Lives',
        description: 'Continue playing after 15 wrong answers. Each life lets you recover from one mistake.',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.lives_large',
        type: IAPProductType.consumable,
        title: '50 Lives',
        description: 'Continue playing after 50 wrong answers. Each life lets you recover from one mistake.',
      ),
      // 50/50 Hints - Remove wrong answers to make questions easier
      IAPProduct.definition(
        id: 'com.flagsquiz.fifty_fifty_small',
        type: IAPProductType.consumable,
        title: '5 50/50 Hints',
        description: 'Remove 2 wrong answers from 5 questions. Makes difficult questions easier by showing only 2 choices.',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.fifty_fifty_medium',
        type: IAPProductType.consumable,
        title: '15 50/50 Hints',
        description: 'Remove 2 wrong answers from 15 questions. Makes difficult questions easier by showing only 2 choices.',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.fifty_fifty_large',
        type: IAPProductType.consumable,
        title: '50 50/50 Hints',
        description: 'Remove 2 wrong answers from 50 questions. Makes difficult questions easier by showing only 2 choices.',
      ),
      // Skips - Skip difficult questions without penalty
      IAPProduct.definition(
        id: 'com.flagsquiz.skips_small',
        type: IAPProductType.consumable,
        title: '5 Skips',
        description: 'Skip 5 difficult questions without penalty. Move to the next question instantly.',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.skips_medium',
        type: IAPProductType.consumable,
        title: '15 Skips',
        description: 'Skip 15 difficult questions without penalty. Move to the next question instantly.',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.skips_large',
        type: IAPProductType.consumable,
        title: '50 Skips',
        description: 'Skip 50 difficult questions without penalty. Move to the next question instantly.',
      ),
      // Bundles - Best value packs with all resources
      IAPProduct.definition(
        id: 'com.flagsquiz.bundle_starter',
        type: IAPProductType.consumable,
        title: 'Starter Pack',
        description: '5 Lives (recover from mistakes) + 5 Hints (narrow answers to 2 choices) + 5 Skips (pass hard questions). Try all helpers!',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.bundle_value',
        type: IAPProductType.consumable,
        title: 'Value Pack',
        description: '15 Lives (recover from mistakes) + 15 Hints (narrow answers to 2 choices) + 15 Skips (pass hard questions). Great value!',
      ),
      IAPProduct.definition(
        id: 'com.flagsquiz.bundle_pro',
        type: IAPProductType.consumable,
        title: 'Pro Pack',
        description: '50 Lives (recover from mistakes) + 50 Hints (narrow answers to 2 choices) + 50 Skips (pass hard questions). Best value!',
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
      contents: {
        ResourceType.lives(): 50,
        ResourceType.fiftyFifty(): 50,
        ResourceType.skip(): 50,
      },
    ),
  ];
}
