# In-App Purchases Setup Guide

This guide covers configuring In-App Purchases (IAP) for the Quiz Apps monorepo, including App Store Connect (iOS), Google Play Console (Android), and integration with the FlagsQuiz app.

---

## Table of Contents

1. [Product Catalog](#product-catalog)
2. [App Store Connect Setup (iOS)](#app-store-connect-setup-ios)
3. [Google Play Console Setup (Android)](#google-play-console-setup-android)
4. [App Configuration](#app-configuration)
5. [Testing](#testing)
6. [Production Checklist](#production-checklist)

---

## Product Catalog

Based on Sprint 9.3, the following products should be configured:

### Consumables (Lives)

| Product ID | Display Name | Price (USD) | Quantity |
|------------|--------------|-------------|----------|
| `com.flagsquiz.lives_small` | 5 Lives | $0.99 | 5 |
| `com.flagsquiz.lives_medium` | 15 Lives | $1.99 | 15 |
| `com.flagsquiz.lives_large` | 50 Lives | $4.99 | 50 |

### Consumables (Hints)

| Product ID | Display Name | Price (USD) | Quantity |
|------------|--------------|-------------|----------|
| `com.flagsquiz.hints_small` | 10 Hints | $0.99 | 10 |
| `com.flagsquiz.hints_medium` | 30 Hints | $1.99 | 30 |
| `com.flagsquiz.hints_large` | 100 Hints | $4.99 | 100 |

### Consumables (Bundles)

| Product ID | Display Name | Price (USD) | Contents |
|------------|--------------|-------------|----------|
| `com.flagsquiz.bundle_starter` | Starter Pack | $1.49 | 5 lives + 10 hints |
| `com.flagsquiz.bundle_value` | Value Pack | $3.49 | 15 lives + 30 hints |
| `com.flagsquiz.bundle_pro` | Pro Pack | $7.99 | 50 lives + 100 hints |

### Non-Consumable

| Product ID | Display Name | Price (USD) |
|------------|--------------|-------------|
| `com.flagsquiz.remove_ads` | Remove Ads | $2.99 |

### Subscriptions (Auto-Renewable)

| Product ID | Display Name | Price (USD) | Duration |
|------------|--------------|-------------|----------|
| `com.flagsquiz.premium_monthly` | Premium Monthly | $1.99/month | 1 month |
| `com.flagsquiz.premium_yearly` | Premium Yearly | $9.99/year | 1 year |

---

## App Store Connect Setup (iOS)

### Prerequisites

1. Apple Developer account ($99/year)
2. App created in App Store Connect
3. Agreements, Tax, and Banking configured

### Step 1: Create In-App Purchases

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app → **Monetization** → **In-App Purchases**
3. Click **+** to create a new product

### Step 2: Configure Consumables

For each consumable product (lives, hints, bundles):

1. **Type:** Consumable
2. **Reference Name:** Internal name (e.g., "5 Lives Pack")
3. **Product ID:** Use the exact ID from the catalog (e.g., `com.flagsquiz.lives_small`)
4. **Pricing:**
   - Select price tier (Tier 1 = $0.99, Tier 2 = $1.99, etc.)
   - Or set custom price
5. **Localization:**
   - Display Name: "5 Lives"
   - Description: "Get 5 extra lives to continue playing"
6. **Review Screenshot:** Add a screenshot showing the purchase UI
7. **Status:** Submit for Review

### Step 3: Configure Non-Consumable (Remove Ads)

1. **Type:** Non-Consumable
2. **Reference Name:** "Remove Ads"
3. **Product ID:** `com.flagsquiz.remove_ads`
4. **Pricing:** Select appropriate tier ($2.99)
5. **Localization:**
   - Display Name: "Remove Ads"
   - Description: "Remove all advertisements permanently"
6. **Review Screenshot:** Required
7. **Status:** Submit for Review

### Step 4: Configure Subscriptions

1. Go to **Monetization** → **Subscriptions**
2. Create a **Subscription Group** (e.g., "Premium")
3. Add subscriptions to the group:

For **Premium Monthly**:
1. **Reference Name:** "Premium Monthly"
2. **Product ID:** `com.flagsquiz.premium_monthly`
3. **Subscription Duration:** 1 Month
4. **Subscription Price:** $1.99
5. **Localization:**
   - Display Name: "Premium Monthly"
   - Description: "Unlimited lives, no ads, exclusive features"
6. **Status:** Submit for Review

For **Premium Yearly**:
1. **Reference Name:** "Premium Yearly"
2. **Product ID:** `com.flagsquiz.premium_yearly`
3. **Subscription Duration:** 1 Year
4. **Subscription Price:** $9.99
5. **Promotional Text:** "Save 58% compared to monthly!"
6. **Localization:** Similar to monthly
7. **Status:** Submit for Review

### Step 5: Create Sandbox Testers

1. Go to **Users and Access** → **Sandbox** → **Testers**
2. Click **+** to add a tester
3. Enter email (use a unique email not linked to any Apple ID)
4. Set password
5. Use this account on test devices

---

## Google Play Console Setup (Android)

### Prerequisites

1. Google Play Developer account ($25 one-time)
2. App created in Google Play Console
3. Merchant account configured

### Step 1: Create In-App Products

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app → **Monetize** → **In-app products**
3. Click **Create product**

### Step 2: Configure Managed Products (Consumables & Non-Consumables)

For each product:

1. **Product ID:** Use exact ID (e.g., `com.flagsquiz.lives_small`)
   - Note: Google doesn't distinguish consumable vs non-consumable at creation
   - Your app code determines if a product is consumed after purchase
2. **Name:** "5 Lives"
3. **Description:** "Get 5 extra lives to continue playing"
4. **Default price:** $0.99
5. **Status:** Active

Repeat for all consumables and the `remove_ads` non-consumable.

### Step 3: Configure Subscriptions

1. Go to **Monetize** → **Subscriptions**
2. Click **Create subscription**

For **Premium Monthly**:
1. **Product ID:** `com.flagsquiz.premium_monthly`
2. **Name:** "Premium Monthly"
3. **Description:** "Unlimited lives, no ads, exclusive features"
4. **Benefits:** List subscription benefits
5. Create a **Base plan**:
   - **Base plan ID:** `monthly-plan`
   - **Renewal type:** Auto-renewing
   - **Billing period:** 1 month
   - **Price:** $1.99

For **Premium Yearly**:
1. **Product ID:** `com.flagsquiz.premium_yearly`
2. **Name:** "Premium Yearly"
3. **Description:** "Save 58%! Unlimited lives, no ads, exclusive features"
4. Create a **Base plan**:
   - **Base plan ID:** `yearly-plan`
   - **Renewal type:** Auto-renewing
   - **Billing period:** 1 year
   - **Price:** $9.99

### Step 4: License Testing

1. Go to **Setup** → **License testing**
2. Add tester email addresses
3. Set **License response:** RESPOND_NORMALLY (for testing real flows)
4. Testers can make purchases without being charged

---

## App Configuration

### Step 1: Create Production IAPConfig

Create a production configuration file:

```dart
// apps/flagsquiz/lib/config/iap_config_production.dart

import 'package:shared_services/shared_services.dart';

/// Production IAP configuration for FlagsQuiz.
///
/// Product IDs must match exactly what's configured in
/// App Store Connect and Google Play Console.
IAPConfig createProductionIAPConfig() {
  return IAPConfig(
    consumableProducts: [
      // Lives
      const IAPProduct.definition(
        id: 'com.flagsquiz.lives_small',
        type: IAPProductType.consumable,
        title: '5 Lives',
        description: 'Get 5 extra lives',
      ),
      const IAPProduct.definition(
        id: 'com.flagsquiz.lives_medium',
        type: IAPProductType.consumable,
        title: '15 Lives',
        description: 'Get 15 extra lives',
      ),
      const IAPProduct.definition(
        id: 'com.flagsquiz.lives_large',
        type: IAPProductType.consumable,
        title: '50 Lives',
        description: 'Get 50 extra lives',
      ),
      // Hints
      const IAPProduct.definition(
        id: 'com.flagsquiz.hints_small',
        type: IAPProductType.consumable,
        title: '10 Hints',
        description: 'Get 10 hints',
      ),
      const IAPProduct.definition(
        id: 'com.flagsquiz.hints_medium',
        type: IAPProductType.consumable,
        title: '30 Hints',
        description: 'Get 30 hints',
      ),
      const IAPProduct.definition(
        id: 'com.flagsquiz.hints_large',
        type: IAPProductType.consumable,
        title: '100 Hints',
        description: 'Get 100 hints',
      ),
      // Bundles
      const IAPProduct.definition(
        id: 'com.flagsquiz.bundle_starter',
        type: IAPProductType.consumable,
        title: 'Starter Pack',
        description: '5 lives + 10 hints',
      ),
      const IAPProduct.definition(
        id: 'com.flagsquiz.bundle_value',
        type: IAPProductType.consumable,
        title: 'Value Pack',
        description: '15 lives + 30 hints',
      ),
      const IAPProduct.definition(
        id: 'com.flagsquiz.bundle_pro',
        type: IAPProductType.consumable,
        title: 'Pro Pack',
        description: '50 lives + 100 hints',
      ),
    ],
    nonConsumableProducts: [
      const IAPProduct.definition(
        id: 'com.flagsquiz.remove_ads',
        type: IAPProductType.nonConsumable,
        title: 'Remove Ads',
        description: 'Remove all advertisements permanently',
      ),
    ],
    subscriptionProducts: [
      const IAPProduct.definition(
        id: 'com.flagsquiz.premium_monthly',
        type: IAPProductType.subscription,
        title: 'Premium Monthly',
        description: 'Unlimited lives, no ads - monthly',
      ),
      const IAPProduct.definition(
        id: 'com.flagsquiz.premium_yearly',
        type: IAPProductType.subscription,
        title: 'Premium Yearly',
        description: 'Unlimited lives, no ads - yearly (save 58%)',
      ),
    ],
  );
}
```

### Step 2: Create Production Resource Packs

```dart
// apps/flagsquiz/lib/config/resource_packs_production.dart

import 'package:shared_services/shared_services.dart';

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
      isBestValue: true,
    ),
    ResourcePack(
      id: 'lives_large',
      type: LivesResource(),
      amount: 50,
      productId: 'com.flagsquiz.lives_large',
    ),
    // Hint packs
    ResourcePack(
      id: 'hints_small',
      type: FiftyFiftyResource(),
      amount: 10,
      productId: 'com.flagsquiz.hints_small',
    ),
    ResourcePack(
      id: 'hints_medium',
      type: FiftyFiftyResource(),
      amount: 30,
      productId: 'com.flagsquiz.hints_medium',
      isBestValue: true,
    ),
    ResourcePack(
      id: 'hints_large',
      type: FiftyFiftyResource(),
      amount: 100,
      productId: 'com.flagsquiz.hints_large',
    ),
    // Bundle packs (grant both lives and hints)
    // Note: Bundles need special handling in ResourceManager
    ResourcePack(
      id: 'bundle_starter',
      type: LivesResource(), // Primary resource
      amount: 5,
      productId: 'com.flagsquiz.bundle_starter',
    ),
    ResourcePack(
      id: 'bundle_value',
      type: LivesResource(),
      amount: 15,
      productId: 'com.flagsquiz.bundle_value',
      isBestValue: true,
    ),
    ResourcePack(
      id: 'bundle_pro',
      type: LivesResource(),
      amount: 50,
      productId: 'com.flagsquiz.bundle_pro',
    ),
  ];
}
```

### Step 3: Update flags_quiz_app_provider.dart

```dart
// In flags_quiz_app_provider.dart

import 'package:flutter/foundation.dart';
import '../config/iap_config_production.dart';
import '../config/resource_packs_production.dart';

// ...

static Future<FlagsQuizDependencies> _initialize() async {
  // ...

  // Initialize IAP service
  final IAPService iapService;

  if (kDebugMode) {
    // Use MockIAPService for development
    iapService = MockIAPService(
      config: IAPConfig.test(),
      simulatedDelay: const Duration(milliseconds: 300),
    );
  } else {
    // Use StoreIAPService for production
    iapService = StoreIAPService(
      config: createProductionIAPConfig(),
    );
  }
  await iapService.initialize();

  // Define resource packs based on environment
  final purchasePacks = kDebugMode
      ? _createTestResourcePacks()  // Use test IDs for MockIAPService
      : createProductionResourcePacks();

  // Create resource config with purchase packs
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
    enableAds: true,
    enablePurchases: true,
  );

  // Create and initialize resource manager
  final resourceManager = ResourceManager(
    config: resourceConfig,
    adProvider: AdMobRewardProvider(analyticsAdsService),
    iapService: iapService,
    repository: SqliteResourceRepository(sl.get<AppDatabase>()),
    analyticsService: screenAnalyticsService,
  );
  await resourceManager.initialize();

  // Connect remove_ads to disable ads
  iapService.onRemoveAdsPurchased.listen((purchased) {
    if (purchased) {
      analyticsAdsService.disableAds();
    }
  });

  // ...
}

/// Test resource packs matching IAPConfig.test() product IDs
static List<ResourcePack> _createTestResourcePacks() {
  return const [
    ResourcePack(
      id: 'lives_small',
      type: LivesResource(),
      amount: 5,
      productId: 'lives_small', // Matches IAPConfig.test()
    ),
    ResourcePack(
      id: 'lives_medium',
      type: LivesResource(),
      amount: 15,
      productId: 'lives_medium',
      isBestValue: true,
    ),
    ResourcePack(
      id: 'lives_large',
      type: LivesResource(),
      amount: 50,
      productId: 'lives_large',
    ),
    ResourcePack(
      id: 'hints_small',
      type: FiftyFiftyResource(),
      amount: 10,
      productId: 'hints_small',
    ),
    ResourcePack(
      id: 'hints_medium',
      type: FiftyFiftyResource(),
      amount: 30,
      productId: 'hints_medium',
      isBestValue: true,
    ),
    ResourcePack(
      id: 'hints_large',
      type: FiftyFiftyResource(),
      amount: 100,
      productId: 'hints_large',
    ),
  ];
}
```

---

## Testing

### Development Testing (MockIAPService)

The app uses `MockIAPService` in debug mode:

```dart
if (kDebugMode) {
  iapService = MockIAPService(
    config: IAPConfig.test(),
    simulatedDelay: const Duration(milliseconds: 300),
  );
}
```

**Features:**
- Simulates successful purchases after 300ms delay
- Returns mock prices ($0.99, $1.99, $4.99)
- No real charges
- Works without store connection

**Test scenarios:**
```dart
// Force a specific result for testing
final mockService = iapService as MockIAPService;

// Test cancelled purchase
mockService.nextPurchaseResult = PurchaseResult.cancelled(
  productId: 'lives_small',
);

// Test failed purchase
mockService.nextPurchaseResult = PurchaseResult.failed(
  productId: 'lives_small',
  errorCode: 'NETWORK_ERROR',
  errorMessage: 'No internet connection',
);

// Test pending purchase
mockService.nextPurchaseResult = PurchaseResult.pending(
  productId: 'lives_small',
  reason: 'Awaiting parental approval',
);
```

### iOS Sandbox Testing

1. **Sign out of App Store** on test device:
   - Settings → [Your Name] → Media & Purchases → Sign Out

2. **Build and run** the app in release/profile mode:
   ```bash
   flutter run --release
   ```

3. **Trigger a purchase** in the app

4. **Sign in with Sandbox account** when prompted
   - Use the account created in App Store Connect

5. **Complete purchase** - No real charges occur

**Sandbox behaviors:**
- Subscriptions renew quickly (monthly = 5 min, yearly = 1 hour)
- Purchases can be made repeatedly
- Use different sandbox accounts for clean testing

### Android Testing

#### Option 1: License Testing (Recommended)

1. Add your email to **License Testing** in Play Console
2. Upload a signed APK/AAB to any track (internal testing is fine)
3. Install the app from Play Store or use:
   ```bash
   flutter run --release
   ```
4. Purchases are free for license testers

#### Option 2: Internal Testing Track

1. Go to **Testing** → **Internal testing**
2. Create a release with signed AAB
3. Add testers by email
4. Testers install from Play Store link
5. Use test card numbers for payment

### Testing Checklist

| Scenario | iOS | Android |
|----------|-----|---------|
| Purchase consumable | [ ] | [ ] |
| Purchase non-consumable | [ ] | [ ] |
| Purchase subscription | [ ] | [ ] |
| Cancel during purchase | [ ] | [ ] |
| Network error during purchase | [ ] | [ ] |
| Restore purchases | [ ] | [ ] |
| Subscription renewal | [ ] | [ ] |
| Subscription cancellation | [ ] | [ ] |
| Remove ads persists after reinstall | [ ] | [ ] |

---

## Production Checklist

### Before Submission

- [ ] All products created in App Store Connect
- [ ] All products created in Google Play Console
- [ ] Product IDs match exactly between stores and app config
- [ ] Products submitted for review (iOS)
- [ ] Products activated (Android)
- [ ] `StoreIAPService` used in release builds
- [ ] Production IAPConfig with correct product IDs
- [ ] Production ResourcePacks with correct product IDs
- [ ] remove_ads connected to AdsService.disableAds()
- [ ] Analytics tracking verified
- [ ] Restore purchases tested
- [ ] Error handling tested

### App Store Review Notes

Include in your app's review notes:
```
In-App Purchase Testing:

Demo Account: (if applicable)
Username: test@example.com
Password: Test123!

To test purchases:
1. Go to Settings → Buy Lives/Hints
2. Tap any pack to purchase
3. Use sandbox account to complete

To test Remove Ads:
1. Go to Settings → Remove Ads
2. Complete purchase
3. Ads should no longer appear
```

### Post-Launch Monitoring

- Monitor purchase analytics in App Store Connect / Play Console
- Check for failed purchases in crash reporting
- Verify subscription renewal rates
- Monitor refund requests

---

## Troubleshooting

### "Product not found" error

**Causes:**
1. Product ID mismatch between app and store
2. Product not approved/activated in store
3. App bundle ID doesn't match store configuration

**Solutions:**
1. Verify product IDs are identical (case-sensitive)
2. Check product status in store console
3. Ensure app is signed with correct certificate

### "Cannot connect to App Store" (iOS)

**Causes:**
1. Sandbox account not configured
2. Network issues
3. App not signed correctly

**Solutions:**
1. Sign out and sign in with sandbox account
2. Check internet connection
3. Clean build and reinstall

### Purchases not being delivered

**Causes:**
1. Purchase not being completed (finished)
2. App not handling purchase stream correctly

**Solutions:**
1. Ensure `completePurchase()` is called
2. Check `StoreIAPService` purchase stream handling
3. Verify analytics for purchase events

---

## References

- [Apple In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [Google Play Billing Guide](https://developer.android.com/google/play/billing)
- [in_app_purchase Flutter Package](https://pub.dev/packages/in_app_purchase)
- [Sprint 9.3 Implementation](./PHASE_IMPLEMENTATION.md#sprint-93-in-app-purchases-service-)
