#!/bin/bash
set -e

echo "🔨 Compilando 3Tap em modo Release..."
swift build -c release

APP_NAME="3Tap.app"
BUILD_DIR=".build/release"
EXEC_PATH="$BUILD_DIR/3Tap"

echo "📦 Criando pacote $APP_NAME..."
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

cp "$EXEC_PATH" "$APP_NAME/Contents/MacOS/3Tap"
cp "Resources/Info.plist" "$APP_NAME/Contents/Info.plist"

echo "🔏 Assinando bundle $APP_NAME..."
codesign --force --deep --sign - "$APP_NAME"

echo "✅ Build concluído com sucesso! $APP_NAME está pronto."
