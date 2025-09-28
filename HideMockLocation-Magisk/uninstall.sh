#!/system/bin/sh

# HideMockLocation Universal - Uninstallation Script
# This script runs when the module is removed

LOG_FILE="/data/local/tmp/hidemocklocation_uninstall.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HideMockLocation Uninstall: $1" >> "$LOG_FILE"
    echo "HideMockLocation Uninstall: $1"
}

log "Starting module uninstallation..."

# Clean up temporary files
cleanup_temp_files() {
    log "Cleaning up temporary files..."

    # Remove temporary directories
    rm -rf /data/local/tmp/hidemock_patch 2>/dev/null
    rm -rf /data/local/tmp/framework_temp.jar 2>/dev/null

    # Remove monitoring scripts
    rm -f /data/local/tmp/hook_monitor.sh 2>/dev/null
    rm -f /data/local/tmp/logcat_filter.sh 2>/dev/null

    # Remove property files
    rm -f /data/property/persistent_properties 2>/dev/null

    log "Temporary files cleaned up"
}

# Reset system properties
reset_properties() {
    log "Resetting system properties..."

    # Reset mock location properties to default
    resetprop --delete ro.allow.mock.location 2>/dev/null
    resetprop --delete persist.sys.mock_location 2>/dev/null
    resetprop --delete persist.vendor.mock_location 2>/dev/null
    resetprop --delete ro.config.mock_location 2>/dev/null

    # Reset debug properties
    resetprop --delete ro.debuggable 2>/dev/null
    resetprop --delete ro.secure 2>/dev/null

    log "System properties reset"
}

# Remove runtime hooks
remove_runtime_hooks() {
    log "Removing runtime hooks..."

    # Kill monitoring processes
    pkill -f "hook_monitor.sh" 2>/dev/null
    pkill -f "logcat_filter.sh" 2>/dev/null

    # Unmount any bound files
    umount /system/lib64/liblocation_hook.so 2>/dev/null
    umount /system/lib/liblocation_hook.so 2>/dev/null
    umount /system/bin/logcat 2>/dev/null

    log "Runtime hooks removed"
}

# Clean up logs
cleanup_logs() {
    log "Cleaning up log files..."

    # Remove old log files (keep recent ones for debugging)
    find /data/local/tmp -name "hidemocklocation*.log" -mtime +7 -delete 2>/dev/null

    log "Log cleanup completed"
}

# Restore system state
restore_system_state() {
    log "Restoring system state..."

    # Note: Framework.jar changes are handled by Magisk automatically
    # when the module is removed, but we can do additional cleanup here

    # Reset any app-specific modifications
    if [ -d "/data/data" ]; then
        for app_dir in /data/data/*; do
            if [ -d "$app_dir" ]; then
                # Remove any app-specific bypass files we might have created
                rm -f "$app_dir/lib/libhidemock_bypass.so" 2>/dev/null
            fi
        done
    fi

    log "System state restoration completed"
}

# Main uninstallation process
main() {
    log "HideMockLocation Universal uninstallation started"

    # Perform cleanup steps
    cleanup_temp_files
    reset_properties
    remove_runtime_hooks
    restore_system_state
    cleanup_logs

    log "HideMockLocation Universal uninstallation completed"
    log "Please reboot your device to ensure all changes are applied"

    # Final message
    echo ""
    echo "HideMockLocation Universal has been uninstalled."
    echo "Please reboot your device to complete the removal process."
    echo ""
}

# Error handling
set -e
trap 'log "Uninstall script error on line $LINENO"' ERR

# Execute main function
main