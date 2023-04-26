# myWitWallet


<div align="center">
    <a href="https://travis-ci.com/witnet/my-wit-wallet"><img src="https://img.shields.io/github/actions/workflow/status/witnet/my-wit-wallet/main.yml" alt="Build Status" /></a>
    <a href="https://github.com/witnet/my-wit-wallet/blob/master/LICENSE"><img src="https://img.shields.io/github/license/witnet/my-wit-wallet" alt="GPLv3 Licensed" /></a>
    <a href="https://github.com/witnet/my-wit-wallet/graphs/contributors"><img src="https://img.shields.io/github/contributors/witnet/my-wit-wallet" alt="GitHub contributors" /></a>
    <a href="https://github.com/witnet/my-wit-wallet/commits/main"><img src="https://img.shields.io/github/last-commit/witnet/my-wit-wallet" alt="Github last commit" /></a>
    <br /><br />
    <p><strong>myWitWallet</strong> is a non-custodial <a href="https://witnet.io/">Witnet</a> compatible wallet that allows you to send and receive Wit immediately.</p>
</div>

## Installation

### From Github Releases

Go to the [releases](https://github.com/witnet/my-wit-wallet/releases) section and download the binary suitable for your system.

## myWitWallet Development

This application is built using the [Flutter](https://docs.flutter.dev/get-started/install) framework.

### Dependencies

You need to install [Flutter](https://docs.flutter.dev/get-started/install) to run the app in development mode. Depending on your operating system, you will be requested to comply with some [requirements](https://docs.flutter.dev/get-started/install).


### Running myWitWallet

``` bash
# clone the repository
git clone git@github.com:witnet/my-wit-wallet.git

# cd into the cloned repository
cd my-wit-wallet

# install application dependencies
flutter pub get

# launch development application
flutter run
```

### Formatter

Repair lint errors with (**this operation modifies your files!**) `dart format .`

### Test

We use [Flutter](https://docs.flutter.dev/testing#unit-tests) for testing.

``` bash
# run unit tests
flutter test
```

### Build

#### Production

``` bash
flutter pub get
```

| System |Build commands | Destination path |
| -------- | -------- | -------- |
| **iOS**   | `flutter build ios --release --no-codesign`    | `./build/ios/ipa/myWitWallet.ipa`    |
| **android**   | `flutter build apk`    | `./build/app/outputs/flutter-apk/myWitWallet.apk`|
| **macOS**   | `flutter build macos --release`    |`./build/macos/Build/Products/Release/myWitWallet.app`|
| **windows**   | `flutter build windows`    | `.\build\windows\runner\Release`    |
| **linux**   | ``` bash sudo apt-get update -y && sudo apt-get install -y ninja-build libgtk-3-dev flutter build linux --release ```    | `./build/linux/x64/release/bundle`     |

### Github Actions (continuous integration)

#### Release

Creating a tag in my-wit-wallet repo triggers a [Github Actions](https://github.com/witnet/my-wit-wallet/actions) workflow and generates a new release for `linux`, `windows`, `macOS`, `android` and `iOs`.

### Troubleshooting

* Use `flutter doctor` to check if you miss any dependencies to complete the Flutter configuration.
* Use `flutter clean` to clean the generated build and the Flutter cache.
* Use `dart pub cache repair` to reinstall all packages in the system cache.

## License

[GPL-3](https://github.com/witnet/my-wit-wallet/blob/main/LICENSE)
