part of 'test_utils.dart';

Future<void> e2eCreateMnemonicTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

  /// Assess what is on the screen
  walletsExist = isTextOnScreen(_localization.unlockWallet);
  bool biometricsActive = isTextOnScreen(_localization.cancel);

  /// Cancel the Biometrics popup
  if (walletsExist && biometricsActive && Platform.isAndroid) {
    await tapButton(tester, _localization.cancel);
  }
  if (walletsExist) {
    /// Login Screen
    await enterText(tester, TextFormField, password);
    await tapButton(tester, _localization.unlockWallet);

    /// Dashboard
    /// Tap on the first PaddedButton on the screen, which is the identicon
    /// and brings up the wallet list.
    await tapButton(tester, PaddedButton, index: 0);
    await tapButton(tester, FontAwesomeIcons.circlePlus);
  }

  /// Create or Import Wallet
  await tapButton(tester, _localization.createNewWalletLabel);

  /// Wallet Security
  await scrollUntilVisible(
      tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, _localization.continueLabel);

  /// Get the generated mnemonic
  final GenerateMnemonicCardState generateMnemonicCardState =
      tester.state(widgetByType(GenerateMnemonicCard));
  String generatedMnemonic = generateMnemonicCardState.mnemonic;
  await tapButton(tester, _localization.continueLabel);

  /// Enter Mnemonic
  await enterText(tester, TextField, generatedMnemonic);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet");
  await tapButton(tester, _localization.continueLabel);

  /// If the wallet database does not exist we need to enter the password.
  if (!walletsExist) {
    await enterText(tester, TextFormField, password, index: 0);
    await enterText(tester, TextFormField, password, index: 1);
    await tapButton(tester, _localization.continueLabel);
  }
  await teardownTest();
}
