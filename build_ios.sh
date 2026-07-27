#!/bin/bash

# iOS Build Script for Car Dealer App
# Run this script on macOS with Xcode installed

echo "🚗 Car Dealer iOS Build Script"
echo "================================"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS builds require macOS"
    exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter not found. Please install Flutter first."
    exit 1
fi

# Check Xcode installation
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode not found. Please install Xcode from App Store."
    exit 1
fi

echo "✅ Environment checks passed"

# Clean and prepare
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Update CocoaPods
echo "🍫 Updating CocoaPods..."
cd ios
pod install --repo-update
cd ..

# Check Flutter doctor
echo "🔍 Checking Flutter setup..."
flutter doctor

# Build options
echo ""
echo "Choose build type:"
echo "1) Debug build (for testing)"
echo "2) Release build (for App Store)"
echo "3) Run on simulator"
echo "4) Run on device"

read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo "🔨 Building iOS debug..."
        flutter build ios --debug
        ;;
    2)
        echo "🔨 Building iOS release..."
        flutter build ios --release
        echo "📱 Open ios/Runner.xcworkspace in Xcode to archive for App Store"
        ;;
    3)
        echo "📱 Running on iOS simulator..."
        flutter run -d ios
        ;;
    4)
        echo "📱 Available devices:"
        flutter devices
        read -p "Enter device ID: " device_id
        flutter run -d "$device_id"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo "✅ iOS build process completed!"