#!/system/bin/sh

# Auto-Start Stealth System - Always Active
# This script ensures all stealth systems are always running

MODDIR="/data/adb/modules/hidemocklocation_universal"
LOG_FILE="/data/local/tmp/auto_start_stealth.log"

log_auto() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] AutoStart: $1" >> "$LOG_FILE"
}

log_auto "Starting auto stealth system"

# Function to start a script safely
start_script_safe() {
    local script_name="$1"
    local script_path="$MODDIR/tools/$script_name"

    if [ -f "$script_path" ]; then
        if [ -x "$script_path" ]; then
            log_auto "Starting $script_name"
            # Use nohup to ensure scripts persist
            nohup "$script_path" >/dev/null 2>&1 &
            sleep 1
        else
            log_auto "ERROR: $script_name not executable"
            chmod +x "$script_path"
            nohup "$script_path" >/dev/null 2>&1 &
        fi
    else
        log_auto "ERROR: $script_name not found at $script_path"
    fi
}

# Function to check if script is running
is_script_running() {
    local script_name="$1"
    pgrep -f "$script_name" >/dev/null
}

# Function to start all stealth systems
start_all_stealth_systems() {
    log_auto "Starting all stealth systems..."

    # Start each system with error handling
    start_script_safe "java_hooks.sh"
    start_script_safe "gps_provider_spoof.sh"
    start_script_safe "native_hooks.sh"
    start_script_safe "app_specific_bypass.sh"
    start_script_safe "advanced_framework_patches.sh"
    start_script_safe "system_call_interception.sh"
    start_script_safe "sensor_spoofing.sh"
    start_script_safe "memory_process_obfuscation.sh"
    start_script_safe "advanced_timing_behavioral.sh"
    start_script_safe "network_validation_spoofing.sh"
    start_script_safe "hardware_signature_spoofing.sh"
    start_script_safe "kernel_level_hooks.sh"

    # Wait for systems to initialize
    sleep 5

    log_auto "All stealth systems startup completed"
}

# Function to monitor and restart systems
monitor_systems() {
    log_auto "Starting system monitor"

    while true; do
        # List of critical systems to monitor
        SYSTEMS=(
            "java_hooks.sh"
            "gps_provider_spoof.sh"
            "native_hooks.sh"
            "app_specific_bypass.sh"
        )

        for system in "${SYSTEMS[@]}"; do
            if ! is_script_running "$system"; then
                log_auto "RESTART: $system stopped, restarting..."
                start_script_safe "$system"
            fi
        done

        # Check every 60 seconds
        sleep 60
    done
}

# Apply basic stealth properties immediately
apply_immediate_stealth() {
    log_auto "Applying immediate stealth properties"

    # Core properties
    resetprop ro.allow.mock.location 0 2>/dev/null
    resetprop persist.sys.mock_location 0 2>/dev/null
    resetprop ro.debuggable 0 2>/dev/null
    resetprop ro.secure 1 2>/dev/null
    resetprop ro.build.type user 2>/dev/null
    resetprop ro.build.tags release-keys 2>/dev/null

    # USB debugging
    resetprop persist.sys.usb.config none 2>/dev/null

    # Bootloader security
    resetprop ro.boot.verifiedbootstate green 2>/dev/null
    resetprop ro.boot.flash.locked 1 2>/dev/null

    # Settings
    settings put secure mock_location 0 2>/dev/null
    settings put global development_settings_enabled 0 2>/dev/null
    settings put global adb_enabled 0 2>/dev/null

    log_auto "Immediate stealth properties applied"
}

# Create systemd-style service
create_persistent_service() {
    # Create a script that runs at boot and monitors continuously
    cat > /data/local/tmp/stealth_service.sh << 'SERVICE_EOF'
#!/system/bin/sh

# Persistent stealth service
while true; do
    # Check if auto_start_stealth is running
    if ! pgrep -f "auto_start_stealth.sh" >/dev/null; then
        # Restart auto start script
        nohup /data/adb/modules/hidemocklocation_universal/auto_start_stealth.sh >/dev/null 2>&1 &
    fi

    # Apply properties every 5 minutes
    resetprop ro.allow.mock.location 0 2>/dev/null
    resetprop ro.debuggable 0 2>/dev/null
    settings put secure mock_location 0 2>/dev/null

    sleep 300  # 5 minutes
done
SERVICE_EOF

    chmod +x /data/local/tmp/stealth_service.sh

    # Start the persistent service
    nohup /data/local/tmp/stealth_service.sh >/dev/null 2>&1 &

    log_auto "Persistent service created and started"
}

# Main execution
main() {
    log_auto "=== AUTO START STEALTH MAIN ==="

    # Apply immediate stealth
    apply_immediate_stealth

    # Start all stealth systems
    start_all_stealth_systems

    # Create persistent monitoring
    create_persistent_service

    # Start continuous monitoring
    monitor_systems &

    log_auto "Auto start stealth system fully initialized"
}

# Run main function
main