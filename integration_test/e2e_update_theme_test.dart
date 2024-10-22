part of 'test_utils.dart';

Future<void> e2eUpdateThemeColorTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;
  await tester.pumpAndSettle();

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

  /// Enter the password
  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);
  await tester.pumpAndSettle();
  await tapButton(tester, FontAwesomeIcons.gear);
  if (tester.widget<Switch>(find.byType(Switch).at(0)).value == false) {
    // Tap switch to change theme color
    await tapButton(tester, Switch, index: 0);
  }

  final textColor =
      tester.widget<Text>(find.text(localization.darkMode)).style!.color;

  // Avoid switch to password authentication if password is not typed by the user
  expect(textColor, WitnetPallet.lightGrey);

  // Tap switch to change theme color
  await tapButton(tester, Switch, index: 0);

  await tester.pumpAndSettle(Duration(milliseconds: 600));

  final textColor2 =
      tester.widget<Text>(find.text(localization.darkMode)).style!.color;
  // Avoid switch to password authentication if password is not typed by the user
  expect(textColor2, WitnetPallet.mediumGrey);
  await teardownTest();
}
