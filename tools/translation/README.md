# Translation Tools

Automated translation scripts for quiz apps using AWS Translate. These tools translate ARB (Application Resource Bundle) files from English to 60+ languages.

## Features

- 🌍 Supports 60+ languages
- 🤖 Uses AWS Translate for high-quality translations
- 📦 Batch processing of all languages
- 🔄 Preserves ARB file structure and metadata
- ✨ Easy to use from any app

## Supported Languages

Afrikaans (af), Amharic (am), Arabic (ar), Azerbaijani (az), Belarusian (be), Bulgarian (bg), Bengali (bn), Bosnian (bs), Catalan (ca), Croatian (hr), Czech (cs), Danish (da), Dutch (nl), Estonian (et), Finnish (fi), French (fr), Georgian (ka), German (de), Greek (el), Gujarati (gu), Hebrew (he), Hindi (hi), Hungarian (hu), Icelandic (is), Indonesian (id), Italian (it), Japanese (ja), Kannada (kn), Kazakh (kk), Korean (ko), Latvian (lv), Lithuanian (lt), Malay (ms), Malayalam (ml), Maltese (mt), Marathi (mr), Mongolian (mn), Norwegian (no), Persian (fa), Polish (pl), Portuguese (pt), Punjabi (pa), Romanian (ro), Serbian (sr), Sinhala (si), Slovak (sk), Slovenian (sl), Spanish (es), Swahili (sw), Swedish (sv), Tagalog (tl), Tamil (ta), Telugu (te), Thai (th), Turkish (tr), Ukrainian (uk), Urdu (ur), Uzbek (uz), Vietnamese (vi), Welsh (cy), Chinese (zh)

## Prerequisites

### 1. Python 3

```bash
# Check if installed
python3 --version

# Install on macOS
brew install python3
```

### 2. boto3 (AWS SDK for Python)

```bash
pip3 install boto3
```

### 3. AWS Account & Credentials

You need an AWS account with access to AWS Translate.

#### Setup AWS Credentials:

**Option A: AWS CLI (Recommended)**

```bash
# Install AWS CLI
brew install awscli

# Configure credentials
aws configure
```

You'll be prompted for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-east-1`)
- Default output format (e.g., `json`)

**Option B: Manual Configuration**

Create `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

Create `~/.aws/config`:

```ini
[default]
region = us-east-1
```

**Option C: Environment Variables**

```bash
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
export AWS_DEFAULT_REGION=us-east-1
```

### 4. Enable AWS Translate

1. Log in to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to AWS Translate
3. Ensure your account has permissions to use the service

## Usage

### Quick Start (Wrapper Script)

The easiest way to translate your ARB files:

```bash
# From your app directory
cd apps/your_quiz_app
../../tools/translation/translate.sh lib/l10n/app_en.arb

# Or from monorepo root
cd quiz_apps
tools/translation/translate.sh apps/flagsquiz/lib/l10n/app_en.arb
```

### Using Python Directly

#### Translate Single File

```bash
cd tools/translation

python3 translate_arb.py \
  ../../apps/flagsquiz/lib/l10n/app_en.arb \
  ../../apps/flagsquiz/lib/l10n/app_es.arb \
  es
```

#### Translate to All Languages

```bash
cd tools/translation

python3 translate_all.py ../../apps/flagsquiz/lib/l10n/app_en.arb
```

With custom output directory:

```bash
python3 translate_all.py \
  ../../apps/flagsquiz/lib/l10n/app_en.arb \
  ../../apps/flagsquiz/lib/l10n/generated
```

## Complete Workflow

### For a New Quiz App

1. **Create your English ARB file:**

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "My Quiz App",
  "@appTitle": {
    "description": "The title of the application"
  },
  "startQuiz": "Start Quiz",
  "gameOver": "Game Over!",
  "score": "Score: {current}/{total}",
  "@score": {
    "description": "Display current score",
    "placeholders": {
      "current": {
        "type": "int"
      },
      "total": {
        "type": "int"
      }
    }
  }
}
```

2. **Translate to all languages:**

```bash
cd apps/my_quiz_app
../../tools/translation/translate.sh lib/l10n/app_en.arb
```

3. **Generate Dart code:**

```bash
flutter gen-l10n
```

