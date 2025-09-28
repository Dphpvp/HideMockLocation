#!/bin/bash

# Script to create proper Magisk module zip
# Run this to package the HideMockLocation Universal module

MODULE_DIR="HideMockLocation-Magisk"
OUTPUT_ZIP="HideMockLocation-Universal-v2.0.0.zip"

echo "Creating Magisk module zip: $OUTPUT_ZIP"

# Check if module directory exists
if [ ! -d "$MODULE_DIR" ]; then
    echo "Error: Module directory '$MODULE_DIR' not found!"
    exit 1
fi

# Remove old zip if exists
if [ -f "$OUTPUT_ZIP" ]; then
    echo "Removing old zip file..."
    rm "$OUTPUT_ZIP"
fi

# Set proper permissions before zipping
echo "Setting permissions..."
find "$MODULE_DIR" -type f -name "*.sh" -exec chmod 755 {} \;
find "$MODULE_DIR" -type f -name "update-binary" -exec chmod 755 {} \;
chmod 644 "$MODULE_DIR/module.prop"
chmod 644 "$MODULE_DIR/system.prop"
chmod 644 "$MODULE_DIR/sepolicy.rule"
chmod 644 "$MODULE_DIR/META-INF/com/google/android/updater-script"

# Create the zip with proper structure
echo "Creating zip file..."
cd "$MODULE_DIR"

# Create zip with all files
zip -r "../$OUTPUT_ZIP" . -x "*.git*" "*.DS_Store*" "*Thumbs.db*"

cd ..

echo "Zip file created: $OUTPUT_ZIP"

# Verify zip contents
echo ""
echo "Zip contents:"
unzip -l "$OUTPUT_ZIP"

echo ""
echo "Module zip ready for installation in Magisk Manager!"
echo ""
echo "Installation steps:"
echo "1. Copy $OUTPUT_ZIP to your Android device"
echo "2. Open Magisk Manager"
echo "3. Go to Modules -> Install from storage"
echo "4. Select $OUTPUT_ZIP"
echo "5. Reboot device after installation"