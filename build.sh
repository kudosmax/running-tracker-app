#!/bin/bash

set -e

echo "Starting Flutter build process..."
echo "Current directory: $(pwd)"
echo "Available files:"
ls -la

# Store the project directory
PROJECT_DIR=$(pwd)

# Ensure we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found in $(pwd)"
    echo "Looking for Flutter project..."
    find . -name "pubspec.yaml" -type f | head -5
    exit 1
fi

# Install Flutter
echo "Installing Flutter..."
cd /tmp

# Detect OS and download appropriate Flutter version
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux, downloading Flutter for Linux..."
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz | tar -xJ
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS, downloading Flutter for macOS..."
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.zip -o flutter.zip
    unzip -q flutter.zip
    rm flutter.zip
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

# Add Flutter to PATH
export PATH="/tmp/flutter/bin:$PATH"

# Return to project directory
cd "$PROJECT_DIR"

# Configure Flutter
echo "Configuring Flutter..."
flutter config --enable-web --no-analytics

echo "Flutter doctor check:"
flutter doctor || true

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build the web app
echo "Building Flutter web app..."
flutter build web --web-renderer html --release

echo "Build completed successfully!"
if [ -d "build/web" ]; then
    echo "Build output directory contents:"
    ls -la build/web/
else
    echo "Error: build/web directory not found"
    exit 1
fi