#!/bin/bash
set -e

APP_NAME="3Tap.app"

find_working_sdk() {
    local candidates=()
    if command -v xcrun >/dev/null 2>&1; then
        local xc_sdk
        xc_sdk=$(xcrun --show-sdk-path 2>/dev/null || true)
        if [ -n "$xc_sdk" ] && [ -d "$xc_sdk" ]; then
            candidates+=("$xc_sdk")
        fi
    fi
    candidates+=(
        "/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk"
        "/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk"
        "/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk"
        "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
    )

    for sdk in "${candidates[@]}"; do
        if [ -d "$sdk" ]; then
            if echo 'import Cocoa' | swiftc -sdk "$sdk" - -typecheck 2>/dev/null; then
                echo "$sdk"
                return 0
            fi
        fi
    done

    if [ ${#candidates[@]} -gt 0 ]; then
        echo "${candidates[0]}"
    fi
}

SDK_PATH=$(find_working_sdk)
echo "🔨 SDK selecionado: ${SDK_PATH:-Padrão do Sistema}"

# Compilar CMultitouch
SYSROOT_FLAG=""
SDK_FLAG=""
PRIVATE_FW_FLAGS="-F /System/Library/PrivateFrameworks"

if [ -n "$SDK_PATH" ] && [ -d "$SDK_PATH" ]; then
    SYSROOT_FLAG="-isysroot $SDK_PATH"
    SDK_FLAG="-sdk $SDK_PATH"
    if [ -d "$SDK_PATH/System/Library/PrivateFrameworks" ]; then
        PRIVATE_FW_FLAGS="$PRIVATE_FW_FLAGS -F $SDK_PATH/System/Library/PrivateFrameworks"
    fi
fi

echo "🔨 Compilando CMultitouch..."
clang $SYSROOT_FLAG -c Sources/CMultitouch/CMultitouch.m -I Sources/CMultitouch/include $PRIVATE_FW_FLAGS -o CMultitouch.o

echo "🔨 Compilando 3Tap em modo Release..."
swiftc $SDK_FLAG -O -I Sources/CMultitouch/include Sources/3Tap/*.swift CMultitouch.o \
    -framework Cocoa -framework CoreGraphics -framework ServiceManagement \
    $PRIVATE_FW_FLAGS -framework MultitouchSupport \
    -o 3Tap_bin

echo "📦 Criando pacote $APP_NAME..."
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

cp 3Tap_bin "$APP_NAME/Contents/MacOS/3Tap"
cp "Resources/Info.plist" "$APP_NAME/Contents/Info.plist"

echo "🔏 Assinando bundle $APP_NAME..."
codesign --force --deep --sign - "$APP_NAME" 2>/dev/null || true

rm -f CMultitouch.o 3Tap_bin

echo "✅ Build concluído com sucesso! $APP_NAME está pronto."
