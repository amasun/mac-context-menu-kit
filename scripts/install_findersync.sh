#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$ROOT_DIR/modules/copy-path/CopyPathFinder"

UNIVERSAL=false
if [[ "${1:-}" == "--universal" ]]; then
    UNIVERSAL=true
fi

if ! command -v swiftc >/dev/null 2>&1; then
    echo "❌ 未检测到 swiftc（Xcode Command Line Tools）。"
    echo "   请先运行以下命令安装基础编译工具，或改用零依赖的 workflow 模式："
    echo "   xcode-select --install"
    exit 1
fi

SDK_PATH="$(xcrun --show-sdk-path 2>/dev/null || true)"
if [[ -z "$SDK_PATH" || ! -d "$SDK_PATH" ]]; then
    echo "❌ 未找到 macOS SDK，请运行 xcode-select --install 后重试。"
    exit 1
fi

BUILD_DIR="$ROOT_DIR/build"
APP_BUNDLE="$BUILD_DIR/CopyPathFinder.app"
APPEX_BUNDLE="$APP_BUNDLE/Contents/PlugIns/CopyPathFinderExtension.appex"
INSTALL_APP="/Applications/CopyPathFinder.app"

rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APPEX_BUNDLE/Contents/MacOS"

compile_host() {
    local arch="$1"
    local out="$2"
    swiftc \
        -parse-as-library \
        -target "${arch}-apple-macosx13.0" \
        -sdk "$SDK_PATH" \
        -framework Cocoa \
        -framework FinderSync \
        "$SRC_DIR/HostApp/main.swift" \
        -o "$out"
}

compile_ext() {
    local arch="$1"
    local out="$2"
    swiftc \
        -parse-as-library \
        -module-name CopyPathFinderExtension \
        -target "${arch}-apple-macosx13.0" \
        -sdk "$SDK_PATH" \
        -application-extension \
        -framework Cocoa \
        -framework FinderSync \
        -Xlinker -e -Xlinker _NSExtensionMain \
        "$SRC_DIR/Extension/FinderSync.swift" \
        -o "$out"
}

echo "🔨 编译宿主应用与 FinderSync 扩展..."
if [[ "$UNIVERSAL" == true ]]; then
    compile_host "arm64" "$BUILD_DIR/CopyPathFinder-arm64"
    compile_host "x86_64" "$BUILD_DIR/CopyPathFinder-x86_64"
    lipo -create "$BUILD_DIR/CopyPathFinder-arm64" "$BUILD_DIR/CopyPathFinder-x86_64" -output "$APP_BUNDLE/Contents/MacOS/CopyPathFinder"

    compile_ext "arm64" "$BUILD_DIR/CopyPathFinderExtension-arm64"
    compile_ext "x86_64" "$BUILD_DIR/CopyPathFinderExtension-x86_64"
    lipo -create "$BUILD_DIR/CopyPathFinderExtension-arm64" "$BUILD_DIR/CopyPathFinderExtension-x86_64" -output "$APPEX_BUNDLE/Contents/MacOS/CopyPathFinderExtension"
else
    HOST_ARCH="$(uname -m)"
    compile_host "$HOST_ARCH" "$APP_BUNDLE/Contents/MacOS/CopyPathFinder"
    compile_ext "$HOST_ARCH" "$APPEX_BUNDLE/Contents/MacOS/CopyPathFinderExtension"
fi

cp "$SRC_DIR/HostApp/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "$SRC_DIR/Extension/Info.plist" "$APPEX_BUNDLE/Contents/Info.plist"

echo "🔏 进行本地 Ad-Hoc 签名..."
codesign --force --sign - --entitlements "$SRC_DIR/Extension/Extension.entitlements" "$APPEX_BUNDLE"
codesign --force --sign - "$APP_BUNDLE"

echo "📦 安装到 $INSTALL_APP..."
rm -rf "$INSTALL_APP"
cp -R "$APP_BUNDLE" "$INSTALL_APP"

echo "🔄 注册并启用 FinderSync 扩展..."
killall CopyPathFinderExtension 2>/dev/null || true
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$INSTALL_APP"
pluginkit -a "$INSTALL_APP/Contents/PlugIns/CopyPathFinderExtension.appex"
pluginkit -e use -i com.amasun.CopyPathFinder.Extension || true
killall Finder || true

echo "✅ FinderSync 扩展安装完成："
pluginkit -m -v | grep -i "CopyPathFinder" || true
