#!/bin/sh
set -eu

cd "$(dirname "$0")"
swift build -c release

app_dir="$PWD/.build/CurrencyToWords.app"
bin_dir="$(swift build -c release --show-bin-path)"
mkdir -p "$app_dir/Contents/MacOS"
cp "$bin_dir/CurrencyToWords" "$app_dir/Contents/MacOS/CurrencyToWords"
cp Resources/Info.plist "$app_dir/Contents/Info.plist"
printf 'Created %s\n' "$app_dir"
