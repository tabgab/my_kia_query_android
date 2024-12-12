# MyKia Query

A Flutter application for monitoring Kia and Hyundai vehicles, providing real-time vehicle status and information through official manufacturer APIs.

## Features

### Authentication & Security // Tested: KIA / EU / With EV
- Multi-region support (Europe, Canada, USA)
- Multi-brand support (Kia, Hyundai)
- Secure credential storage
- Biometric authentication
- PIN-based security fallback
- Automatic token refresh

### Home Screen Widgets
- Text Widget: Simple 12V battery level display
  - Configurable text size and colors
  - One-tap refresh
  - Settings configuration
- Graphical Battery Widget: Visual battery status representation
  - Dynamic battery level indicator
  - Centered percentage display
  - Warning indicator for low battery levels
  - Visual scaling based on battery percentage
  - One-tap refresh functionality

### Vehicle Monitoring / Some of these are not reliable yet.
- Vehicle status updates - not realtime, we use a saved state from the cloud. 
- Location tracking with Google Maps integration
- Comprehensive vehicle information:
  - Battery status and charging information (EV)
  - Door lock status
  - Climate control status
  - Engine status
  - Odometer readings
  - Range information
  - Temperature readings
  - Tire pressure monitoring
  - Defrost status
  - Steering wheel heat status

### EV-Specific Features
- Battery charge level
- Charging status
- Estimated range
- Remaining charging time
- Plug status
- Energy consumption data:
  - Current drive
  - Since last charge
  - Since last reset

## Testing Status

### Tested Configurations
- Region: Europe
- Brand: KIA
- Vehicle Type: Electric Vehicle (EV)
- Authentication: Username/Password + PIN
- Biometric: Android fingerprint authentication

### Known Limitations
- Vehicle status is based on cached cloud data, not real-time updates
- Some vehicle monitoring features may be unreliable or unavailable depending on vehicle model and region
- API response times may vary based on server load and network conditions
- Feature availability varies by region and vehicle model

## Technical Architecture

### Frontend (Flutter)
- Material Design UI
- Provider pattern for state management
- Secure credential storage using flutter_secure_storage
- Local authentication with biometric support
- Shared preferences for user settings

### Android Widgets
- Native Kotlin implementation
- Support for both text and graphical displays
- Shared vehicle data service
- Configurable appearance and behavior

### Backend Bridge (Python)
- Integration with hyundai_kia_connect_api
- Real-time data fetching and formatting
- Error handling and offline fallbacks
- Secure token management

## Setup

### Prerequisites
- Flutter SDK
- Android Studio / Xcode
- Python 3.x
- Required Python packages (see requirements.txt)

### Installation

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Install Python dependencies:
```bash
cd android/app/src/main/python
pip install -r requirements.txt
```

4. Configure your IDE:
- Set up Flutter and Dart plugins
- Configure Python interpreter

### Building

For Android:
```bash
flutter build apk
```

For iOS:
```bash
flutter build ios
```

## Usage

1. Launch the app
2. Log in with your Kia/Hyundai account credentials
3. Optional: Set up biometric authentication or PIN for secure access
4. View your vehicle's status information (cached from cloud)
5. Use the refresh button to update vehicle data
6. Click on the location to open Google Maps
7. Add widgets to your home screen:
   - Choose "12V Battery (Text)" for a simple text display
   - Choose "12V Battery (Graphical)" for a visual battery representation

## Security Considerations

- Credentials are securely stored using platform-specific encryption
- Biometric authentication uses system-level security
- PIN provides a secure fallback authentication method
- Tokens are automatically refreshed and securely managed
- All API communications use secure HTTPS connections

## Dependencies

### Flutter Packages
- provider: State management
- flutter_secure_storage: Secure credential storage
- local_auth: Biometric authentication
- shared_preferences: User settings storage
- url_launcher: External map integration
- json_annotation: JSON serialization

### Python Packages
- hyundai_kia_connect_api: Official API integration
- requests: HTTP client
- urllib3: HTTP client library
- certifi: Certificate validation
- charset-normalizer: Character encoding
- six: Python 2/3 compatibility

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

Do whatever you want. Adhere to the original hyundai_kia_connect license restrictions though, as we use that to connect to the vehicle.

## Acknowledgments

- Thanks to the hyundai_kia_connect_api library maintainers
- Flutter and Dart teams for the framework