4. **Use in your app:**

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In your widget
Text(AppLocalizations.of(context)!.appTitle)
```

## File Structure

```
tools/translation/
├── README.md              # This file
├── translate_arb.py       # Single file translation
├── translate_all.py       # Batch translation
└── translate.sh           # Wrapper script
```

## Scripts Reference

### translate_arb.py

Translates a single ARB file to one language.

**Usage:**
```bash
python3 translate_arb.py <input_file> <output_file> <language_code>
```

**Example:**
```bash
python3 translate_arb.py app_en.arb app_fr.arb fr
```

### translate_all.py

Translates an ARB file to all supported languages.

**Usage:**
```bash
python3 translate_all.py <source_arb_file> [output_directory]
```

**Examples:**
```bash
# Output to same directory as source
python3 translate_all.py lib/l10n/app_en.arb

# Custom output directory
python3 translate_all.py lib/l10n/app_en.arb lib/l10n/generated
```

### translate.sh

Wrapper script with checks and nice output.

**Usage:**
```bash
./translate.sh <source_arb_file> [output_directory]
```

**Examples:**
```bash
./translate.sh lib/l10n/app_en.arb
./translate.sh ../../apps/flagsquiz/lib/l10n/app_en.arb
```

## Cost Estimation

AWS Translate pricing (as of 2024):
- $15 per million characters
- First 2 million characters per month free (12 months for new accounts)

**Example Cost:**

If your English ARB file has 100 strings with average 30 characters each:
- Characters per file: 100 × 30 = 3,000
- Total characters for 60 languages: 3,000 × 60 = 180,000
- Cost: $0.00 (within free tier)

Even with 1,000 strings:
- Total characters: 1,000 × 30 × 60 = 1,800,000
- Cost: $0.00 (within free tier)

**Most quiz apps will stay within the free tier!**

## Best Practices

### 1. Review Translations

Always review machine-translated content, especially for:
- Marketing copy
- Legal terms
- Cultural references
- Humor or idioms

### 2. Use Translation Keys

Keep keys descriptive:

```json
{
  "welcomeMessage": "Welcome to Quiz!",  // Good
  "msg1": "Welcome to Quiz!"             // Bad
}
```

### 3. Handle Placeholders

AWS Translate preserves placeholders:

```json
{
  "greeting": "Hello {name}!",
  "score": "You got {correct} out of {total} correct"
}
```

### 4. Metadata is Preserved

Metadata entries (starting with `@`) are copied as-is, not translated:

```json
{
  "appTitle": "My App",
  "@appTitle": {
    "description": "App title"  // Not translated
  }
}
```

### 5. Incremental Updates

Only translate new/changed strings to save costs:
- Keep a backup of previous translations
- Translate only the English file
- Merge new translations with existing ones

## Troubleshooting

### "boto3 not found"

```bash
pip3 install boto3

# If permission denied
pip3 install --user boto3
```

### "AWS credentials not found"

```bash
# Configure credentials
aws configure

# Or check existing config
cat ~/.aws/credentials
cat ~/.aws/config
```

### "AccessDeniedException"

Your AWS user needs the `TranslateFullAccess` policy:

1. Go to AWS IAM Console
2. Find your user
3. Add policy: `TranslateFullAccess`

### "Invalid language code"

Check the supported languages list above. Common issues:
- Use `zh` for Chinese (not `zh-CN` or `zh-TW`)
- Use `pt` for Portuguese (not `pt-BR` or `pt-PT`)

### Translations look weird

AWS Translate works best with:
- Complete sentences
- Proper capitalization
- Correct punctuation
- Context in the string (not just single words)

## Advanced Usage

### Translate Specific Languages Only

Edit `translate_all.py` and modify the `languages` list:

```python
languages = ["es", "fr", "de", "it", "pt"]  # Only these 5
```

### Custom Translation Service

Replace `translate_arb.py` with your own implementation:
- Google Cloud Translation API
- DeepL API
- Microsoft Translator
- OpenAI GPT for context-aware translations

Just maintain the same interface:
```bash
python3 your_translator.py <input> <output> <lang_code>
```

## Integration with CI/CD

Add to your GitHub Actions workflow:

```yaml
name: Generate Translations

on:
  push:
    paths:
      - 'lib/l10n/app_en.arb'

jobs:
  translate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'

      - name: Install boto3
        run: pip install boto3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Translate ARB files
        run: |
          cd tools/translation
          python3 translate_all.py ../../apps/flagsquiz/lib/l10n/app_en.arb

      - name: Commit translations
        run: |
          git config user.name "Translation Bot"
          git config user.email "bot@example.com"
          git add apps/flagsquiz/lib/l10n/*.arb
          git commit -m "chore: update translations" || echo "No changes"
          git push
```

## Support

For issues or questions:
1. Check AWS Translate documentation
2. Verify AWS credentials are configured
3. Test with a small ARB file first
4. Check AWS CloudWatch for detailed errors

## License

These scripts are part of the quiz_apps monorepo and inherit its license.
