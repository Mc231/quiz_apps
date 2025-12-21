# GitHub Actions Workflows

This directory contains reusable workflows for deploying quiz apps from the monorepo.

## Architecture

### Reusable Workflows (Templates)

These workflows are designed to be reused by multiple apps:

- **`reusable-test.yml`** - Run tests for any app
- **`reusable-deploy-android.yml`** - Deploy any app to Google Play Store
- **`reusable-deploy-ios.yml`** - Deploy any app to Apple App Store
- **`reusable-deploy-web.yml`** - Deploy any app to Firebase Hosting
- **`reusable-deploy-macos.yml`** - Deploy any app to Mac App Store

### App-Specific Workflows

These workflows call the reusable workflows for specific apps:

**Flagsquiz:**
- `flagsquiz-test.yml` - Run tests
- `flagsquiz-deploy-android.yml` - Deploy to Play Store
- `flagsquiz-deploy-ios.yml` - Deploy to App Store
- `flagsquiz-deploy-web.yml` - Deploy to Firebase
- `flagsquiz-deploy-macos.yml` - Deploy to Mac App Store

## Adding a New App

When you create a new quiz app (e.g., "capital_quiz"), create these workflows:

### 1. Create Test Workflow

**File:** `.github/workflows/capital-quiz-test.yml`

```yaml
name: Capital Quiz - Tests

on:
  workflow_dispatch:
  push:
    branches: [main, develop]
    paths:
      - 'apps/capital_quiz/**'
      - 'packages/**'
  pull_request:
    branches: [main, develop]
    paths:
      - 'apps/capital_quiz/**'
      - 'packages/**'

jobs:
  test:
    uses: ./.github/workflows/reusable-test.yml
    with:
      app_name: 'capital_quiz'
      app_path: 'apps/capital_quiz'
```

### 2. Create Android Deploy Workflow

**File:** `.github/workflows/capital-quiz-deploy-android.yml`

```yaml
name: Capital Quiz - Deploy Android

on:
  workflow_dispatch:
    inputs:
      track:
        description: 'Play Store track'
        required: true
        type: choice
        options:
          - internal
          - alpha
          - beta
          - production
        default: 'internal'

jobs:
  deploy:
    uses: ./.github/workflows/reusable-deploy-android.yml
    with:
      app_name: 'capital_quiz'
      app_path: 'apps/capital_quiz'
      track: ${{ inputs.track || 'internal' }}
    secrets:
      ANDROID_PACKAGE_NAME: ${{ secrets.CAPITAL_QUIZ_ANDROID_PACKAGE_NAME }}
      GOOGLE_PLAY_KEY: ${{ secrets.CAPITAL_QUIZ_GOOGLE_PLAY_KEY }}
      ANDROID_BASE_64_KEY_STORE: ${{ secrets.CAPITAL_QUIZ_ANDROID_BASE_64_KEY_STORE }}
      ANDROID_KEYSTORE_PASSWORD: ${{ secrets.CAPITAL_QUIZ_ANDROID_KEYSTORE_PASSWORD }}
      ANDROID_KEY_ALIAS: ${{ secrets.CAPITAL_QUIZ_ANDROID_KEY_ALIAS }}
      ANDROID_KEY_PASSWORD: ${{ secrets.CAPITAL_QUIZ_ANDROID_KEY_PASSWORD }}
```

### 3. Create iOS Deploy Workflow

**File:** `.github/workflows/capital-quiz-deploy-ios.yml`

