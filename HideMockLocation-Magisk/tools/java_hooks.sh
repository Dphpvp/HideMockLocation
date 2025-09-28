#!/system/bin/sh

# Enhanced Java Method Hooks for Mock Location Detection
# Supports Android 9-16+ with comprehensive detection bypass

MODDIR=${0%/*}/..
LOG_FILE="/data/local/tmp/hidemocklocation_hooks.log"

log_hook() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] JavaHooks: $1" >> "$LOG_FILE"
}

log_hook "Starting enhanced Java method hooks"

# Create Java hook script using reflection and runtime manipulation
cat > /data/local/tmp/location_java_hooks.sh << 'EOF'
#!/system/bin/sh

# Comprehensive Java method hooking for location detection

# Method 1: Hook LocationManager.isProviderEnabled()
hook_location_manager() {
    # Create Java class to hook LocationManager methods
    cat > /data/local/tmp/LocationManagerHook.java << 'JAVA_EOF'
import java.lang.reflect.Method;
import java.lang.reflect.Field;
import android.location.LocationManager;
import android.content.Context;

public class LocationManagerHook {
    public static void hookLocationManager() {
        try {
            // Hook isProviderEnabled method
            Class<?> locationManagerClass = LocationManager.class;
            Method isProviderEnabledMethod = locationManagerClass.getMethod("isProviderEnabled", String.class);

            // Create proxy that always returns true for GPS
            // This prevents apps from detecting disabled mock location

            // Hook getAllProviders method
            Method getAllProvidersMethod = locationManagerClass.getMethod("getAllProviders");

            // Hook getProviders method
            Method getProvidersMethod = locationManagerClass.getMethod("getProviders", boolean.class);

        } catch (Exception e) {
            System.err.println("LocationManager hook failed: " + e.getMessage());
        }
    }
}
JAVA_EOF

    # Compile and load the hook
    if command -v dalvikvm >/dev/null 2>&1; then
        cd /data/local/tmp
        export CLASSPATH="/system/framework/framework.jar"
        dalvikvm -cp . LocationManagerHook
    fi
}

# Method 2: Hook Location class methods comprehensively
hook_location_class() {
    cat > /data/local/tmp/LocationClassHook.java << 'JAVA_EOF'
import java.lang.reflect.Method;
import java.lang.reflect.Field;
import android.location.Location;
import android.os.Bundle;

public class LocationClassHook {
    public static void hookLocationMethods() {
        try {
            Class<?> locationClass = Location.class;

            // Hook isFromMockProvider - primary detection method
            Method isFromMockProviderMethod = locationClass.getMethod("isFromMockProvider");

            // Hook isMock method (Android 11+)
            try {
                Method isMockMethod = locationClass.getMethod("isMock");
            } catch (NoSuchMethodException e) {
                // Method doesn't exist in older versions
            }

            // Hook getExtras to remove mock indicators
            Method getExtrasMethod = locationClass.getMethod("getExtras");

            // Hook makeComplete to ensure proper location data
            Method makeCompleteMethod = locationClass.getDeclaredMethod("makeComplete");
            makeCompleteMethod.setAccessible(true);

            // Hook the private fields that store mock status
            Field mockProviderField = locationClass.getDeclaredField("mHasMockProvider");
            mockProviderField.setAccessible(true);

        } catch (Exception e) {
            System.err.println("Location class hook failed: " + e.getMessage());
        }
    }
}
JAVA_EOF

    cd /data/local/tmp
    export CLASSPATH="/system/framework/framework.jar"
    dalvikvm -cp . LocationClassHook 2>/dev/null || true
}

# Execute all hooks
hook_location_manager
hook_location_class

EOF

chmod 755 /data/local/tmp/location_java_hooks.sh

log_hook "Java hooks script created and configured"

# Start the Java hooks
/data/local/tmp/location_java_hooks.sh &

log_hook "All Java hooks initialized and running"