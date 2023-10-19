part of 'test_utils.dart';

Future<void> e2eReEstablishWallets(WidgetTester tester) async {
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
    /// Create or Import Wallet from mnemonic
    await tapButton(tester, "Import wallet");
    await tapButton(tester, "Import from secret security phrase");

    /// Wallet Security
    await scrollUntilVisible(
        tester, widgetByLabel("I will be careful, I promise!"));
    await tapButton(tester, LabeledCheckbox);
    await tapButton(tester, "Continue");

    /// Enter Mnemonic
    await enterText(tester, TextField, mnemonic);
    await tapButton(tester, "Continue");

    /// Enter Wallet Name
    await enterText(tester, TextField, "Test Wallet");
    await tapButton(tester, "Continue");

    /// If the wallet database does not exist we need to enter the password.
    if (!walletsExist) {
      await enterText(tester, TextFormField, password, index: 0);
      await enterText(tester, TextFormField, password, index: 1);
      await tapButton(tester, "Continue");
    }
    await tester.pumpAndSettle();
  }

  await tapButton(tester, FontAwesomeIcons.gear);
  await tapButton(tester, 'Lock wallet', delay: true, milliseconds: 1000);
  await scrollUntilVisible(
    tester,
    widgetByText("Re-establish wallet"),
    lastScroll: true,
  );
  await tapButton(
    tester,
    "Re-establish wallet",
    delay: true,
    milliseconds: 1000,
  );
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, "Continue");
  await tapButton(tester, "Re-establish");
  await tapButton(tester, "Continue", index: 1);
  bool isStorageDeleted = isTextOnScreen('Create new wallet');
  expect(isStorageDeleted, true);
  await teardownTest();
}
