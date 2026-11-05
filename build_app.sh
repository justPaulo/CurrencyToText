#!/bin/sh
set -eu

cd "$(dirname "$0")"
swift build -c release

app_dir="$PWD/.build/CurrencyToText.app"
bin_dir="$(swift build -c release --show-bin-path)"
iconset_dir="$PWD/.build/AppIcon.iconset"
mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Resources"
cp "$bin_dir/CurrencyToText" "$app_dir/Contents/MacOS/CurrencyToText"
cp Resources/Info.plist "$app_dir/Contents/Info.plist"
swift Scripts/generate_app_icon.swift "$iconset_dir"
iconutil -c icns "$iconset_dir" -o "$app_dir/Contents/Resources/AppIcon.icns"
printf 'Created %s\n' "$app_dir"
