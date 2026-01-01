# Go-bull

Go-bull is a customized edition of the open-source [Hiddify](https://github.com/hiddify/hiddify-next) client. This fork keeps the cross-platform Flutter codebase while adapting the application and documentation for the Go-bull panel ecosystem.

## Project goals
- Deliver the familiar Hiddify experience under the Go-bull brand.
- Restrict remote subscriptions to the Go-bull control panel.
- Provide Windows, macOS, Linux, Android, iOS and web builds tailored for Go-bull users.

## Getting started
This repository follows the original Hiddify build workflow. Refer to the upstream documentation for full environment setup details.

1. Install Flutter (stable channel) and platform-specific toolchains.
2. Clone the repository:
   ```bash
   git clone https://github.com/go-bull/go-bull-client.git
   cd go-bull-client
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Build for your platform of choice, for example:
   ```bash
   flutter build windows
   flutter build macos
   flutter build apk
   ```

## Platform notes
- **Windows**: the packaged application name, installer metadata, and mutex identifiers now use the Go-bull branding.
- **Android**: launcher labels and foreground notifications display the Go-bull name. The in-app menu/navigation has been redesigned to better match the Go-bull identity and feel less like the upstream Hiddify UI.
- **macOS & Web**: manifests and packaging scripts reference Go-bull assets.

## License
Go-bull remains under the same licenses as the upstream Hiddify project. See [LICENSE.md](LICENSE.md) for details.

## Credits
All kudos go to the original [Hiddify](https://github.com/hiddify/hiddify-next) authors and contributors for building the foundation that this fork extends.
