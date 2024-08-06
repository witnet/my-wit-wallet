part of 'test_utils.dart';

Future<void> e2eReEstablishWallets(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;
  await tester.pumpAndSettle();

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

  /// Enter the password
  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);
  await tester.pumpAndSettle();

  await tapButton(tester, FontAwesomeIcons.gear);
  await scrollUntilVisible(
    tester,
    widgetByText(_localization.lockWalletLabel),
    lastScroll: true,
  );
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
  // Wait until is deleted
  await tester.pumpAndSettle(Duration(seconds: 2));
  await tapButton(tester, _localization.continueLabel, index: 1);
  expect(widgetByText(_localization.createNewWalletLabel), findsOneWidget);
  await teardownTest();
}
