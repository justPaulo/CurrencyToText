# Currency to Text

A native macOS SwiftUI app that spells out monetary values. Choose EUR, USD,
GBP, or BRL and convert in Portuguese, English, or Spanish. The result updates
as you type and can be copied to the clipboard.

## Run

Build a launchable `.app` bundle without Xcode:

```sh
./build_app.sh
open .build/CurrencyToText.app
```

The Swift package is used to compile the app; `build_app.sh` packages that
executable as a macOS application bundle and generates its app icon from
`Scripts/generate_app_icon.swift`. Launch the `.app` rather than running the
package executable directly.

Amounts accept a comma or period as the decimal separator, an optional leading
minus sign, and up to two decimal places. Do not enter grouping separators.
