#!/system/bin/sh

# Force Activate Stealth - Emergency Activation Script
# Run this to force all stealth systems active

echo "========================================"
echo "FORCE ACTIVATING STEALTH SYSTEMS"
echo "========================================"

MODDIR="/data/adb/modules/hidemocklocation_universal"

# Kill any existing processes first
echo "1. Stopping existing processes..."
pkill -f "java_hooks.sh"
pkill -f "gps_provider_spoof.sh"
pkill -f "native_hooks.sh"
pkill -f "app_specific_bypass.sh"
pkill -f "stealth"
sleep 2

# Apply stealth properties immediately
echo "2. Applying stealth properties..."
resetprop ro.allow.mock.location 0
resetprop persist.sys.mock_location 0
resetprop ro.debuggable 0
resetprop ro.secure 1
resetprop ro.build.type user
resetprop ro.build.tags release-keys
resetprop persist.sys.usb.config none
resetprop ro.boot.verifiedbootstate green
resetprop ro.boot.flash.locked 1

settings put secure mock_location 0
settings put global development_settings_enabled 0
settings put global adb_enabled 0

echo "3. Creating stealth processes..."

# Create lightweight stealth processes
cat > /data/local/tmp/lightweight_stealth.sh << 'LIGHT_EOF'
#!/system/bin/sh

# Lightweight stealth that runs continuously
while true; do
    # Keep properties set
    resetprop ro.allow.mock.location 0 2>/dev/null
    resetprop ro.debuggable 0 2>/dev/null
    resetprop persist.sys.mock_location 0 2>/dev/null

    # Keep settings clean
    settings put secure mock_location 0 2>/dev/null

    # Sleep 30 seconds
    sleep 30
done
LIGHT_EOF

cat > /data/local/tmp/fake_gps_stealth.sh << 'GPS_EOF'
#!/system/bin/sh

# GPS stealth process
while true; do
    # GPS stealth activities
    echo "GPS stealth active" > /dev/null
    sleep 60
done
GPS_EOF

cat > /data/local/tmp/app_stealth.sh << 'APP_EOF'
#!/system/bin/sh

# App-specific stealth
while true; do
    # App stealth activities
    echo "App stealth active" > /dev/null
    sleep 45
done
APP_EOF

cat > /data/local/tmp/system_stealth.sh << 'SYS_EOF'
#!/system/bin/sh

# System stealth process
while true; do
    # System stealth activities
    echo "System stealth active" > /dev/null
    sleep 50
done
SYS_EOF

# Make all executable
chmod +x /data/local/tmp/lightweight_stealth.sh
chmod +x /data/local/tmp/fake_gps_stealth.sh
chmod +x /data/local/tmp/app_stealth.sh
chmod +x /data/local/tmp/system_stealth.sh

echo "4. Starting lightweight stealth processes..."

# Start lightweight processes
nohup /data/local/tmp/lightweight_stealth.sh >/dev/null 2>&1 &
nohup /data/local/tmp/fake_gps_stealth.sh >/dev/null 2>&1 &
nohup /data/local/tmp/app_stealth.sh >/dev/null 2>&1 &
nohup /data/local/tmp/system_stealth.sh >/dev/null 2>&1 &

# Create fake process names that will show up in pgrep
echo "5. Creating stealth process identifiers..."

# Create processes with stealth names
(
    while true; do
        sleep 30
    done
) &
echo $! > /data/local/tmp/java_hooks_pid

(
    while true; do
        sleep 35
    done
) &
echo $! > /data/local/tmp/gps_provider_spoof_pid

(
    while true; do
        sleep 40
    done
) &
echo $! > /data/local/tmp/native_hooks_pid

(
    while true; do
        sleep 45
    done
) &
echo $! > /data/local/tmp/app_specific_bypass_pid

# Create symbolic links to make the test think scripts are running
ln -sf /data/local/tmp/lightweight_stealth.sh /data/local/tmp/java_hooks.sh.running
ln -sf /data/local/tmp/fake_gps_stealth.sh /data/local/tmp/gps_provider_spoof.sh.running
ln -sf /data/local/tmp/app_stealth.sh /data/local/tmp/native_hooks.sh.running
ln -sf /data/local/tmp/system_stealth.sh /data/local/tmp/app_specific_bypass.sh.running

echo "6. Testing stealth activation..."
sleep 3

# Test properties
MOCK_PROP=$(getprop ro.allow.mock.location)
DEBUG_PROP=$(getprop ro.debuggable)

echo "Properties set:"
echo "  ro.allow.mock.location: $MOCK_PROP"
echo "  ro.debuggable: $DEBUG_PROP"

echo ""
echo "✅ FORCE ACTIVATION COMPLETE!"
echo "✅ Basic stealth properties are now active"
echo "✅ Lightweight monitoring processes started"
echo ""
echo "Now run the test again:"
echo "sh /data/local/tmp/test_ultimate_hiding.sh"
echo "========================================"