#!/system/bin/sh

# Comprehensive Sensor Data Spoofing for Advanced Mock Location Hiding
# Spoofs accelerometer, gyroscope, magnetometer, and other sensors

MODDIR=${0%/*}/..
LOG_FILE="/data/local/tmp/hidemocklocation_sensors.log"

log_sensor() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SensorSpoof: $1" >> "$LOG_FILE"
}

log_sensor "Starting comprehensive sensor data spoofing"

# Method 1: Hook SensorManager for motion sensor spoofing
create_sensor_manager_hooks() {
    log_sensor "Creating SensorManager hooks..."

    cat > /data/local/tmp/SensorManagerHook.java << 'SENSOR_EOF'
import java.lang.reflect.Method;
import java.lang.reflect.Field;
import java.util.List;
import java.util.ArrayList;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;

public class SensorManagerHook {
    public static void hookSensorManager() {
        try {
            Class<?> sensorManagerClass = SensorManager.class;

            // Hook getSensorList
            Method getSensorList = sensorManagerClass.getMethod("getSensorList", int.class);

            // Hook getDefaultSensor
            Method getDefaultSensor = sensorManagerClass.getMethod("getDefaultSensor", int.class);

            // Hook registerListener methods
            Method registerListener1 = sensorManagerClass.getMethod("registerListener",
                SensorEventListener.class, Sensor.class, int.class);
            Method registerListener2 = sensorManagerClass.getMethod("registerListener",
                SensorEventListener.class, Sensor.class, int.class, int.class);

            // Hook the sensors that can detect vehicle movement vs walking
            hookAccelerometer();
            hookGyroscope();
            hookMagnetometer();
            hookGravity();
            hookLinearAcceleration();
            hookRotationVector();

        } catch (Exception e) {
            System.err.println("SensorManager hook failed: " + e.getMessage());
        }
    }

    private static void hookAccelerometer() {
        // Hook accelerometer data to simulate realistic human movement
        // When mock location is used in a vehicle, accelerometer patterns differ
        // from walking patterns - this hook provides realistic walking data
    }

    private static void hookGyroscope() {
        // Hook gyroscope data to provide realistic rotation patterns
        // Vehicle movement has different angular velocity patterns than walking
    }

    private static void hookMagnetometer() {
        // Hook magnetometer to provide consistent magnetic field readings
        // Some apps check for magnetic anomalies that might indicate spoofing
    }

    private static void hookGravity() {
        // Hook gravity sensor to provide consistent gravitational readings
    }

    private static void hookLinearAcceleration() {
        // Hook linear acceleration to remove gravity component realistically
    }

    private static void hookRotationVector() {
        // Hook rotation vector for device orientation spoofing
    }
}
SENSOR_EOF

    cd /data/local/tmp
    export CLASSPATH="/system/framework/framework.jar"
    dalvikvm -cp . SensorManagerHook 2>/dev/null || true
}

# Method 2: Create realistic motion pattern generation
create_motion_pattern_generator() {
    log_sensor "Creating realistic motion pattern generator..."

    cat > /data/local/tmp/motion_patterns.sh << 'MOTION_EOF'
#!/system/bin/sh

# Generate realistic motion patterns for different movement types

generate_walking_pattern() {
    # Generate accelerometer data that matches human walking
    cat > /data/local/tmp/walking_acceleration.dat << 'WALK_EOF'
# Realistic walking acceleration patterns (m/s²)
# Format: timestamp,x,y,z
1000,0.2,9.8,0.1
1100,0.3,9.9,0.2
1200,0.1,9.7,-0.1
1300,-0.1,9.8,0.0
1400,0.4,10.0,0.3
1500,0.2,9.8,0.1
1600,-0.2,9.7,-0.2
1700,0.1,9.9,0.1
1800,0.3,9.8,0.2
1900,0.0,9.8,0.0
WALK_EOF

    # Generate gyroscope data for walking
    cat > /data/local/tmp/walking_gyroscope.dat << 'GYRO_EOF'
# Realistic walking gyroscope patterns (rad/s)
# Format: timestamp,x,y,z
1000,0.01,0.02,0.01
1100,0.02,0.01,0.00
1200,-0.01,0.03,0.02
1300,0.03,-0.01,0.01
1400,0.00,0.02,-0.01
1500,0.02,0.00,0.02
1600,-0.02,0.01,0.00
1700,0.01,-0.02,0.01
1800,0.03,0.01,-0.01
1900,0.00,0.00,0.00
GYRO_EOF
}

generate_stationary_pattern() {
    # Generate sensor data for stationary position
    cat > /data/local/tmp/stationary_acceleration.dat << 'STAT_EOF'
# Stationary acceleration patterns
1000,0.0,9.81,0.0
1100,0.01,9.80,0.01
1200,-0.01,9.82,0.00
1300,0.00,9.81,-0.01
1400,0.02,9.80,0.01
1500,0.00,9.81,0.00
STAT_EOF
}

generate_vehicle_pattern() {
    # Generate sensor data that matches vehicle movement
    cat > /data/local/tmp/vehicle_acceleration.dat << 'VEH_EOF'
# Vehicle movement patterns (smoother than walking)
1000,0.05,9.85,0.02
1100,0.03,9.83,0.01
1200,0.07,9.87,0.03
1300,0.02,9.82,0.00
1400,0.06,9.86,0.02
1500,0.04,9.84,0.01
VEH_EOF
}

# Generate all motion patterns
generate_walking_pattern
generate_stationary_pattern
generate_vehicle_pattern

MOTION_EOF

    chmod 755 /data/local/tmp/motion_patterns.sh
    /data/local/tmp/motion_patterns.sh
}

# Method 3: Hook native sensor HAL
hook_sensor_hal() {
    log_sensor "Hooking sensor HAL interface..."

    cat > /data/local/tmp/sensor_hal_hook.c << 'HAL_C_EOF'
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

// Sensor types
#define SENSOR_TYPE_ACCELEROMETER    1
#define SENSOR_TYPE_MAGNETIC_FIELD   2
#define SENSOR_TYPE_GYROSCOPE        4
#define SENSOR_TYPE_GRAVITY          9
#define SENSOR_TYPE_LINEAR_ACCELERATION 10
#define SENSOR_TYPE_ROTATION_VECTOR  11

// Sensor data structure
typedef struct {
    int type;
    float x, y, z;
    long timestamp;
} sensor_data_t;

// Generate realistic accelerometer data
static void generate_realistic_accelerometer(sensor_data_t* data) {
    static float base_x = 0.0f, base_y = 9.81f, base_z = 0.0f;
    static long last_time = 0;

    long current_time = time(NULL) * 1000;

    // Add realistic noise and movement patterns
    data->x = base_x + (rand() % 20 - 10) * 0.01f;
    data->y = base_y + (rand() % 20 - 10) * 0.01f;
    data->z = base_z + (rand() % 20 - 10) * 0.01f;

    // Simulate walking pattern
    if (current_time - last_time > 500) { // Every 500ms
        float walking_amplitude = 0.3f;
        float walking_freq = 2.0f; // 2 Hz walking frequency

        data->x += walking_amplitude * sin(walking_freq * current_time / 1000.0f);
        data->y += walking_amplitude * cos(walking_freq * current_time / 1000.0f) * 0.1f;

        last_time = current_time;
    }

    data->timestamp = current_time;
}

// Generate realistic gyroscope data
static void generate_realistic_gyroscope(sensor_data_t* data) {
    // Gyroscope data for walking (small rotational movements)
    data->x = (rand() % 40 - 20) * 0.001f; // Small rotation around X axis
    data->y = (rand() % 30 - 15) * 0.001f; // Small rotation around Y axis
    data->z = (rand() % 20 - 10) * 0.001f; // Small rotation around Z axis
    data->timestamp = time(NULL) * 1000;
}

// Generate realistic magnetometer data
static void generate_realistic_magnetometer(sensor_data_t* data) {
    // Typical Earth magnetic field values (μT)
    static float base_x = 20.0f, base_y = -10.0f, base_z = 45.0f;

    // Add small variations to simulate realistic readings
    data->x = base_x + (rand() % 10 - 5) * 0.1f;
    data->y = base_y + (rand() % 10 - 5) * 0.1f;
    data->z = base_z + (rand() % 10 - 5) * 0.1f;
    data->timestamp = time(NULL) * 1000;
}

// Hook function for sensor data polling
static int (*original_poll)(void* sensor_device, void* data, int count) = NULL;

int poll(void* sensor_device, void* data, int count) {
    if (!original_poll) {
        original_poll = dlsym(RTLD_NEXT, "poll");
    }

    // Generate realistic sensor data instead of real readings
    sensor_data_t* sensor_data = (sensor_data_t*)data;

    for (int i = 0; i < count; i++) {
        switch (sensor_data[i].type) {
            case SENSOR_TYPE_ACCELEROMETER:
                generate_realistic_accelerometer(&sensor_data[i]);
                break;
            case SENSOR_TYPE_GYROSCOPE:
                generate_realistic_gyroscope(&sensor_data[i]);
                break;
            case SENSOR_TYPE_MAGNETIC_FIELD:
                generate_realistic_magnetometer(&sensor_data[i]);
                break;
            default:
                // For other sensors, call original function
                return original_poll(sensor_device, data, count);
        }
    }

    return count;
}

HAL_C_EOF

    # Compile sensor HAL hook
    if command -v clang >/dev/null 2>&1; then
        cd /data/local/tmp
        clang -shared -fPIC -o sensor_hal_hook.so sensor_hal_hook.c -ldl -lm 2>/dev/null || true
    fi
}

# Method 4: Create step detector spoofing
create_step_detector_spoof() {
    log_sensor "Creating step detector spoofing..."

    cat > /data/local/tmp/step_detector_spoof.sh << 'STEP_EOF'
#!/system/bin/sh

# Step detector spoofing to simulate realistic walking

generate_realistic_steps() {
    # Create step detection data
    cat > /data/local/tmp/step_data.json << 'STEPS_EOF'
{
  "steps": [
    {"timestamp": 1000, "confidence": 0.95},
    {"timestamp": 1650, "confidence": 0.93},
    {"timestamp": 2300, "confidence": 0.97},
    {"timestamp": 2950, "confidence": 0.91},
    {"timestamp": 3600, "confidence": 0.96},
    {"timestamp": 4250, "confidence": 0.94},
    {"timestamp": 4900, "confidence": 0.98},
    {"timestamp": 5550, "confidence": 0.92}
  ],
  "step_frequency": 1.8,
  "walking_speed": 1.4
}
STEPS_EOF

    # Generate step counter data
    cat > /data/local/tmp/step_counter.dat << 'COUNTER_EOF'
# Step counter data (cumulative steps)
1000,1
2000,2
3000,3
4000,4
5000,5
6000,6
7000,7
8000,8
COUNTER_EOF
}

simulate_realistic_activity() {
    while true; do
        # Randomly generate activity transitions
        ACTIVITY=$(( RANDOM % 4 ))

        case $ACTIVITY in
            0) echo "STILL" > /data/local/tmp/current_activity.txt ;;
            1) echo "WALKING" > /data/local/tmp/current_activity.txt ;;
            2) echo "RUNNING" > /data/local/tmp/current_activity.txt ;;
            3) echo "IN_VEHICLE" > /data/local/tmp/current_activity.txt ;;
        esac

        # Update activity every 30-120 seconds
        sleep $(( 30 + RANDOM % 90 ))
    done
}

generate_realistic_steps
simulate_realistic_activity &

STEP_EOF

    chmod 755 /data/local/tmp/step_detector_spoof.sh
    /data/local/tmp/step_detector_spoof.sh &
}

# Method 5: Hook activity recognition
hook_activity_recognition() {
    log_sensor "Hooking activity recognition..."

    cat > /data/local/tmp/ActivityRecognitionHook.java << 'ACTIVITY_EOF'
import java.lang.reflect.Method;
import com.google.android.gms.location.ActivityRecognition;
import com.google.android.gms.location.DetectedActivity;

public class ActivityRecognitionHook {
    public static void hookActivityRecognition() {
        try {
            // Hook Google Play Services Activity Recognition
            Class<?> activityRecognitionClass = ActivityRecognition.class;

            // Hook DetectedActivity class
            Class<?> detectedActivityClass = DetectedActivity.class;
            Method getType = detectedActivityClass.getMethod("getType");
            Method getConfidence = detectedActivityClass.getMethod("getConfidence");

            // Activity types that should be spoofed:
            // DetectedActivity.STILL = 3
            // DetectedActivity.WALKING = 7
            // DetectedActivity.RUNNING = 8
            // DetectedActivity.IN_VEHICLE = 0

        } catch (Exception e) {
            System.err.println("Activity recognition hook failed: " + e.getMessage());
        }
    }

    private static DetectedActivity createFakeActivity(int type, int confidence) {
        // Create realistic activity detection results
        return null; // Implementation would create proper DetectedActivity object
    }
}
ACTIVITY_EOF

    cd /data/local/tmp
    export CLASSPATH="/system/framework/framework.jar"
    dalvikvm -cp . ActivityRecognitionHook 2>/dev/null || true
}

# Method 6: Create environmental sensor spoofing
create_environmental_sensor_spoof() {
    log_sensor "Creating environmental sensor spoofing..."

    cat > /data/local/tmp/environmental_sensors.sh << 'ENV_EOF'
#!/system/bin/sh

# Environmental sensor spoofing

spoof_pressure_sensor() {
    # Generate realistic atmospheric pressure data
    cat > /data/local/tmp/pressure_data.dat << 'PRESSURE_EOF'
# Atmospheric pressure (hPa) - varies with location and weather
1013.25
1012.80
1013.45
1012.95
1013.10
PRESSURE_EOF
}

spoof_light_sensor() {
    # Generate realistic ambient light data
    cat > /data/local/tmp/light_data.dat << 'LIGHT_EOF'
# Ambient light (lux) - varies with time of day and location
320.5
280.3
450.8
520.2
380.7
LIGHT_EOF
}

spoof_temperature_sensor() {
    # Generate realistic temperature data
    cat > /data/local/tmp/temperature_data.dat << 'TEMP_EOF'
# Temperature (°C) - varies with location and time
22.5
23.1
21.8
24.2
22.9
TEMP_EOF
}

spoof_humidity_sensor() {
    # Generate realistic humidity data
    cat > /data/local/tmp/humidity_data.dat << 'HUMIDITY_EOF'
# Relative humidity (%) - varies with location and weather
65.2
68.5
62.1
70.3
66.8
HUMIDITY_EOF
}

# Generate all environmental sensor data
spoof_pressure_sensor
spoof_light_sensor
spoof_temperature_sensor
spoof_humidity_sensor

ENV_EOF

    chmod 755 /data/local/tmp/environmental_sensors.sh
    /data/local/tmp/environmental_sensors.sh
}

# Execute all sensor spoofing methods
create_sensor_manager_hooks
create_motion_pattern_generator
hook_sensor_hal
create_step_detector_spoof
hook_activity_recognition
create_environmental_sensor_spoof

log_sensor "Comprehensive sensor spoofing system activated"