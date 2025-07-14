#!/bin/bash

set -e

# Install Flutter if not already installed
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    
    # Download and install Flutter
    cd /tmp
    curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION:-3.24.0}-stable.tar.xz
    tar xf flutter_linux_${FLUTTER_VERSION:-3.24.0}-stable.tar.xz
    
    # Add Flutter to PATH
    export PATH="/tmp/flutter/bin:$PATH"
    
    # Configure Flutter
    flutter config --enable-web
    flutter doctor
else
    echo "Flutter is already installed"
    export PATH="/tmp/flutter/bin:$PATH"
fi

# Return to project directory
cd "$NETLIFY_BUILD_BASE"

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build the web app
echo "Building Flutter web app..."
flutter build web --web-renderer html --release

echo "Build completed successfully!"