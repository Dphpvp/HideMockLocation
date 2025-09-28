#!/system/bin/sh

# HideMockLocation Test Script
# Run this on your device to test if mock location is hidden

echo "========================================"
echo "  HideMockLocation Functionality Test   "
echo "========================================"
echo ""

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ ERROR: This script requires root access"
    echo "Run with: adb shell su -c 'sh /sdcard/test_hidemock.sh'"
    exit 1
fi

echo "✅ Running as root"
echo ""

# Test 1: System Properties
echo "🔍 Testing System Properties..."
MOCK_LOCATION=$(getprop ro.allow.mock.location)
DEBUG_MODE=$(getprop ro.debuggable)
SECURE_MODE=$(getprop ro.secure)
BUILD_TYPE=$(getprop ro.build.type)

echo "  ro.allow.mock.location: $MOCK_LOCATION"
echo "  ro.debuggable: $DEBUG_MODE"
echo "  ro.secure: $SECURE_MODE"
echo "  ro.build.type: $BUILD_TYPE"

if [ "$MOCK_LOCATION" = "0" ] && [ "$DEBUG_MODE" = "0" ]; then
    echo "  ✅ System properties look good"
else
    echo "  ❌ System properties not properly set"
fi

echo ""

# Test 2: Settings Database
echo "🔍 Testing Settings Database..."
SECURE_MOCK=$(settings get secure mock_location)
SYSTEM_MOCK=$(settings get system mock_location)
GLOBAL_MOCK=$(settings get global mock_location)

echo "  Settings secure mock_location: $SECURE_MOCK"
echo "  Settings system mock_location: $SYSTEM_MOCK"
echo "  Settings global mock_location: $GLOBAL_MOCK"

if [ "$SECURE_MOCK" = "0" ] || [ "$SECURE_MOCK" = "null" ]; then
    echo "  ✅ Settings database looks good"
else
    echo "  ❌ Settings database not properly modified"
fi

echo ""

# Test 3: Module Status
echo "🔍 Testing Module Status..."
MODULE_PATH="/data/adb/modules/hidemocklocation_universal"

if [ -d "$MODULE_PATH" ]; then
    echo "  ✅ Module installed at: $MODULE_PATH"

    if [ -f "$MODULE_PATH/disable" ]; then
        echo "  ❌ Module is DISABLED"
    else
        echo "  ✅ Module is enabled"
    fi

    # Check if scripts exist
    [ -f "$MODULE_PATH/service.sh" ] && echo "  ✅ service.sh present" || echo "  ❌ service.sh missing"
    [ -f "$MODULE_PATH/post-fs-data.sh" ] && echo "  ✅ post-fs-data.sh present" || echo "  ❌ post-fs-data.sh missing"

else
    echo "  ❌ Module not found at expected location"
fi

echo ""

# Test 4: Runtime Scripts
echo "🔍 Testing Runtime Scripts..."
if [ -f "/data/local/tmp/hidemocklocation.log" ]; then
    echo "  ✅ Service log found"
    echo "  📋 Last 5 log entries:"
    tail -5 /data/local/tmp/hidemocklocation.log | sed 's/^/    /'
else
    echo "  ❌ Service log not found (service may not have run)"
fi

if [ -f "/data/local/tmp/test_mock_hiding.sh" ]; then
    echo "  ✅ Test script created by service"
else
    echo "  ❌ Test script not created"
fi

echo ""

# Test 5: Process Check
echo "🔍 Testing Background Processes..."
MONITOR_PROC=$(ps | grep mock_monitor | grep -v grep)
if [ -n "$MONITOR_PROC" ]; then
    echo "  ✅ Monitor process running"
else
    echo "  ⚠️  Monitor process not found"
fi

echo ""

# Test 6: Developer Options
echo "🔍 Testing Developer Options..."
if [ -f "/data/data/com.android.providers.settings/databases/settings.db" ]; then
    echo "  ✅ Settings database accessible"
    # Note: This would require sqlite3 to query properly
else
    echo "  ❌ Settings database not accessible"
fi

echo ""

# Test 7: Mock Location App Test
echo "🔍 Mock Location App Test..."
echo "  📱 Install a fake GPS app and enable mock location"
echo "  📱 Test with apps that detect mock location:"
echo "     - Banking apps"
echo "     - Pokemon GO"
echo "     - Uber/Lyft"
echo "     - Dating apps (Tinder, Bumble)"
echo ""

# Summary
echo "========================================"
echo "                Summary                 "
echo "========================================"

if [ "$MOCK_LOCATION" = "0" ] && [ "$DEBUG_MODE" = "0" ] && [ -d "$MODULE_PATH" ]; then
    echo "✅ HideMockLocation appears to be working"
    echo ""
    echo "🧪 Next Steps:"
    echo "1. Install a fake GPS app (like Fake GPS Location)"
    echo "2. Enable mock location in Developer Options"
    echo "3. Set fake GPS app as mock location app"
    echo "4. Test with apps that normally detect mock location"
    echo ""
    echo "📋 For detailed testing, run the app-specific test script:"
    echo "   /data/local/tmp/test_mock_hiding.sh"
else
    echo "❌ HideMockLocation may not be working properly"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "1. Reboot your device"
    echo "2. Check Magisk Manager - ensure module is enabled"
    echo "3. Check /data/local/tmp/hidemocklocation.log for errors"
    echo "4. Try disabling and re-enabling the module"
fi

echo ""
echo "📱 Device: $(getprop ro.product.model)"
echo "🤖 Android: $(getprop ro.build.version.release) (API $(getprop ro.build.version.sdk))"
echo "🏭 Manufacturer: $(getprop ro.product.manufacturer)"
echo ""