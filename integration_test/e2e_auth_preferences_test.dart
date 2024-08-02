part of 'test_utils.dart';

Future<void> e2eAuthPreferencesTest(WidgetTester tester) async {
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
  // Check if it is desktop
  if (Platform.isIOS || Platform.isAndroid) {
    if (tester.widget<Switch>(find.byType(Switch).at(1)).value == false) {
      // Tap switch to authenticate with Biometrics
      await tapButton(tester, Switch, index: 1);
    }
    // Tap switch again to authenticate with password
    await tapButton(tester, Switch, index: 1);

    // Show modal to verify password
    expect(widgetByText(_localization.enterYourPassword), findsWidgets);

    // Enter password for verification and continue
    await enterText(tester, TextFormField, password);
    await tapButton(tester, _localization.continueLabel);
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);

    // Avoid switch to password authentication if password is not typed by the user
    await tapButton(tester, Switch, index: 1);
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
    await tapButton(tester, Switch, index: 1);
    await tapButton(tester, _localization.close);
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
  } else {
    // Auth settings should not appear
    expect(widgetByText(_localization.enableLoginWithBiometrics), findsNothing);
  }
  await teardownTest();
}
