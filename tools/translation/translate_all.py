import subprocess
import sys
import os

# List of language codes supported by Amazon Translate
languages = [
    "af", "am", "ar", "az", "be", "bg", "bn", "bs", "ca", "hr", "cs", "da",
    "nl", "et", "fi", "fr", "ka", "de", "el", "gu", "he", "hi", "hu", "is",
    "id", "it", "ja", "kn", "kk", "ko", "lv", "lt", "ms", "ml", "mt", "mr",
    "mn", "no", "fa", "pl", "pt", "pa", "ro", "sr", "si", "sk", "sl", "es",
    "sw", "sv", "tl", "ta", "te", "th", "tr", "uk", "ur", "uz", "vi", "cy", "zh"
]

def translate_all_languages(source_file, output_dir, script_dir):
    """
    Translate source ARB file to all supported languages.

    Args:
        source_file: Path to source ARB file (e.g., lib/l10n/app_en.arb)
        output_dir: Directory to output translated files
        script_dir: Directory containing translate_arb.py
    """
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Get the base filename pattern
    base_name = os.path.basename(source_file)
    # Replace _en.arb with _{lang}.arb or app_en.arb with app_{lang}.arb
    if "_en.arb" in base_name:
        file_pattern = base_name.replace("_en.arb", "_{}.arb")
    elif "en.arb" in base_name:
        file_pattern = base_name.replace("en.arb", "{}.arb")
    else:
        print("Warning: Source file doesn't follow expected naming convention (*_en.arb or *en.arb)")
        file_pattern = "app_{}.arb"

    total_languages = len(languages)
    translate_script = os.path.join(script_dir, "translate_arb.py")

    print(f"Translating {source_file} to {total_languages} languages...")
    print(f"Output directory: {output_dir}")
    print(f"File pattern: {file_pattern}")
    print("-" * 80)

    for index, lang in enumerate(languages, start=1):
        # Format the target file name
        target_file = os.path.join(output_dir, file_pattern.format(lang))

        # Run the translation script
        result = subprocess.run(
            ["python3", translate_script, source_file, target_file, lang],
            capture_output=True,
            text=True
        )

        # Log the progress
        status = "✓" if result.returncode == 0 else "✗"
        print(f"[{status}] {index}/{total_languages}: {lang} -> {os.path.basename(target_file)}")

        if result.returncode != 0:
            print(f"    Error: {result.stderr}")

    print("-" * 80)
    print("Translation process completed.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 translate_all.py <source_arb_file> [output_directory]")
        print("")
        print("Examples:")
        print("  python3 translate_all.py lib/l10n/app_en.arb")
        print("  python3 translate_all.py lib/l10n/app_en.arb lib/l10n")
        print("  python3 translate_all.py ../apps/flagsquiz/lib/l10n/app_en.arb ../apps/flagsquiz/lib/l10n")
        sys.exit(1)

    source_file = sys.argv[1]

    # Default output directory is same as source file directory
    if len(sys.argv) >= 3:
        output_dir = sys.argv[2]
    else:
        output_dir = os.path.dirname(source_file)

    # Get script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Verify source file exists
    if not os.path.exists(source_file):
        print(f"Error: Source file not found: {source_file}")
        sys.exit(1)

    translate_all_languages(source_file, output_dir, script_dir)
