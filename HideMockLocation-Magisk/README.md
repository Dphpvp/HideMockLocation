# HideMockLocation Universal - Magisk Module

A comprehensive systemless solution to hide mock location settings from applications on Android 9-16+.

## Features

### 🔧 Multi-Approach Implementation
1. **Framework Patching** - Direct bytecode modification of Android framework
2. **System File Replacement** - Systemless overlay of location-related system files
3. **Property Overrides** - System property modifications to hide mock location
4. **Runtime Hooks** - Dynamic hooking for real-time detection bypass

### 📱 Wide Compatibility
- **Android Versions**: 9, 10, 11, 12, 12L, 13, 14, 15, 16+
- **API Levels**: 28-35+ with future-proofing
- **OEM Support**: Samsung (Knox), Xiaomi (MIUI), Huawei (EMUI/HarmonyOS), OPPO/OnePlus, Google Pixel, Generic AOSP

### 🛡️ Advanced Detection Bypass
- Location class method hooking (`isFromMockProvider`, `isMock`, etc.)
- Settings provider modification
- Bundle extra filtering
- SELinux policy adjustments
- Privacy indicator bypass (Android 14+)
- Logcat filtering to prevent detection

## Installation

### Prerequisites
- Rooted Android device
- Magisk v20.4+ installed
- Unlocked bootloader

### Steps
1. Download the latest `HideMockLocation-Universal.zip` from releases
2. Open Magisk Manager
3. Navigate to Modules → Install from storage
4. Select the downloaded zip file
5. Reboot your device

## How It Works

### Framework Patching
The module applies version-specific patches to `framework.jar`:
- **Android 9-10**: Basic Location class modifications
- **Android 11-12**: APEX module support, enhanced privacy controls
- **Android 13-15**: Privacy indicators, permission manager integration
- **Android 16+**: Future-proof universal patches

### System Overlays
Systemless replacement of:
- `/system/etc/permissions/android.hardware.location.xml`
- `/system/etc/sysconfig/hidemocklocation.xml`
- Framework JARs with patched versions

### Runtime Protection
- Property monitoring and reset
- Dynamic hook maintenance
- App-specific bypass detection
- Background service monitoring

## Module Structure

```
HideMockLocation-Magisk/
├── module.prop                    # Module metadata
├── service.sh                     # Late-start service script
├── post-fs-data.sh               # Early boot script
├── uninstall.sh                  # Cleanup script
├── system.prop                   # System property overrides
├── sepolicy.rule                 # SELinux policy rules
├── system/                       # System file overlays
│   └── etc/
│       ├── permissions/
│       └── sysconfig/
├── tools/
│   └── smali_patcher.sh          # Framework patching utility
├── patches/
│   └── android_version_detector.sh # Version detection
└── META-INF/                     # Installation scripts
```

## Supported Methods

### Hooked Android APIs
- `android.location.Location`
  - `isFromMockProvider()`
  - `isMock()`
  - `setIsFromMockProvider()`
  - `setMock()`
  - `getExtras()` / `setExtras()`
  - `set()`

- `android.provider.Settings`
  - `Secure.getStringForUser("mock_location")`
  - `System.getStringForUser("mock_location")`
  - `Global.getStringForUser("mock_location")`
  - `NameValueCache.getStringForUser("mock_location")`

### System Properties
- `ro.allow.mock.location=0`
- `persist.sys.mock_location=0`
- `ro.debuggable=0`
- `ro.secure=1`

## OEM-Specific Support

### Samsung (Knox)
- Knox security framework bypass
- Secure folder compatibility
- Samsung Health location spoofing

### Xiaomi (MIUI)
- MIUI security center bypass
- Permission manager modifications
- Clone app support

### Huawei (EMUI/HarmonyOS)
- HMS location service patches
- EMUI security bypass
- HarmonyOS compatibility

### OPPO/OnePlus (ColorOS/OxygenOS)
- Clone app detection bypass
- ColorOS security modifications
- OxygenOS privacy controls

### Google Pixel
- Play Protect compatibility
- Pixel-specific security features
- Android update stability

## Testing

Test your installation with these apps:
- [MockLocationDetector](https://github.com/auag0/MockLocationDetector)
- Banking applications
- Pokemon GO / location-based games
- Navigation apps
- Food delivery apps

## Troubleshooting

### Common Issues

**Module not working after installation:**
1. Ensure Magisk v20.4+ is installed
2. Check if device is properly rooted
3. Verify Android version compatibility (9+)
4. Reboot device after installation

**Framework patching failed:**
1. Check device logs: `cat /data/local/tmp/hidemocklocation.log`
2. Verify available storage space
3. Ensure Java tools are accessible
4. Try disabling other framework-modifying modules

**App still detects mock location:**
1. Clear app data and cache
2. Restart the problematic app
3. Check if app uses alternative detection methods
4. Report compatibility issue with app name and version

### Logs
- Installation: Magisk Manager → Logs
- Runtime: `/data/local/tmp/hidemocklocation.log`
- Uninstall: `/data/local/tmp/hidemocklocation_uninstall.log`

## Compatibility Notes

### Working Applications
- Most banking apps
- Pokemon GO (with additional precautions)
- Food delivery apps (Uber Eats, DoorDash, etc.)
- Navigation apps (Google Maps, Waze)
- Social media location features

### Known Limitations
- Apps using hardware-level GPS verification
- Applications with server-side location validation
- Some advanced anti-cheat systems
- Real-time multiplayer location games

## Development

### Building from Source
1. Clone the repository
2. Modify version-specific patches in `tools/smali_patcher.sh`
3. Update compatibility matrix in `patches/android_version_detector.sh`
4. Test on target Android versions
5. Package as Magisk module zip

### Contributing
- Report compatibility issues
- Submit patches for new Android versions
- Add support for additional OEMs
- Improve detection bypass methods

## Disclaimer

This module is intended for legitimate privacy protection and testing purposes only. Users are responsible for complying with all applicable laws and terms of service. The developers are not responsible for any misuse or consequences resulting from the use of this module.

## Credits

- Original HideMockLocation by [auag0](https://github.com/auag0/HideMockLocation)
- Magisk by [topjohnwu](https://github.com/topjohnwu/Magisk)
- Android framework analysis community
- Beta testers and contributors

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- GitHub Issues: [Report problems](https://github.com/auag0/HideMockLocation/issues)
- XDA Thread: [Community discussion](https://xdaforums.com/)
- Telegram: [Support group](https://t.me/hidemocklocation)

---

**Version**: 2.0.0
**Last Updated**: September 2024
**Supported Android**: 9-16+
**Magisk Version**: 20.4+