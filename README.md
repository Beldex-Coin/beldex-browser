# Beldex Browser


An ad-free, privacy-first mobile browser with a built-in decentralized VPN (dVPN). Beldex Browser lets you browse confidentially over **Belnet**, the onion-routed, decentralized network built on top of Beldex — so your traffic is anonymized without relying on a centralized VPN provider.

---

## Overview

Beldex Browser is a cross-platform (Android and iOS) application built with Flutter. It bundles a full web browser together with the Belnet dVPN client (`belnet_lib`), giving users private, ad-free browsing where network traffic is routed through Belnet's decentralized relays rather than a single trusted server.

## Features

- **Built-in dVPN** — Route traffic through the decentralized Belnet network for anonymous, censorship-resistant browsing.
- **Ad-free browsing** — Blocks ads for a cleaner, faster experience.
- **No central authority** — Decentralized routing means no single provider can log or control your connection.
- **Voice search** — Search hands-free using speech-to-text.
- **QR code scanning** — Scan QR codes directly from the browser.
- **Text-to-speech** — Have page content read aloud for accessibility.
- **Downloads manager** — Download and manage files on device.
- **Content sharing** — Share pages and links to other apps, and open shared content in the browser.
- **Material You theming** — Dynamic color and customizable appearance.
- **Multi-language support** — Localized UI with translation tooling.

## Tech Stack

- **Framework:** Flutter (Dart, SDK `>=3.5.0 <4.0.0`)
- **dVPN engine:** Belnet, integrated via the local `belnet_lib` package (native C/C++/CMake)
- **Web engine:** `flutter_inappwebview`
- **Platforms:** Android and iOS

## Project Structure

```
beldex-browser/
├── android/          # Android platform code and config
├── ios/              # iOS platform code and config
├── lib/              # Main Dart application source
├── belnet_lib/       # Belnet dVPN library (native bindings)
├── assets/           # Images, icons, fonts, and other assets
├── fonts/            # Bundled fonts (Poppins)
├── contrib/          # Supporting scripts and resources
├── test/             # Tests
├── pubspec.yaml      # Flutter dependencies and configuration
└── l10n.yaml         # Localization configuration
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>=3.5.0`)
- Android Studio / Xcode with platform toolchains
- A native build toolchain (CMake, NDK) for compiling `belnet_lib`

### Build & Run

Clone the repository:

```bash
git clone https://github.com/Beldex-Coin/beldex-browser.git
cd beldex-browser
```

Install dependencies:

```bash
flutter pub get
```

Run on a connected device or emulator:

```bash
flutter run
```

Build release binaries:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Releases

Pre-built binaries are available on the [Releases page](https://github.com/Beldex-Coin/beldex-browser/releases). You can also find the app via the [App Store](https://apps.apple.com/app/id1477376905).

## Contributing

Contributions are welcome. Please open an issue to discuss significant changes before submitting a pull request. Bug reports and feature requests can be filed on the [issue tracker](https://github.com/Beldex-Coin/beldex-browser/issues).

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.


## Credits

 * Copyright © 2018-2026 The Beldex Project

