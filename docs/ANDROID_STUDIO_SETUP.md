# Android Studio Setup for Monorepo

## Quick Fix for Autocomplete

If you're experiencing no autocomplete in packages, follow these steps:

### Option 1: Open Individual Packages (Recommended)

The best way to work with this monorepo in Android Studio is to **open each package/app individually**:

1. **Close Android Studio** if it's open
2. **Open the specific package** you want to work on:
   - For quiz_engine_core: `File → Open → quiz_apps/packages/quiz_engine_core/`
   - For quiz_engine: `File → Open → quiz_apps/packages/quiz_engine/`
   - For flagsquiz: `File → Open → quiz_apps/apps/flagsquiz/`

3. **Wait for indexing** to complete (bottom right status bar)
4. **Test autocomplete** - type `import 'package:` and you should see suggestions

**Benefits:**
- Full autocomplete and code intelligence
- Hot reload works perfectly
- No configuration needed
- Each package is treated as its own project

### Option 2: Open Root with Multiple Projects

If you need to work across multiple packages simultaneously:

1. **Open the root directory:**
   ```bash
   cd quiz_apps
   open -a "Android Studio" .
   ```

2. **Attach Flutter SDK:**
   - Go to `Preferences → Languages & Frameworks → Flutter`
   - Set Flutter SDK path (usually `/Users/YOUR_USERNAME/development/flutter`)
   - Click "Apply"

3. **Invalidate Caches:**
   - Go to `File → Invalidate Caches and Restart`
   - Click "Invalidate and Restart"
   - Wait for re-indexing (5-10 minutes)

4. **Run pub get in each package:**
   ```bash
   cd quiz_apps
   dart run melos bootstrap
   ```

5. **Verify .iml files exist:**
   ```bash
   ls packages/*/melos_*.iml
   ls apps/*/melos_*.iml
   ```

6. **If still no autocomplete:**
   - Right-click on `packages/quiz_engine_core`
   - Select `Flutter → Pub Get`
   - Repeat for each package

### Option 3: Force Refresh

```bash
cd quiz_apps

# Clean everything
dart run melos clean

# Remove IDE files
rm -rf .idea .dart_tool

# Bootstrap again
dart run melos bootstrap

# Open Android Studio
open -a "Android Studio" .

# Then: File → Invalidate Caches and Restart
```

## Running Apps

### From Terminal:
```bash
cd quiz_apps/apps/flagsquiz
flutter run
```

### From Android Studio:

If you opened the root directory:

1. **Create Run Configuration:**
   - Click `Run → Edit Configurations`
   - Click `+` → `Flutter`
   - Name: `flagsquiz`
   - Dart entrypoint: `apps/flagsquiz/lib/main.dart`
   - Working directory: `$PROJECT_DIR$/apps/flagsquiz`
   - Click "Apply"

2. **Run:**
   - Select `flagsquiz` from dropdown
   - Click Run button or press `Ctrl+R`

If you opened `apps/flagsquiz` directly:
- Just click the Run button (it's auto-configured)

## Testing

### Run tests from terminal:
```bash
# All tests
cd quiz_apps
dart run melos run test

# Specific package
cd packages/quiz_engine_core
flutter test

# With coverage
flutter test --coverage
```

### Run tests from Android Studio:

1. **Right-click** on `test/` folder
2. **Select** `Run 'tests in test'`

Or:

1. **Open a test file**
2. **Click the green arrow** next to test name
3. **Select** `Run` or `Debug`

## Troubleshooting

### No autocomplete at all

**Solution:**
```bash
# 1. Ensure Flutter SDK is set
Android Studio → Preferences → Languages & Frameworks → Flutter

# 2. Refresh dependencies
cd quiz_apps
dart run melos bootstrap

# 3. Restart IDE
File → Invalidate Caches and Restart
```

### Package imports show red

**Solution:**
```bash
# Run pub get in the specific package
cd packages/quiz_engine
flutter pub get

# Or bootstrap everything
cd ../..
dart run melos bootstrap
```

### Autocomplete works but shows old code

**Solution:**
- `File → Invalidate Caches and Restart → Invalidate and Restart`

### Changes in quiz_engine_core not reflected in quiz_engine

**Solution:**
```bash
# Path dependencies are live-linked, but sometimes cache needs refresh
cd quiz_apps/packages/quiz_engine
flutter pub get

# Or hot restart your app instead of hot reload
```

### "Dart SDK is not configured"

**Solution:**
1. `Preferences → Languages & Frameworks → Dart`
2. Check `Enable Dart support`
3. Dart SDK path should be: `/YOUR_FLUTTER_PATH/bin/cache/dart-sdk`
4. Click "Apply"

## Recommended Workflow

### For Package Development:

1. **Open package directly** in Android Studio
   ```bash
   open -a "Android Studio" quiz_apps/packages/quiz_engine_core
   ```

2. **Make changes**

3. **Run tests:**
   ```bash
   flutter test
   ```

4. **The changes are immediately available** to apps via path dependencies

### For App Development:

1. **Open app directly** in Android Studio
   ```bash
   open -a "Android Studio" quiz_apps/apps/flagsquiz
   ```

2. **Make changes**

3. **Hot reload** (r key) or **hot restart** (R key)

4. **Run tests:**
   ```bash
   flutter test
   ```

### For Cross-Package Changes:

1. **Use VS Code or multiple Android Studio windows:**
   - Window 1: `quiz_engine_core`
   - Window 2: `quiz_engine`
   - Window 3: `flagsquiz`

2. **Or use terminal + single AS window:**
   - Edit in Android Studio
   - Run commands in terminal
   - Hot reload to see changes

## Keyboard Shortcuts

### macOS:
- **Hot Reload:** `Cmd + \`
- **Hot Restart:** `Cmd + Shift + \`
- **Run:** `Ctrl + R`
- **Debug:** `Ctrl + D`
- **Go to Declaration:** `Cmd + B`
- **Find Usages:** `Option + F7`
- **Reformat Code:** `Cmd + Option + L`

### Windows/Linux:
- **Hot Reload:** `Ctrl + \`
- **Hot Restart:** `Ctrl + Shift + \`
- **Run:** `Shift + F10`
- **Debug:** `Shift + F9`
- **Go to Declaration:** `Ctrl + B`
- **Find Usages:** `Alt + F7`
- **Reformat Code:** `Ctrl + Alt + L`

## Best Practices

1. ✅ **Open individual packages** for best IDE experience
2. ✅ **Run `dart run melos bootstrap`** after pulling changes
3. ✅ **Use hot reload** during development
4. ✅ **Invalidate caches** if autocomplete stops working
5. ❌ **Don't edit** `pubspec_overrides.yaml` manually (melos manages it)
6. ❌ **Don't commit** `.dart_tool/`, `build/`, `.idea/workspace.xml`

## Still Having Issues?

1. **Check Flutter Doctor:**
   ```bash
   flutter doctor -v
   ```

2. **Check Dart Analysis:**
   ```bash
   cd quiz_apps/packages/quiz_engine_core
   dart analyze
   ```

3. **Verify path dependencies:**
   ```bash
   cat quiz_apps/packages/quiz_engine/pubspec.yaml | grep -A2 quiz_engine_core
   ```
   Should show: `path: ../quiz_engine_core`

4. **Check if melos created overrides:**
   ```bash
   cat quiz_apps/packages/quiz_engine/pubspec_overrides.yaml
   ```
   Should contain path to quiz_engine_core

---

**Quick Start:**
```bash
cd quiz_apps
dart run melos bootstrap
open -a "Android Studio" apps/flagsquiz
# Wait for indexing, then start coding!
```
