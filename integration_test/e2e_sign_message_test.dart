part of 'test_utils.dart';

Future<void> e2eSignMessageTest(WidgetTester tester) async {
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

  if (Platform.isIOS || Platform.isAndroid) {
    if (tester.widget<Switch>(find.byType(Switch).at(1)).value == false) {
      // Tap switch to authenticate with Biometrics
      await tapButton(tester, Switch, index: 1);
    }
  }

  await tapButton(tester, _localization.preferenceTabs("wallet"));

  // Scroll Sign message button into view
  await scrollUntilVisible(tester, widgetByText(_localization.signMessage).last,
      lastScroll: true);

  await tapButton(tester, _localization.signMessage);

  /// Enter Message to sign
  await enterText(tester, TextField, "myWitWallet");

  // Scroll Sign message button into view
  await scrollUntilVisible(tester, find.text(_localization.signMessage),
      lastScroll: true);

  await tapButton(tester, _localization.signMessage);

  // Scroll Copy JSON button into view
  await scrollUntilVisible(tester, widgetByText(_localization.copyJson).first,
      lastScroll: true);

  // Scroll Copy JSON button into view
  await tapButton(tester, _localization.copyJson);

  ClipboardData? data = await Clipboard.getData('text/plain');

  /// Verify the imported wallet and the current address
  expect(data?.text, isNotNull);

  // Scroll Close button into view
  await scrollUntilVisible(
      tester, widgetByIcon(FontAwesomeIcons.solidCircleXmark),
      lastScroll: true);

  // Close sign message config view
  await tapButton(tester, FontAwesomeIcons.solidCircleXmark);

  // Go back to wallet config options
  expect(widgetByText(_localization.walletConfigHeader), findsWidgets);
  await teardownTest();
}
