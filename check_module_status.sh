#!/system/bin/sh

# HideMockLocation Module Status Checker
# Run this script on your Android device via ADB shell or terminal

echo "=== HideMockLocation Module Status Check ==="
echo ""

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ ERROR: This script requires root access"
    echo "Run: su -c 'sh /sdcard/check_module_status.sh'"
    exit 1
fi

echo "✅ Running as root"
echo ""

# Check Magisk installation
if [ -d "/data/adb" ]; then
    echo "✅ Magisk detected: /data/adb exists"
else
    echo "❌ Magisk not found: /data/adb missing"
    exit 1
fi

# Check modules directory
if [ -d "/data/adb/modules" ]; then
    echo "✅ Modules directory exists"
    echo "📂 Installed modules:"
    ls -la /data/adb/modules/ | grep -E "^d" | awk '{print "  - " $9}' | grep -v "^\.$\|^\.\.$"
else
    echo "❌ Modules directory missing"
fi

# Check our specific module
MODULE_ID="hidemocklocation_universal"
MODULE_PATH="/data/adb/modules/$MODULE_ID"

echo ""
echo "🔍 Checking HideMockLocation module..."

if [ -d "$MODULE_PATH" ]; then
    echo "✅ Module directory exists: $MODULE_PATH"

    # Check module.prop
    if [ -f "$MODULE_PATH/module.prop" ]; then
        echo "✅ module.prop found"
        echo "📋 Module info:"
        cat "$MODULE_PATH/module.prop" | sed 's/^/  /'
    else
        echo "❌ module.prop missing"
    fi

    # Check if module is disabled
    if [ -f "$MODULE_PATH/disable" ]; then
        echo "⚠️  Module is DISABLED (disable file exists)"
    else
        echo "✅ Module is enabled"
    fi

    # Check if module failed to load
    if [ -f "$MODULE_PATH/remove" ]; then
        echo "❌ Module marked for removal"
    fi

    # Check scripts
    echo ""
    echo "📜 Module scripts:"
    [ -f "$MODULE_PATH/service.sh" ] && echo "  ✅ service.sh" || echo "  ❌ service.sh"
    [ -f "$MODULE_PATH/post-fs-data.sh" ] && echo "  ✅ post-fs-data.sh" || echo "  ❌ post-fs-data.sh"
    [ -f "$MODULE_PATH/system.prop" ] && echo "  ✅ system.prop" || echo "  ❌ system.prop"
    [ -f "$MODULE_PATH/sepolicy.rule" ] && echo "  ✅ sepolicy.rule" || echo "  ❌ sepolicy.rule"

    # Check system overlay
    echo ""
    echo "🗂️  System overlay:"
    if [ -d "$MODULE_PATH/system" ]; then
        find "$MODULE_PATH/system" -type f | sed 's/^/  ✅ /'
    else
        echo "  ❌ No system overlay found"
    fi

else
    echo "❌ Module NOT installed: $MODULE_PATH does not exist"
    echo ""
    echo "💡 Troubleshooting steps:"
    echo "1. Check if installation actually completed"
    echo "2. Look for any 'remove' or 'disable' files"
    echo "3. Check Magisk logs for errors"
    echo "4. Reinstall the module"
    exit 1
fi

# Check if module is working
echo ""
echo "🧪 Testing mock location properties..."

MOCK_LOCATION=$(getprop ro.allow.mock.location)
DEBUG_MODE=$(getprop ro.debuggable)

echo "📊 Current system properties:"
echo "  ro.allow.mock.location: $MOCK_LOCATION"
echo "  ro.debuggable: $DEBUG_MODE"
echo "  persist.sys.mock_location: $(getprop persist.sys.mock_location)"

if [ "$MOCK_LOCATION" = "0" ] && [ "$DEBUG_MODE" = "0" ]; then
    echo "✅ Properties appear to be set correctly"
else
    echo "⚠️  Properties may not be applied yet (reboot needed?)"
fi

# Check logs
echo ""
echo "📋 Recent module logs:"
if [ -f "/data/local/tmp/hidemocklocation.log" ]; then
    echo "✅ Log file found:"
    tail -10 /data/local/tmp/hidemocklocation.log | sed 's/^/  /'
else
    echo "⚠️  No log file found (module may not have run yet)"
fi

echo ""
echo "=== Status Check Complete ==="
echo ""

# Provide recommendations
if [ -d "$MODULE_PATH" ] && [ ! -f "$MODULE_PATH/disable" ]; then
    echo "🎯 Module appears to be installed correctly."
    echo "💡 If not working:"
    echo "1. Reboot your device"
    echo "2. Test with a mock location app"
    echo "3. Check specific app compatibility"
else
    echo "❌ Module installation issues detected."
    echo "💡 Try:"
    echo "1. Reinstalling the module"
    echo "2. Checking Magisk Manager logs"
    echo "3. Ensuring sufficient storage space"
fi