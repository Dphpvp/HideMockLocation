#!/system/bin/sh

# Debug Location Issue Script
# Run this to diagnose location detection problems

echo "=========================================="
echo "LOCATION ISSUE DIAGNOSTIC TOOL"
echo "=========================================="
echo ""

# Check if module is properly installed
echo "1. MODULE STATUS CHECK:"
if [ -d "/data/adb/modules/hidemocklocation_universal" ]; then
    echo "✅ Module installed: YES"
    MODULE_DIR="/data/adb/modules/hidemocklocation_universal"
else
    echo "❌ Module installed: NO"
    echo "   Check if module ID matches your module.prop"
    exit 1
fi

echo ""
echo "2. MODULE SERVICES STATUS:"
echo "Service script exists: $([ -f "$MODULE_DIR/service.sh" ] && echo "YES" || echo "NO")"
echo "Tools directory: $([ -d "$MODULE_DIR/tools" ] && echo "YES" || echo "NO")"

echo ""
echo "3. STEALTH SYSTEMS STATUS:"
echo "Java hooks: $(pgrep -f 'java_hooks.sh' >/dev/null && echo 'RUNNING' || echo 'NOT RUNNING')"
echo "GPS spoofing: $(pgrep -f 'gps_provider_spoof.sh' >/dev/null && echo 'RUNNING' || echo 'NOT RUNNING')"
echo "Native hooks: $(pgrep -f 'native_hooks.sh' >/dev/null && echo 'RUNNING' || echo 'NOT RUNNING')"
echo "App bypasses: $(pgrep -f 'app_specific_bypass.sh' >/dev/null && echo 'RUNNING' || echo 'NOT RUNNING')"
echo "Memory obfuscation: $(pgrep -f 'memory_process_obfuscation.sh' >/dev/null && echo 'RUNNING' || echo 'NOT RUNNING')"
echo "Master coordinator: $(pgrep -f 'master_stealth_coordinator.sh' >/dev/null && echo 'RUNNING' || echo 'NOT RUNNING')"

echo ""
echo "4. SYSTEM PROPERTIES CHECK:"
echo "ro.allow.mock.location: $(getprop ro.allow.mock.location)"
echo "ro.debuggable: $(getprop ro.debuggable)"
echo "ro.secure: $(getprop ro.secure)"
echo "persist.sys.usb.config: $(getprop persist.sys.usb.config)"

echo ""
echo "5. MOCK LOCATION APP STATUS:"
echo "Developer options enabled: $(settings get global development_settings_enabled)"
echo "Mock location app set: $(settings get secure mock_location_app)"

echo ""
echo "6. LOCATION SERVICES CHECK:"
# Check what location providers are available
echo "Available location providers:"
PROVIDERS=$(dumpsys location | grep -A 10 "Location Providers" | head -15)
echo "$PROVIDERS"

echo ""
echo "7. RUNNING LOCATION APPS:"
# Check what apps are currently requesting location
ps aux | grep -i "location\|gps\|maps" | head -10

echo ""
echo "8. POTENTIAL ISSUES & SOLUTIONS:"
echo ""

# Check common issues
if [ "$(getprop ro.allow.mock.location)" != "0" ]; then
    echo "⚠️  ISSUE: ro.allow.mock.location is not set to 0"
    echo "   SOLUTION: Module needs time to apply or needs reboot"
fi

if [ "$(getprop ro.debuggable)" != "0" ]; then
    echo "⚠️  ISSUE: ro.debuggable is not set to 0"
    echo "   SOLUTION: Module stealth not fully active"
fi

if [ "$(settings get global development_settings_enabled)" = "1" ]; then
    echo "⚠️  ISSUE: Developer options are visible as enabled"
    echo "   SOLUTION: This makes mock location more detectable"
fi

# Check if GPS is disabled (common issue)
GPS_ENABLED=$(settings get secure location_mode)
if [ "$GPS_ENABLED" = "0" ]; then
    echo "⚠️  ISSUE: GPS/Location is completely disabled"
    echo "   SOLUTION: Enable location services for apps to get ANY location"
fi

echo ""
echo "9. RECOMMENDATIONS:"
echo ""
echo "If apps still see REAL location:"
echo "• Make sure your mock location app is set as 'Mock location app' in Developer Options"
echo "• Ensure the mock location app is actively spoofing (green indicator/notification)"
echo "• Some apps bypass mock location by using network-based location only"
echo "• Try force-closing and reopening the problematic apps"
echo ""
echo "If apps DETECT mock location usage:"
echo "• The stealth module is not working - check stealth systems above"
echo "• Try specific app bypasses or wait for module to fully initialize"
echo ""
echo "=========================================="
echo "Run: su -c 'sh $PWD/debug_location_issue.sh'"
echo "=========================================="