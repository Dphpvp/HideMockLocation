#!/system/bin/sh

# Smali Patcher for Android Location Framework
# Supports Android 9-16 (API 28-35)

MODDIR=${0%/*}
FRAMEWORK_DIR="/system/framework"
TEMP_DIR="/data/local/tmp/hidemock_patch"
BAKSMALI_JAR="$MODDIR/tools/baksmali.jar"
SMALI_JAR="$MODDIR/tools/smali.jar"

# Android version detection
SDK_VERSION=$(getprop ro.build.version.sdk)
ANDROID_VERSION=$(getprop ro.build.version.release)

log_info() {
    echo "[HideMockLocation] $1"
}

log_error() {
    echo "[HideMockLocation] ERROR: $1"
}

# Create temp directory
mkdir -p "$TEMP_DIR"

# Extract framework.jar
log_info "Extracting framework.jar for Android $ANDROID_VERSION (API $SDK_VERSION)"
cp "$FRAMEWORK_DIR/framework.jar" "$TEMP_DIR/"

# Decompile framework.jar
log_info "Decompiling framework.jar..."
java -jar "$BAKSMALI_JAR" d "$TEMP_DIR/framework.jar" -o "$TEMP_DIR/framework_out" -a "$SDK_VERSION"

if [ $? -ne 0 ]; then
    log_error "Failed to decompile framework.jar"
    exit 1
fi

# Apply patches based on Android version
case "$SDK_VERSION" in
    28|29) # Android 9-10
        log_info "Applying patches for Android 9-10"
        apply_patches_api28_29
        ;;
    30|31) # Android 11-12
        log_info "Applying patches for Android 11-12"
        apply_patches_api30_31
        ;;
    32|33) # Android 12L-13
        log_info "Applying patches for Android 12L-13"
        apply_patches_api32_33
        ;;
    34|35) # Android 14-15
        log_info "Applying patches for Android 14-15"
        apply_patches_api34_35
        ;;
    *) # Future versions (Android 16+)
        log_info "Applying universal patches for Android 16+"
        apply_universal_patches
        ;;
esac

# Recompile framework.jar
log_info "Recompiling framework.jar..."
java -jar "$SMALI_JAR" a "$TEMP_DIR/framework_out" -o "$TEMP_DIR/classes.dex" -a "$SDK_VERSION"

if [ $? -ne 0 ]; then
    log_error "Failed to recompile framework.jar"
    exit 1
fi

# Create patched framework.jar
log_info "Creating patched framework.jar..."
cp "$TEMP_DIR/framework.jar" "$TEMP_DIR/framework_patched.jar"
cd "$TEMP_DIR"
zip -u framework_patched.jar classes.dex

# Copy to module directory
mkdir -p "$MODDIR/system/framework"
cp "$TEMP_DIR/framework_patched.jar" "$MODDIR/system/framework/framework.jar"

log_info "Framework patching completed successfully"

# Cleanup
rm -rf "$TEMP_DIR"

apply_patches_api28_29() {
    # Android 9-10 specific patches
    patch_location_class_legacy
    patch_settings_secure_legacy
}

apply_patches_api30_31() {
    # Android 11-12 specific patches
    patch_location_class_modern
    patch_settings_secure_modern
    patch_location_manager_service
}

apply_patches_api32_33() {
    # Android 12L-13 specific patches
    patch_location_class_modern
    patch_settings_secure_modern
    patch_location_manager_service
    patch_gnss_location_provider
}

apply_patches_api34_35() {
    # Android 14-15 specific patches
    patch_location_class_v14
    patch_settings_secure_v14
    patch_location_manager_service_v14
    patch_privacy_indicators
}

apply_universal_patches() {
    # Universal patches for future Android versions
    patch_location_class_universal
    patch_settings_universal
}

patch_location_class_legacy() {
    local LOCATION_FILE="$TEMP_DIR/framework_out/android/location/Location.smali"

    if [ -f "$LOCATION_FILE" ]; then
        log_info "Patching Location.smali for API 28-29"

        # Patch isFromMockProvider()
        sed -i '/\.method public isFromMockProvider()Z/,/\.end method/ {
            /return/c\
            const/4 v0, 0x0\
            return v0
        }' "$LOCATION_FILE"

        # Patch isMock()
        sed -i '/\.method public isMock()Z/,/\.end method/ {
            /return/c\
            const/4 v0, 0x0\
            return v0
        }' "$LOCATION_FILE"

        log_info "Location.smali patched successfully"
    else
        log_error "Location.smali not found"
    fi
}

patch_location_class_modern() {
    local LOCATION_FILE="$TEMP_DIR/framework_out/android/location/Location.smali"

    if [ -f "$LOCATION_FILE" ]; then
        log_info "Patching Location.smali for API 30-33"

        # Enhanced patches for modern Android
        sed -i '/\.method public isFromMockProvider()Z/,/\.end method/ {
            /iget/d
            /if-/d
            /goto/d
            /return/c\
            const/4 v0, 0x0\
            return v0
        }' "$LOCATION_FILE"

        # Patch getExtras() to remove mock indicators
        sed -i '/\.method public getExtras()Landroid\/os\/Bundle;/,/\.end method/ {
            /invoke-virtual.*mockLocation/d
            /const-string.*mockLocation/d
        }' "$LOCATION_FILE"

        log_info "Modern Location.smali patched successfully"
    fi
}

patch_location_class_v14() {
    local LOCATION_FILE="$TEMP_DIR/framework_out/android/location/Location.smali"

    if [ -f "$LOCATION_FILE" ]; then
        log_info "Patching Location.smali for API 34-35"

        # Android 14+ specific patches
        sed -i '/\.method.*isFromMockProvider/,/\.end method/ {
            s/iget-boolean.*HAS_MOCK_PROVIDER_MASK.*/const\/4 v0, 0x0/
            /return/c\
            return v0
        }' "$LOCATION_FILE"

        log_info "Android 14+ Location.smali patched successfully"
    fi
}

patch_settings_secure_legacy() {
    local SETTINGS_FILE="$TEMP_DIR/framework_out/android/provider/Settings\$Secure.smali"

    if [ -f "$SETTINGS_FILE" ]; then
        log_info "Patching Settings\$Secure.smali"

        # Patch getString for mock_location
        sed -i '/const-string.*"mock_location"/,+10 {
            /const-string.*"mock_location"/ {
                a\
                const-string v0, "0"\
                return-object v0
            }
        }' "$SETTINGS_FILE"

        log_info "Settings\$Secure.smali patched successfully"
    fi
}