part of 'test_utils.dart';

Future<void> e2eReEstablishWallets(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;
  await tester.pumpAndSettle();

  /// Assess what is on the screen
  walletsExist = isTextOnScreen(_localization.unlockWallet);
  bool biometricsActive = isTextOnScreen(_localization.cancel);

  if (walletsExist && biometricsActive && Platform.isAndroid) {
    await tapButton(tester, _localization.cancel);
  }
  if (walletsExist) {
    /// Login Screen
    await enterText(tester, TextFormField, password);
    await tapButton(tester, _localization.unlockWallet);
  } else {
    /// Create or Import Wallet from mnemonic
    await tapButton(tester, _localization.importWalletLabel);
    await tapButton(tester, _localization.importMnemonicLabel);

    /// Wallet Security
    await scrollUntilVisible(
        tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
    await tapButton(tester, LabeledCheckbox);
    await tapButton(tester, _localization.continueLabel);

    /// Enter Mnemonic
    await enterText(tester, TextField, mnemonic);
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
  }

  await tapButton(tester, FontAwesomeIcons.gear);
  await tapButton(tester, _localization.lockWalletLabel,
      delay: true, milliseconds: 1000);
  await scrollUntilVisible(
    tester,
    widgetByText(_localization.reestablishWallet),
    lastScroll: true,
  );
  await tapButton(
    tester,
    _localization.reestablishWallet,
    delay: true,
    milliseconds: 1000,
  );
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, _localization.continueLabel);
  await tapButton(tester, _localization.reestablish);
  await tapButton(tester, _localization.continueLabel, index: 1);
  bool isStorageDeleted = isTextOnScreen(_localization.createNewWalletLabel);
  expect(isStorageDeleted, true);
  await teardownTest();
}