```yaml
name: Capital Quiz - Deploy iOS

on:
  workflow_dispatch:
    inputs:
      lane:
        description: 'Fastlane lane'
        required: true
        type: choice
        options:
          - beta
          - release
        default: 'beta'

jobs:
  deploy:
    uses: ./.github/workflows/reusable-deploy-ios.yml
    with:
      app_name: 'capital_quiz'
      app_path: 'apps/capital_quiz'
      lane: ${{ inputs.lane || 'beta' }}
    secrets:
      FASTLANE_APPLE_ID: ${{ secrets.CAPITAL_QUIZ_FASTLANE_APPLE_ID }}
      FASTLANE_USER: ${{ secrets.CAPITAL_QUIZ_FASTLANE_USER }}
      IOS_PACKAGE_NAME: ${{ secrets.CAPITAL_QUIZ_IOS_PACKAGE_NAME }}
      IOS_TEAM_ID: ${{ secrets.CAPITAL_QUIZ_IOS_TEAM_ID }}
      FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.CAPITAL_QUIZ_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD }}
```

### 4. Create Web Deploy Workflow

**File:** `.github/workflows/capital-quiz-deploy-web.yml`

```yaml
name: Capital Quiz - Deploy Web

on:
  workflow_dispatch:

jobs:
  deploy:
    uses: ./.github/workflows/reusable-deploy-web.yml
    with:
      app_name: 'capital_quiz'
      app_path: 'apps/capital_quiz'
      hosting_target: 'capital-quiz'  # Firebase hosting target
    secrets:
      FIREBASE_TOKEN: ${{ secrets.CAPITAL_QUIZ_FIREBASE_TOKEN }}
```

### 5. Create macOS Deploy Workflow

**File:** `.github/workflows/capital-quiz-deploy-macos.yml`

```yaml
name: Capital Quiz - Deploy macOS

on:
  workflow_dispatch:

jobs:
  deploy:
    uses: ./.github/workflows/reusable-deploy-macos.yml
    with:
      app_name: 'capital_quiz'
      app_path: 'apps/capital_quiz'
      scheme: 'Runner'
    secrets:
      FASTLANE_APPLE_ID: ${{ secrets.CAPITAL_QUIZ_FASTLANE_APPLE_ID }}
      FASTLANE_USER: ${{ secrets.CAPITAL_QUIZ_FASTLANE_USER }}
      MACOS_PACKAGE_NAME: ${{ secrets.CAPITAL_QUIZ_MACOS_PACKAGE_NAME }}
      MACOS_TEAM_ID: ${{ secrets.CAPITAL_QUIZ_MACOS_TEAM_ID }}
      FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.CAPITAL_QUIZ_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD }}
```

## Required Secrets

For each app, you need to configure these secrets in GitHub:

### Android Secrets

- `{APP_NAME}_ANDROID_PACKAGE_NAME` - Package name (e.g., com.example.capitalquiz)
- `{APP_NAME}_GOOGLE_PLAY_KEY` - Google Play service account JSON
- `{APP_NAME}_ANDROID_BASE_64_KEY_STORE` - Base64 encoded keystore
- `{APP_NAME}_ANDROID_KEYSTORE_PASSWORD` - Keystore password
- `{APP_NAME}_ANDROID_KEY_ALIAS` - Key alias
- `{APP_NAME}_ANDROID_KEY_PASSWORD` - Key password

### iOS/macOS Secrets

- `{APP_NAME}_FASTLANE_APPLE_ID` - Apple ID email
- `{APP_NAME}_FASTLANE_USER` - Fastlane user (usually same as Apple ID)
- `{APP_NAME}_IOS_PACKAGE_NAME` - iOS bundle ID
- `{APP_NAME}_MACOS_PACKAGE_NAME` - macOS bundle ID
- `{APP_NAME}_IOS_TEAM_ID` - Apple Team ID
- `{APP_NAME}_MACOS_TEAM_ID` - Apple Team ID (usually same)
- `{APP_NAME}_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` - App-specific password

### Web Secrets

- `{APP_NAME}_FIREBASE_TOKEN` - Firebase CI token

**Example for Capital Quiz:**
- `CAPITAL_QUIZ_ANDROID_PACKAGE_NAME`
- `CAPITAL_QUIZ_GOOGLE_PLAY_KEY`
- etc.

## Running Workflows

### From GitHub UI

