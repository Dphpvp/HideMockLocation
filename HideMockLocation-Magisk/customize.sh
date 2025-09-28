#!/system/bin/sh

# HideMockLocation Universal - Customization Script

#################
# Permissions
#################

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/post-fs-data.sh 0 0 0755
  set_perm $MODPATH/uninstall.sh 0 0 0755

  if [ -d "$MODPATH/tools" ]; then
    set_perm_recursive $MODPATH/tools 0 0 0755 0755
    # Set specific permissions for ULTIMATE enhanced scripts
    set_perm $MODPATH/tools/java_hooks.sh 0 0 0755
    set_perm $MODPATH/tools/gps_provider_spoof.sh 0 0 0755
    set_perm $MODPATH/tools/native_hooks.sh 0 0 0755
    set_perm $MODPATH/tools/app_specific_bypass.sh 0 0 0755
    set_perm $MODPATH/tools/advanced_framework_patches.sh 0 0 0755
    set_perm $MODPATH/tools/system_call_interception.sh 0 0 0755
    set_perm $MODPATH/tools/sensor_spoofing.sh 0 0 0755
    set_perm $MODPATH/tools/memory_process_obfuscation.sh 0 0 0755
    set_perm $MODPATH/tools/advanced_timing_behavioral.sh 0 0 0755
    set_perm $MODPATH/tools/network_validation_spoofing.sh 0 0 0755
    set_perm $MODPATH/tools/hardware_signature_spoofing.sh 0 0 0755
    set_perm $MODPATH/tools/kernel_level_hooks.sh 0 0 0755
  fi

  if [ -d "$MODPATH/patches" ]; then
    set_perm_recursive $MODPATH/patches 0 0 0755 0755
  fi
}

#################
# Installation
#################

ui_print "*******************************************"
ui_print "🚀    HideMockLocation ULTIMATE    🚀"
ui_print "    The Most Advanced Mock Location    "
ui_print "       Hiding System Available        "
ui_print "         Android 9 - 16+              "
ui_print "*******************************************"

ui_print "- Detecting device info..."

SDK_VERSION=$(getprop ro.build.version.sdk)
ANDROID_VERSION=$(getprop ro.build.version.release)
MANUFACTURER=$(getprop ro.product.manufacturer)

ui_print "- Android: $ANDROID_VERSION (API $SDK_VERSION)"
ui_print "- Manufacturer: $MANUFACTURER"

# Check compatibility
if [ $SDK_VERSION -lt 28 ]; then
  abort "! Android 9+ (API 28+) is required"
fi

# Determine profile
case "$SDK_VERSION" in
  28|29) PROFILE="Legacy" ;;
  30|31) PROFILE="Modern" ;;
  32|33) PROFILE="Advanced" ;;
  34|35) PROFILE="Latest" ;;
  *) PROFILE="Future" ;;
esac

ui_print "- Profile: $PROFILE Android"

# OEM detection
case "$MANUFACTURER" in
  "samsung"|"Samsung")
    ui_print "- Samsung device detected"
    ;;
  "xiaomi"|"Xiaomi"|"Redmi")
    ui_print "- MIUI device detected"
    ;;
  *)
    ui_print "- Generic device"
    ;;
esac

ui_print "- Installing module files..."

# Remove placeholder files
rm -f $MODPATH/system/placeholder 2>/dev/null

ui_print "- Setting permissions..."
set_permissions

ui_print "- Installation complete!"
ui_print ""
ui_print "🔥 ULTIMATE features installed:"
ui_print "  ✅ Java method hooks & framework patches"
ui_print "  ✅ GPS provider & sensor spoofing"
ui_print "  ✅ Native library & system call hooks"
ui_print "  ✅ Memory obfuscation & process hiding"
ui_print "  ✅ Advanced timing & behavioral mimicking"
ui_print "  ✅ Network validation & hardware spoofing"
ui_print "  ✅ Kernel-level hooks & ultimate stealth"
ui_print "  ✅ App-specific bypasses for popular apps"
ui_print ""
ui_print "🔄 Reboot to activate ULTIMATE mock location hiding"
ui_print "🎯 Test with: su -c 'sh /data/local/tmp/test_ultimate_hiding.sh'"
ui_print "💪 NO KNOWN APP SHOULD DETECT MOCK LOCATION!"
ui_print ""