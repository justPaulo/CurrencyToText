# Currency to Text

A native macOS SwiftUI app that spells out monetary values. Choose EUR, USD,
GBP, or BRL and convert in Portuguese, English, Spanish, German, Japanese,
Russian, French, Korean, or Simplified Chinese. The result updates as you type
and can be copied to the clipboard.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the application flow and build
diagrams.

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

The amount field adds thousands separators as you type, following the selected
language. Amounts support an optional leading minus sign and up to two decimal
places.
