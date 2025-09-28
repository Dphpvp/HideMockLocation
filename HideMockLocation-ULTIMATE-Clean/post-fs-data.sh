#!/system/bin/sh

# HideMockLocation Universal - Post-FS-Data Script
MODDIR=${0%/*}

# Early property setup (before system fully boots)
resetprop ro.allow.mock.location 0
resetprop persist.sys.mock_location 0
resetprop ro.debuggable 0
resetprop ro.secure 1
resetprop ro.build.type "user"
resetprop ro.build.tags "release-keys"

# Create early settings override
# This runs before apps can read the settings
settings put secure mock_location 0 2>/dev/null &
settings put system mock_location 0 2>/dev/null &
settings put global mock_location 0 2>/dev/null &

# Samsung-specific properties for S21 FE and Knox
resetprop ro.config.knox "v30"
resetprop ro.boot.warranty_bit "0"
resetprop ro.warranty_bit "0"
resetprop ro.boot.veritymode "enforcing"
resetprop ro.boot.verifiedbootstate "green"
resetprop ro.boot.flash.locked "1"

# Additional Samsung properties
resetprop persist.vendor.radio.enable_mock_location 0
resetprop vendor.gps.mock_location 0

# Create logcat filter to prevent detection through logs
if [ -x "/system/bin/logcat" ]; then
    # Create filtered logcat that hides mock location logs
    mount --bind "$MODDIR/tools/logcat_filter" /system/bin/logcat 2>/dev/null || true
fi

echo "HideMockLocation: Post-FS-Data setup completed" > /data/local/tmp/hidemock_early.log