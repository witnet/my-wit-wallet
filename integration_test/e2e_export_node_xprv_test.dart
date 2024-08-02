part of 'test_utils.dart';

Future<void> e2eExportXprvTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

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

  /// Enter the password
    await enterText(tester, TextFormField, password, index: 0);
    await enterText(tester, TextFormField, password, index: 1);
    await tapButton(tester, _localization.continueLabel);

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
