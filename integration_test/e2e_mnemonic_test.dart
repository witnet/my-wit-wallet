part of 'test_utils.dart';

Future<void> e2eCreateMnemonicTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

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

  /// Enter the password
  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);
  await teardownTest();
}
