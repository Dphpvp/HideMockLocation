#!/system/bin/sh

# Native Library Hooks for Low-Level Mock Location Detection
# Hooks native methods that apps use to detect mock locations

MODDIR=${0%/*}/..
LOG_FILE="/data/local/tmp/hidemocklocation_native.log"

log_native() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] NativeHooks: $1" >> "$LOG_FILE"
}

log_native "Starting native library hooks"

# Create native library hooking system
create_native_hooks() {
    log_native "Creating native library hooks..."

    cat > /data/local/tmp/native_hooks.sh << 'EOF'
#!/system/bin/sh

# Native library hooking for mock location detection

# Method 1: Hook libc functions used for system property access
hook_libc_functions() {
    cat > /data/local/tmp/libc_hooks.c << 'C_EOF'
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

// Hook __system_property_get function
static int (*original_system_property_get)(const char* name, char* value) = NULL;

int __system_property_get(const char* name, char* value) {
    if (!original_system_property_get) {
        original_system_property_get = dlsym(RTLD_NEXT, "__system_property_get");
    }

    // Intercept mock location related properties
    if (name && (
        strcmp(name, "ro.allow.mock.location") == 0 ||
        strcmp(name, "persist.sys.mock_location") == 0 ||
        strcmp(name, "persist.vendor.mock_location") == 0 ||
        strcmp(name, "ro.debuggable") == 0)) {

        // Return fake values
        if (strcmp(name, "ro.debuggable") == 0) {
            strcpy(value, "0");
        } else {
            strcpy(value, "0");
        }
        return strlen(value);
    }

    return original_system_property_get(name, value);
}

// Hook property_get function (alternative name)
static int (*original_property_get)(const char* key, char* value, const char* default_value) = NULL;

int property_get(const char* key, char* value, const char* default_value) {
    if (!original_property_get) {
        original_property_get = dlsym(RTLD_NEXT, "property_get");
    }

    // Intercept mock location properties
    if (key && (
        strcmp(key, "ro.allow.mock.location") == 0 ||
        strcmp(key, "persist.sys.mock_location") == 0 ||
        strcmp(key, "ro.debuggable") == 0)) {

        strcpy(value, "0");
        return strlen(value);
    }

    return original_property_get(key, value, default_value);
}

// Hook fopen to intercept reading of system files
static FILE* (*original_fopen)(const char* filename, const char* mode) = NULL;

FILE* fopen(const char* filename, const char* mode) {
    if (!original_fopen) {
        original_fopen = dlsym(RTLD_NEXT, "fopen");
    }

    // Intercept access to build.prop and other system files
    if (filename && (
        strstr(filename, "build.prop") ||
        strstr(filename, "default.prop") ||
        strstr(filename, "/proc/version") ||
        strstr(filename, "/system/build.prop"))) {

        // Log the access attempt
        FILE* log = fopen("/data/local/tmp/file_access.log", "a");
        if (log) {
            fprintf(log, "Intercepted file access: %s\n", filename);
            fclose(log);
        }
    }

    return original_fopen(filename, mode);
}

C_EOF

    # Try to compile the native hook library
    if command -v clang >/dev/null 2>&1; then
        cd /data/local/tmp
        clang -shared -fPIC -o libc_hooks.so libc_hooks.c -ldl 2>/dev/null || {
            # Try with gcc if clang fails
            if command -v gcc >/dev/null 2>&1; then
                gcc -shared -fPIC -o libc_hooks.so libc_hooks.c -ldl 2>/dev/null || true
            fi
        }
    fi
}

# Method 2: Hook GPS-specific native functions
hook_gps_native_functions() {
    cat > /data/local/tmp/gps_native_hooks.c << 'GPS_C_EOF'
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

// Hook GPS HAL functions
typedef struct {
    int (*init)(void);
    int (*start)(void);
    int (*stop)(void);
    void (*cleanup)(void);
} gps_interface_t;

// Hook the GPS interface initialization
static gps_interface_t* (*original_gps_get_interface)(void) = NULL;

gps_interface_t* gps_get_interface(void) {
    if (!original_gps_get_interface) {
        original_gps_get_interface = dlsym(RTLD_NEXT, "gps_get_interface");
    }

    // Log GPS interface access
    FILE* log = fopen("/data/local/tmp/gps_interface.log", "a");
    if (log) {
        fprintf(log, "GPS interface accessed\n");
        fclose(log);
    }

    return original_gps_get_interface();
}

// Hook location callback functions
typedef void (*gps_location_callback)(void* location);
typedef void (*gps_status_callback)(void* status);

static void hooked_location_callback(void* location) {
    // Log location callback
    FILE* log = fopen("/data/local/tmp/gps_callbacks.log", "a");
    if (log) {
        fprintf(log, "Location callback intercepted\n");
        fclose(log);
    }
}

GPS_C_EOF

    # Compile GPS native hooks
    if command -v clang >/dev/null 2>&1; then
        cd /data/local/tmp
        clang -shared -fPIC -o gps_hooks.so gps_native_hooks.c -ldl 2>/dev/null || true
    fi
}

# Method 3: Hook JNI functions used by apps
hook_jni_functions() {
    cat > /data/local/tmp/jni_hooks.c << 'JNI_C_EOF'
#define _GNU_SOURCE
#include <jni.h>
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

// Hook JNI functions that apps might use to detect mock location

// Hook GetMethodID to intercept location-related method calls
static jmethodID (*original_GetMethodID)(JNIEnv* env, jclass clazz, const char* name, const char* sig) = NULL;

jmethodID GetMethodID(JNIEnv* env, jclass clazz, const char* name, const char* sig) {
    if (!original_GetMethodID) {
        original_GetMethodID = dlsym(RTLD_NEXT, "GetMethodID");
    }

    // Log method access for location-related methods
    if (name && (
        strcmp(name, "isFromMockProvider") == 0 ||
        strcmp(name, "isMock") == 0 ||
        strcmp(name, "getExtras") == 0)) {

        FILE* log = fopen("/data/local/tmp/jni_methods.log", "a");
        if (log) {
            fprintf(log, "JNI method accessed: %s\n", name);
            fclose(log);
        }
    }

    return original_GetMethodID(env, clazz, name, sig);
}

// Hook CallBooleanMethod to intercept boolean method calls
static jboolean (*original_CallBooleanMethod)(JNIEnv* env, jobject obj, jmethodID methodID, ...) = NULL;

jboolean CallBooleanMethod(JNIEnv* env, jobject obj, jmethodID methodID, ...) {
    // This is a simplified hook - in practice, you'd need to identify the method being called
    // and return false for mock location detection methods

    if (!original_CallBooleanMethod) {
        original_CallBooleanMethod = dlsym(RTLD_NEXT, "CallBooleanMethod");
    }

    va_list args;
    va_start(args, methodID);
    jboolean result = original_CallBooleanMethod(env, obj, methodID, args);
    va_end(args);

    return result;
}

JNI_C_EOF

    # Compile JNI hooks
    if command -v clang >/dev/null 2>&1; then
        cd /data/local/tmp
        clang -shared -fPIC -o jni_hooks.so jni_hooks.c -ldl 2>/dev/null || true
    fi
}

# Method 4: Create LD_PRELOAD setup for runtime hooking
setup_ld_preload() {
    cat > /data/local/tmp/setup_preload.sh << 'PRELOAD_EOF'
#!/system/bin/sh

# Setup LD_PRELOAD for runtime hooking

setup_preload_environment() {
    # Create directory for hook libraries
    mkdir -p /data/local/tmp/hooks

    # Copy hook libraries
    cp /data/local/tmp/*.so /data/local/tmp/hooks/ 2>/dev/null || true

    # Create LD_PRELOAD wrapper script
    cat > /data/local/tmp/app_wrapper.sh << 'WRAPPER_EOF'
#!/system/bin/sh

# Wrapper script to inject hooks into app processes

# Set LD_PRELOAD to load our hook libraries
export LD_PRELOAD="/data/local/tmp/hooks/libc_hooks.so:/data/local/tmp/hooks/gps_hooks.so:/data/local/tmp/hooks/jni_hooks.so:$LD_PRELOAD"

# Execute the original app
exec "$@"
WRAPPER_EOF

    chmod 755 /data/local/tmp/app_wrapper.sh
}

# Monitor app launches and inject hooks
monitor_app_launches() {
    while true; do
        # Look for new app processes
        for pid in $(pgrep -f "^/system/bin/app_process"); do
            if [ -d "/proc/$pid" ]; then
                # Try to inject hooks into the process
                echo "Found app process: $pid" >> /data/local/tmp/app_monitor.log
            fi
        done
        sleep 2
    done
}

setup_preload_environment
monitor_app_launches &

PRELOAD_EOF

    chmod 755 /data/local/tmp/setup_preload.sh
    /data/local/tmp/setup_preload.sh &
}

# Execute all native hooking methods
hook_libc_functions
hook_gps_native_functions
hook_jni_functions
setup_ld_preload

EOF

    chmod 755 /data/local/tmp/native_hooks.sh
    /data/local/tmp/native_hooks.sh &
}

# Method 5: Create binary patcher for existing libraries
create_binary_patcher() {
    log_native "Creating binary patcher for system libraries..."

    cat > /data/local/tmp/binary_patcher.sh << 'PATCH_EOF'
#!/system/bin/sh

# Binary patching for system libraries

patch_system_libraries() {
    # List of libraries that might contain location detection code
    LIBRARIES=(
        "/system/lib64/libbinder.so"
        "/system/lib/libbinder.so"
        "/system/lib64/libandroid_runtime.so"
        "/system/lib/libandroid_runtime.so"
        "/vendor/lib64/libril.so"
        "/vendor/lib/libril.so"
    )

    for lib in "${LIBRARIES[@]}"; do
        if [ -f "$lib" ]; then
            # Create backup
            cp "$lib" "${lib}.backup" 2>/dev/null || true

            # Log library found
            echo "Found library: $lib" >> /data/local/tmp/libraries.log

            # In a real implementation, you would use hexdump/xxd and sed
            # to patch specific bytes in the binary
        fi
    done
}

patch_system_libraries

PATCH_EOF

    chmod 755 /data/local/tmp/binary_patcher.sh
    /data/local/tmp/binary_patcher.sh
}

# Execute native hooks
create_native_hooks
create_binary_patcher

log_native "Native library hooks initialized"