1. Go to **Actions** tab in GitHub
2. Select the workflow you want to run (e.g., "Flagsquiz - Deploy Android")
3. Click **Run workflow**
4. Select options (e.g., which track for Android)
5. Click **Run workflow** button

### From Command Line (GitHub CLI)

```bash
# Run tests
gh workflow run flagsquiz-test.yml

# Deploy Android to internal track
gh workflow run flagsquiz-deploy-android.yml -f track=internal

# Deploy Android to production
gh workflow run flagsquiz-deploy-android.yml -f track=production

# Deploy iOS beta
gh workflow run flagsquiz-deploy-ios.yml -f lane=beta

# Deploy iOS release
gh workflow run flagsquiz-deploy-ios.yml -f lane=release

# Deploy Web
gh workflow run flagsquiz-deploy-web.yml

# Deploy macOS
gh workflow run flagsquiz-deploy-macos.yml
```

## Workflow Features

### Automatic Tests

All deploy workflows automatically run tests before deploying. If tests fail, deployment is aborted.

### Coverage Reports

Test workflows generate coverage reports and upload them as artifacts. You can download them from the Actions tab.

### Monorepo Support

All workflows:
- Bootstrap the monorepo using `melos bootstrap`
- Work from the correct app directory
- Share the same package dependencies

### Path Filtering

Test workflows only run when relevant files change:
- The specific app's directory
- Shared packages directory

This saves CI/CD time and resources.

## Workflow Structure

```
.github/workflows/
├── README.md                           # This file
│
├── Reusable Workflows (Templates)
│   ├── reusable-test.yml              # Test any app
│   ├── reusable-deploy-android.yml    # Deploy any app to Android
│   ├── reusable-deploy-ios.yml        # Deploy any app to iOS
│   ├── reusable-deploy-web.yml        # Deploy any app to Web
│   └── reusable-deploy-macos.yml      # Deploy any app to macOS
│
├── Flagsquiz Workflows
│   ├── flagsquiz-test.yml
│   ├── flagsquiz-deploy-android.yml
│   ├── flagsquiz-deploy-ios.yml
│   ├── flagsquiz-deploy-web.yml
│   └── flagsquiz-deploy-macos.yml
│
└── Future App Workflows
    ├── capital-quiz-test.yml
    ├── capital-quiz-deploy-android.yml
    └── ... (copy pattern from flagsquiz)
```

## Best Practices

1. **Name Secrets Consistently**: Use `{APP_NAME}_{SECRET_NAME}` pattern
2. **Test Before Deploy**: All deploy workflows run tests first
3. **Use Workflow Dispatch**: Enable manual triggering for all workflows
4. **Version Control**: Track which version was deployed in release notes
5. **Separate Secrets**: Each app has its own set of secrets for security

## Troubleshooting

### Workflow Not Found

If you get "workflow not found" error, ensure:
- Workflow file is in `.github/workflows/`
- File has `.yml` or `.yaml` extension
- File is committed to the repository
- You're on the correct branch

### Secrets Not Working

If secrets aren't being passed correctly:
- Check secret names match exactly (case-sensitive)
- Verify secrets are set in repository settings
- Ensure you're using `secrets.SECRET_NAME` syntax

### Melos Bootstrap Fails

If melos bootstrap fails:
- Ensure `melos.yaml` is in the root
- Ensure `pubspec.yaml` has melos as dev dependency
- Check that all path dependencies are correct

## Future Enhancements

Potential improvements to consider:

- [ ] Add automatic version bumping
- [ ] Add automatic changelog generation
- [ ] Add Slack/Discord notifications on deploy
- [ ] Add rollback workflows
- [ ] Add staging environment workflows
- [ ] Add performance testing workflows
- [ ] Add screenshot testing workflows

## Support

For issues with workflows:
1. Check workflow run logs in Actions tab
2. Verify all secrets are configured
3. Ensure Fastlane is configured correctly in the app
4. Check that self-hosted runner is online and healthy
