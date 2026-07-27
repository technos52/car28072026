# iOS Build Guide for Car Dealer App

## Prerequisites (Required on macOS)

1. **macOS** (iOS builds can only be done on macOS)
2. **Xcode** (latest version from App Store)
3. **Apple Developer Account** (for distribution)
4. **Flutter SDK** (already configured)

## Current Project Status

✅ Flutter project is properly configured
✅ iOS folder structure exists
✅ Dependencies are compatible with iOS
✅ Firebase integration is set up

## Step-by-Step iOS Build Process

### 1. Verify Flutter iOS Setup (on macOS)

```bash
flutter doctor
```

Ensure you see:
- ✅ Flutter
- ✅ Xcode - develop for iOS and macOS
- ✅ iOS toolchain

### 2. Clean and Prepare Project

```bash
flutter clean
flutter pub get
```

### 3. iOS Configuration

#### Bundle Identifier Setup
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project → Runner target
3. Set a unique Bundle Identifier (e.g., `com.yourcompany.cardealer`)
4. Configure signing with your Apple Developer account

#### Required iOS Permissions
Your app uses several features that require permissions. Add these to `ios/Runner/Info.plist`:

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos of cars</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select car images</string>

<!-- Location Permission (if needed) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearby dealers</string>

<!-- Push Notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### 4. Firebase iOS Configuration

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` folder in Xcode
3. Ensure it's added to the Runner target

### 5. Build Commands

#### Debug Build (for testing)
```bash
flutter build ios --debug
```

#### Release Build (for App Store)
```bash
flutter build ios --release
```

#### Build and Run on Simulator
```bash
flutter run -d ios
```

#### Build for Device
```bash
flutter run -d [device-id]
```

### 6. Archive for App Store

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Upload to App Store Connect

## Build Configurations

### Development Build
- Use for testing on devices/simulators
- Includes debug symbols
- Larger file size

### Release Build  
- Optimized for production
- Smaller file size
- Required for App Store submission

## Troubleshooting Common Issues

### CocoaPods Issues
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### Signing Issues
- Ensure Apple Developer account is properly configured
- Check Bundle Identifier is unique
- Verify provisioning profiles

### Build Errors
- Check Xcode version compatibility
- Update iOS deployment target if needed
- Resolve any Swift/Objective-C compilation errors

## App Store Submission Checklist

- [ ] Bundle Identifier configured
- [ ] App icons added (all required sizes)
- [ ] Launch screen configured
- [ ] Privacy permissions descriptions added
- [ ] Firebase configuration added
- [ ] Release build tested
- [ ] App Store metadata prepared
- [ ] Screenshots prepared

## Next Steps When You Have macOS Access

1. Transfer this project to a Mac
2. Install Xcode and Flutter
3. Follow the build process above
4. Test on iOS Simulator
5. Test on physical iOS device
6. Submit to App Store

## Current Dependencies That Support iOS

✅ All your current dependencies support iOS:
- Firebase (Core, Auth, Firestore, Storage, Messaging)
- Google Sign In
- Sign in with Apple
- Image Picker
- File Picker
- Local Notifications
- URL Launcher
- And all other dependencies

Your project is ready for iOS building once you have access to macOS and Xcode!