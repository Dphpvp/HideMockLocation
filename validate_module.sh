#!/bin/bash

# Validation script for HideMockLocation Universal Magisk module
ZIP_FILE="HideMockLocation-Universal-v2.0.0.zip"

echo "=== HideMockLocation Universal Module Validation ==="
echo ""

# Check if zip exists
if [ ! -f "$ZIP_FILE" ]; then
    echo "❌ ERROR: $ZIP_FILE not found!"
    exit 1
fi

echo "✅ Zip file exists: $ZIP_FILE"
echo "📦 Size: $(stat -c%s "$ZIP_FILE" 2>/dev/null || stat -f%z "$ZIP_FILE" 2>/dev/null) bytes"
echo ""

# Required files for Magisk module
REQUIRED_FILES=(
    "module.prop"
    "META-INF/com/google/android/update-binary"
    "META-INF/com/google/android/updater-script"
)

OPTIONAL_FILES=(
    "service.sh"
    "post-fs-data.sh"
    "system.prop"
    "sepolicy.rule"
    "uninstall.sh"
)

echo "🔍 Checking required files..."
for file in "${REQUIRED_FILES[@]}"; do
    if unzip -l "$ZIP_FILE" | grep -q "$file"; then
        echo "  ✅ $file"
    else
        echo "  ❌ MISSING: $file"
    fi
done

echo ""
echo "🔍 Checking optional files..."
for file in "${OPTIONAL_FILES[@]}"; do
    if unzip -l "$ZIP_FILE" | grep -q "$file"; then
        echo "  ✅ $file"
    else
        echo "  ⚠️  MISSING: $file"
    fi
done

echo ""
echo "📋 Module structure:"
unzip -l "$ZIP_FILE"

echo ""
echo "=== Installation Instructions ==="
echo "1. Transfer $ZIP_FILE to your Android device"
echo "2. Open Magisk Manager"
echo "3. Go to 'Modules' tab"
echo "4. Tap 'Install from storage'"
echo "5. Select $ZIP_FILE"
echo "6. Wait for installation to complete"
echo "7. Reboot your device"
echo ""
echo "=== Troubleshooting ==="
echo "If installation fails:"
echo "- Check Magisk version (requires v20.4+)"
echo "- Verify Android version (requires 9+/API 28+)"
echo "- Check Magisk logs for error details"
echo "- Ensure sufficient storage space"
echo ""
echo "✅ Module validation complete!"