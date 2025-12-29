# AdMob Environment Configuration

This guide explains how to configure AdMob IDs for the Flags Quiz app.

## Overview

- **Development**: Uses Google's test IDs by default - just run `flutter run`
- **Production**: Provide your AdMob IDs via `--dart-define-from-file`

## Quick Start

### Development (Default)

No configuration needed. Test ads work out of the box:

```bash
flutter run
```

### Production Build

1. Create your env.json:
```bash
cd apps/flagsquiz
./scripts/setup_env.sh
```

2. Edit `config/env.json` with your production IDs:
```json
{
  "ADMOB_APP_ID_ANDROID": "ca-app-pub-YOUR_ID~XXXXXXXXXX",
  "ADMOB_APP_ID_IOS": "ca-app-pub-YOUR_ID~XXXXXXXXXX",
  "ADMOB_BANNER_ID": "ca-app-pub-YOUR_ID/XXXXXXXXXX",
  "ADMOB_INTERSTITIAL_ID": "ca-app-pub-YOUR_ID/XXXXXXXXXX",
  "ADMOB_REWARDED_ID": "ca-app-pub-YOUR_ID/XXXXXXXXXX"
}
```

3. For iOS, update `ios/Flutter/AdMob.xcconfig`:
```
ADMOB_APP_ID_IOS=ca-app-pub-YOUR_ID~XXXXXXXXXX
```

4. Build with production IDs:
```bash
flutter run --dart-define-from-file=config/env.json
flutter build apk --dart-define-from-file=config/env.json
flutter build ios --dart-define-from-file=config/env.json
```

## File Structure

```
apps/flagsquiz/
├── config/
│   ├── env.json              # Your production IDs (gitignored)
│   └── env.template.json     # Template with placeholders
├── scripts/
│   └── setup_env.sh          # Creates env.json from template
├── android/
│   └── app/
│       ├── build.gradle      # Parses dart-defines, defaults to test ID
│       └── src/main/
│           └── AndroidManifest.xml  # Uses ${admobAppId}
└── ios/
    ├── Flutter/
    │   ├── AdMob.xcconfig    # iOS App ID (committed with test ID)
    │   ├── Debug.xcconfig    # Includes AdMob.xcconfig
    │   └── Release.xcconfig  # Includes AdMob.xcconfig
    └── Runner/
        └── Info.plist        # Uses $(ADMOB_APP_ID_IOS)
```

## How It Works

### Android

1. **build.gradle** parses `dart-defines` and defaults to test ID:
   ```groovy
   def admobAppId = dartDefines['ADMOB_APP_ID_ANDROID'] ?: 'ca-app-pub-3940256099942544~3347511713'
   ```

2. The App ID is passed to AndroidManifest via `manifestPlaceholders`

3. **AndroidManifest.xml** uses the `${admobAppId}` placeholder

### iOS

1. **AdMob.xcconfig** contains the App ID (defaults to test ID)

2. For production, update this file or override in CI/CD

3. **Info.plist** references `$(ADMOB_APP_ID_IOS)`

### Dart Code

Access IDs via `String.fromEnvironment` with test ID defaults:

```dart
const bannerId = String.fromEnvironment(
  'ADMOB_BANNER_ID',
  defaultValue: 'ca-app-pub-3940256099942544/6300978111',
);
```

Or use the convenience factory:

```dart
final config = AdsConfig.test(); // Uses all test IDs
```

## Google Test IDs (Defaults)

| Type | Android | iOS |
|------|---------|-----|
| App ID | ca-app-pub-3940256099942544~3347511713 | ca-app-pub-3940256099942544~1458002511 |
| Banner | ca-app-pub-3940256099942544/6300978111 | ca-app-pub-3940256099942544/2934735716 |
| Interstitial | ca-app-pub-3940256099942544/1033173712 | ca-app-pub-3940256099942544/4411468910 |
| Rewarded | ca-app-pub-3940256099942544/5224354917 | ca-app-pub-3940256099942544/1712485313 |

## CI/CD Integration

For CI/CD pipelines, create configuration from secrets:

```yaml
# GitHub Actions example
- name: Setup AdMob configuration
  run: |
    # Create env.json
    cat > apps/flagsquiz/config/env.json << EOF
    {
      "ADMOB_APP_ID_ANDROID": "${{ secrets.ADMOB_APP_ID_ANDROID }}",
      "ADMOB_APP_ID_IOS": "${{ secrets.ADMOB_APP_ID_IOS }}",
      "ADMOB_BANNER_ID": "${{ secrets.ADMOB_BANNER_ID }}",
      "ADMOB_INTERSTITIAL_ID": "${{ secrets.ADMOB_INTERSTITIAL_ID }}",
      "ADMOB_REWARDED_ID": "${{ secrets.ADMOB_REWARDED_ID }}"
    }
    EOF

    # Update iOS AdMob.xcconfig for production
    echo "ADMOB_APP_ID_IOS=${{ secrets.ADMOB_APP_ID_IOS }}" > apps/flagsquiz/ios/Flutter/AdMob.xcconfig

- name: Build
  run: flutter build apk --dart-define-from-file=apps/flagsquiz/config/env.json
```

## Security Notes

- **env.json is gitignored** - Production IDs never committed
- **Test IDs are safe to commit** - They only show test ads
- **AdMob.xcconfig committed with test ID** - Override in CI/CD for production

## Troubleshooting

### Ads Not Loading

1. Check that Ad Unit IDs match your AdMob console
2. Ensure your app is registered in AdMob
3. Wait for AdMob to approve your app (can take hours/days for new apps)

### Test Ads Working, Production Ads Not

1. Verify production IDs in env.json
2. Check AdMob console for policy violations
3. Ensure payment info is set up in AdMob

## SKAdNetwork Configuration

The Info.plist includes required SKAdNetworkItems for iOS ad attribution. These are pre-configured and don't need modification.
