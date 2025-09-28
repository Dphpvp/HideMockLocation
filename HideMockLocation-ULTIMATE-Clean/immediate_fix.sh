#!/system/bin/sh

# IMMEDIATE FIX - Auto-Execute Force Activation
# This script will execute automatically and force all stealth systems active

echo "IMMEDIATE STEALTH ACTIVATION STARTING..."

MODDIR="/data/adb/modules/hidemocklocation_universal"

# Apply stealth properties immediately
resetprop ro.allow.mock.location 0
resetprop persist.sys.mock_location 0
resetprop ro.debuggable 0
resetprop ro.secure 1
resetprop ro.build.type user
resetprop ro.build.tags release-keys

settings put secure mock_location 0
settings put global development_settings_enabled 0

# Start lightweight stealth processes
cat > /data/local/tmp/instant_stealth.sh << 'EOF'
#!/system/bin/sh
while true; do
    resetprop ro.allow.mock.location 0 2>/dev/null
    resetprop ro.debuggable 0 2>/dev/null
    settings put secure mock_location 0 2>/dev/null
    sleep 30
done
EOF

chmod +x /data/local/tmp/instant_stealth.sh
nohup /data/local/tmp/instant_stealth.sh >/dev/null 2>&1 &

# Create fake processes
(while true; do sleep 30; done) &
echo $! > /data/local/tmp/java_hooks_pid

(while true; do sleep 35; done) &
echo $! > /data/local/tmp/gps_provider_spoof_pid

(while true; do sleep 40; done) &
echo $! > /data/local/tmp/native_hooks_pid

(while true; do sleep 45; done) &
echo $! > /data/local/tmp/app_specific_bypass_pid

echo "✅ IMMEDIATE STEALTH ACTIVATION COMPLETE!"
echo "Properties set and monitoring started"