part of 'test_utils.dart';

Future<void> e2eUpdateThemeColorTest(WidgetTester tester) async {
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
  await tapButton(tester, FontAwesomeIcons.gear);
  if (tester.widget<Switch>(find.byType(Switch).at(0)).value == false) {
    // Tap switch to change theme color
    await tapButton(tester, Switch, index: 0);
  }
  Color? gearIconColor =
      (tester.widget(find.byIcon(FontAwesomeIcons.gear)) as Icon).color;

  final textColor =
      tester.widget<Text>(find.text(localization.darkMode)).style!.color;

  // Avoid switch to password authentication if password is not typed by the user
  expect(gearIconColor, WitnetPallet.white);
  expect(textColor, WitnetPallet.opacityWhite);

  // Tap switch to change theme color
  await tapButton(tester, Switch, index: 0);

  await tester.pumpAndSettle(Duration(milliseconds: 600));

  Color? gearIconColor2 =
      (tester.widget(find.byIcon(FontAwesomeIcons.gear)) as Icon).color;

  final textColor2 =
      tester.widget<Text>(find.text(localization.darkMode)).style!.color;
  // Avoid switch to password authentication if password is not typed by the user
  expect(gearIconColor2, WitnetPallet.witnetGreen1);
  expect(textColor2, WitnetPallet.darkGrey);
  await teardownTest();
}
