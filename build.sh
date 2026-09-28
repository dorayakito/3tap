#!/bin/bash
set -e

# Find suitable macOS SDK
SDK_PATH=""
for sdk in "/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk" "/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk" "/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk"; do
    if [ -d "$sdk" ]; then
        SDK_PATH="$sdk"
        break
    fi
done

if [ -z "$SDK_PATH" ]; then
    SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null || true)
fi

echo "🔨 Compilando CMultitouch..."
clang -c Sources/CMultitouch/CMultitouch.m -I Sources/CMultitouch/include -F /System/Library/PrivateFrameworks -o CMultitouch.o

echo "🔨 Compilando 3Tap em modo Release usando SDK em $SDK_PATH..."
swiftc -sdk "$SDK_PATH" -O -I Sources/CMultitouch/include Sources/3Tap/*.swift CMultitouch.o \
    -framework Cocoa -framework CoreGraphics -framework ServiceManagement \
    -F /System/Library/PrivateFrameworks -framework MultitouchSupport \
    -o 3Tap_bin

APP_NAME="3Tap.app"

echo "📦 Criando pacote $APP_NAME..."
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

cp 3Tap_bin "$APP_NAME/Contents/MacOS/3Tap"
cp "Resources/Info.plist" "$APP_NAME/Contents/Info.plist"

echo "🔏 Assinando bundle $APP_NAME..."
codesign --force --deep --sign - "$APP_NAME"

rm -f CMultitouch.o 3Tap_bin

echo "✅ Build concluído com sucesso! $APP_NAME está pronto."
