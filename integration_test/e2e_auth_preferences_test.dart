part of 'test_utils.dart';

Future<void> e2eAuthPreferencesTest(WidgetTester tester) async {
  await initializeTest(tester);
  await tester.pumpAndSettle();

  /// Assess what is on the screen
  walletsExist = isTextOnScreen("Unlock wallet");
  bool biometricsActive = isTextOnScreen("CANCEL");

  if (walletsExist && biometricsActive && Platform.isAndroid) {
    await tapButton(tester, "CANCEL");
  }
  if (walletsExist) {
    /// Login Screen
    await enterText(tester, TextFormField, password);
    await tapButton(tester, "Unlock wallet");
  } else {
    /// Create or Import Wallet from xprv
    await tapButton(tester, "Import wallet");
    await tapButton(tester, "Import from Xprv key");

    /// Wallet Security
    await scrollUntilVisible(
        tester, widgetByLabel("I will be careful, I promise!"));
    await tapButton(tester, LabeledCheckbox);
    await tapButton(tester, "Continue");

    /// Enter node Xprv
    await tapButton(tester, Select, index: 0);
    await tapButton(tester, "Node");
    await enterText(tester, TextField, nodeXprv);
    await tapButton(tester, "Continue");

    /// Enter Wallet Name
    await enterText(tester, TextField, "Test Node");
    await tapButton(tester, "Continue", delay: true);

    /// If the wallet database does not exist we need to enter the password.
    if (!walletsExist) {
      await enterText(tester, TextFormField, password, index: 0);
      await enterText(tester, TextFormField, password, index: 1);
      await tapButton(tester, "Continue");
    }
  }
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
    expect(widgetByText('Enter your password'), findsWidgets);

    // Enter password for verification and continue
    await enterText(tester, TextFormField, password);
    await tapButton(tester, "Continue");
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);

    // Avoid switch to password authentication if password is not typed by the user
    await tapButton(tester, Switch, index: 1);
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
    await tapButton(tester, Switch, index: 1);
    await tapButton(tester, "Close");
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
  } else {
    // Auth settings should not appear
    expect(widgetByText('Enable login with biometrics'), findsNothing);
  }
  await teardownTest();
}
