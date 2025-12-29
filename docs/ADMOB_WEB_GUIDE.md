# AdMob Web Platform Guide

## Overview

**Important:** Google AdMob does not natively support web platforms. The `google_mobile_ads` Flutter plugin only works on iOS and Android. For web monetization, you have two options:

1. **Google AdSense** - For general web ads
2. **Google Ad Manager** - For advanced ad serving

This guide explains how to set up ads on web using AdSense, and how to integrate with the existing `AdsService` architecture.

---

## Option 1: Google AdSense (Recommended for Web)

### Step 1: Create an AdSense Account

1. Go to [Google AdSense](https://www.google.com/adsense/)
2. Sign up with your Google account
3. Add your website/app domain
4. Wait for account approval (can take 1-2 weeks)

### Step 2: Add AdSense Script to Web

Add this script to your `web/index.html` before `</head>`:

```html
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXX"
     crossorigin="anonymous"></script>
```

Replace `ca-pub-XXXXXXXXXX` with your AdSense publisher ID.

### Step 3: Create Ad Units

1. In AdSense dashboard, go to **Ads** > **By ad unit**
2. Create ad units:
   - **Display ads** - For banner-like placements
   - **In-feed ads** - For list views
   - **In-article ads** - For content pages
   - **Matched content** - For related content sections

### Step 4: Create Web-Specific AdsService

Create a web implementation of `AdsService`:

```dart
// lib/src/ads/web_ads_service.dart
import 'dart:async';
import 'dart:html' as html;
import 'ads_service.dart';

class WebAdsService implements AdsService {
  WebAdsService({required this.publisherId});

  final String publisherId;
  bool _isInitialized = false;
  bool _isEnabled = true;

  final _adEventController = StreamController<AdEvent>.broadcast();
  final _adAvailabilityController = StreamController<bool>.broadcast();

  @override
  Future<bool> initialize() async {
    // AdSense script is loaded via index.html
    _isInitialized = true;
    return true;
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isEnabled => _isEnabled;

  // Banner ads on web are handled via HTML/JS
  @override
  bool get isBannerAdLoaded => false;

  @override
  Future<bool> loadBannerAd() async => false;

  @override
  void disposeBannerAd() {}

  @override
  Object? getBannerAdWidget() => null;

  // Interstitial ads not available on AdSense
  @override
  bool get isInterstitialAdLoaded => false;

  @override
  Future<bool> loadInterstitialAd() async => false;

  @override
  Future<AdResult> showInterstitialAd(AdPlacement placement) async {
    return AdResult.notAvailable();
  }

  // Rewarded ads not available on AdSense
  @override
  bool get isRewardedAdLoaded => false;

  @override
  Future<bool> loadRewardedAd() async => false;

  @override
  Future<AdResult> showRewardedAdWithPlacement(AdPlacement placement) async {
    return AdResult.notAvailable();
  }

  @override
  bool get isAdAvailable => false;

  @override
  Future<bool> showRewardedAd() async => false;

  @override
  Stream<bool> get onAdAvailabilityChanged => _adAvailabilityController.stream;

  @override
  Stream<AdEvent> get onAdEvent => _adEventController.stream;

  @override
  void disableAds() => _isEnabled = false;

  @override
  void enableAds() => _isEnabled = true;

  @override
  AdsConfig get config => AdsConfig.test();

  @override
  void dispose() {
    _adEventController.close();
    _adAvailabilityController.close();
  }
}
```

### Step 5: Display Banner Ads on Web

For web, use HTML/JS integration via `HtmlElementView`:

```dart
// lib/src/widgets/web_banner_ad_widget.dart
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebBannerAdWidget extends StatefulWidget {
  const WebBannerAdWidget({
    super.key,
    required this.adSlot,
    this.adFormat = 'auto',
    this.width = 728,
    this.height = 90,
  });

  final String adSlot;
  final String adFormat;
  final int width;
  final int height;

  @override
  State<WebBannerAdWidget> createState() => _WebBannerAdWidgetState();
}

class _WebBannerAdWidgetState extends State<WebBannerAdWidget> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'adsense-${widget.adSlot}-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  void _registerView() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final container = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%';

        final ins = html.Element.tag('ins')
          ..className = 'adsbygoogle'
          ..style.display = 'block'
          ..setAttribute('data-ad-client', 'ca-pub-XXXXXXXXXX')  // Your publisher ID
          ..setAttribute('data-ad-slot', widget.adSlot)
          ..setAttribute('data-ad-format', widget.adFormat)
          ..setAttribute('data-full-width-responsive', 'true');

        container.children.add(ins);

        // Push the ad
        final script = html.ScriptElement()
          ..text = '(adsbygoogle = window.adsbygoogle || []).push({});';
        container.children.add(script);

        return container;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width.toDouble(),
      height: widget.height.toDouble(),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
```

---

## Option 2: Google Ad Manager (Advanced)

For more control over ad serving, use Google Ad Manager:

### Step 1: Create Ad Manager Account

1. Go to [Google Ad Manager](https://admanager.google.com/)
2. Create a new account
3. Set up your inventory (ad units)

### Step 2: Implement with Google Publisher Tag (GPT)

Add to `web/index.html`:

```html
<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
<script>
  window.googletag = window.googletag || {cmd: []};
  googletag.cmd.push(function() {
    googletag.defineSlot('/YOUR_NETWORK_CODE/ad_unit_name', [300, 250], 'div-gpt-ad-banner')
      .addService(googletag.pubads());
    googletag.pubads().enableSingleRequest();
    googletag.enableServices();
  });
</script>
```

---

## Platform-Specific Service Selection

In your app, select the appropriate service based on platform:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_services/shared_services.dart';

AdsService createAdsService() {
  if (kIsWeb) {
    // Web: Use NoAdsService or WebAdsService
    return NoAdsService();
  }

  // Mobile: Use AdMob
  return AdMobService(
    config: AdsConfig(
      bannerAdUnitId: 'ca-app-pub-xxx/banner',
      interstitialAdUnitId: 'ca-app-pub-xxx/interstitial',
      rewardedAdUnitId: 'ca-app-pub-xxx/rewarded',
    ),
  );
}
```

---

## Web Monetization Alternatives

Since rewarded ads are not available on web via AdSense, consider these alternatives:

### 1. Subscription Model
- Offer premium features via Stripe or other payment providers
- Use `in_app_purchase` for mobile, Stripe for web

### 2. Donation/Tip System
- Add a "Support the Developer" button
- Integrate with PayPal, Buy Me a Coffee, etc.

### 3. Remove Ads via Purchase
- On web: Use Stripe for one-time purchase
- Store purchase status in user account

### 4. Hybrid Approach
```dart
// Check platform and show appropriate monetization
if (kIsWeb) {
  // Show "Support us" button instead of rewarded ad
  showSupportDialog();
} else {
  // Show rewarded ad
  final result = await adsService.showRewardedAdWithPlacement(
    AdPlacement.rewardedLives,
  );
}
```

---

## Testing AdSense

### Development Mode
AdSense requires a live site for testing. For development:

1. **Use Test Mode**: Add `data-adtest="on"` to your ad tags
2. **Test Site**: Deploy to a staging URL approved in AdSense
3. **Preview Tool**: Use AdSense's ad preview feature

```html
<ins class="adsbygoogle"
     data-adtest="on"  <!-- Test mode -->
     data-ad-client="ca-pub-XXXXXXXXXX"
     data-ad-slot="1234567890">
</ins>
```

### Common Issues

1. **Ads not showing**: Check if site is approved in AdSense
2. **Policy violations**: Ensure content complies with AdSense policies
3. **Ad blockers**: Test in incognito mode without ad blockers

---

## Summary

| Feature | Mobile (AdMob) | Web (AdSense) |
|---------|----------------|---------------|
| Banner Ads | ✅ Native SDK | ✅ HTML/JS |
| Interstitial Ads | ✅ Native SDK | ❌ Not available |
| Rewarded Ads | ✅ Native SDK | ❌ Not available |
| Revenue Share | 68% | 68% |
| Setup Complexity | Low | Medium |

For quiz apps on web, consider a hybrid approach:
- Show banner ads (AdSense) for basic monetization
- Offer premium/ad-free via payment instead of rewarded ads
- Focus mobile users on rewarded ads for free content

---

## Resources

- [AdSense Help Center](https://support.google.com/adsense/)
- [Google Ad Manager Documentation](https://support.google.com/admanager/)
- [Flutter Web Platform Views](https://docs.flutter.dev/development/platform-integration/web/web-plugins)
- [AdSense Program Policies](https://support.google.com/adsense/answer/48182)
