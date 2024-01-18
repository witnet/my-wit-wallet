part of 'test_utils.dart';

Future<void> e2eExportXprvTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

  /// Assess what is on the screen
  walletsExist = isTextOnScreen(_localization.unlockWallet);
  bool biometricsActive = isTextOnScreen(_localization.cancel);

  /// Cancel the Biometrics popup for linux
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
  await tapButton(tester, _localization.importWalletLabel);
  await tapButton(tester, _localization.importXprvLabel);

  /// Wallet Security
  await scrollUntilVisible(
      tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, _localization.continueLabel);

  /// Enter node Xprv
  await tapButton(tester, Select, index: 0);
  await tapButton(tester, _localization.walletTypeNodeLabel);
  await enterText(tester, TextField, nodeXprv);
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

  await tester.pumpAndSettle();

  await tapButton(tester, FontAwesomeIcons.gear);
  await tapButton(tester, _localization.preferenceTabs('wallet'));

  await tapButton(tester, _localization.exportXprv);

  await enterText(tester, TextFormField, password, index: 0);

  await scrollUntilVisible(
      tester, widgetByText(_localization.verifyLabel).first,
      lastScroll: true);

  await tapButton(tester, _localization.verifyLabel);

  // Scroll Save button into view
  await scrollUntilVisible(
      tester, widgetByText(_localization.copyXprvLabel).first,
      lastScroll: true);
  await tester.pumpAndSettle();
  await tapButton(tester, _localization.copyXprvLabel);

  ClipboardData? data = await Clipboard.getData('text/plain');

  /// Verify the imported wallet and the current address
  expect(data?.text, nodeXprv);
  await teardownTest();
}
