part of 'test_utils.dart';

Future<void> e2eStakeUnstakeTest(WidgetTester tester) async {
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
    /// Create or Import Wallet from xprv
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
    await enterText(tester, TextField, "Test Node");
    await tapButton(tester, _localization.continueLabel, delay: true);

    /// If the wallet database does not exist we need to enter the password.
    if (!walletsExist) {
      await enterText(tester, TextFormField, password, index: 0);
      await enterText(tester, TextFormField, password, index: 1);
      await tapButton(tester, _localization.continueLabel);
    }
  }
  await tester.pumpAndSettle();
  await tapButton(tester, localization.stakeUnstake, semantics: true);
  await tapButton(tester, localization.stake);
  expect(widgetByText(localization.stake), findsOneWidget);
  await tapButton(tester, localization.stakeUnstake, semantics: true);
  await tapButton(tester, localization.unstake);
  expect(widgetByText(localization.stake), findsNothing);
  expect(widgetByText(localization.unstake), findsOneWidget);

  await teardownTest();
}
