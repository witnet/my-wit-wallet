part of 'test_utils.dart';

Future<void> e2eSignMessageTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

  /// Assess what is on the screen
  walletsExist = isTextOnScreen(_localization.unlockWallet);
  bool biometricsActive = isTextOnScreen(_localization.cancel);

  /// Cancel the Biometrics popup for linux
  if (walletsExist && biometricsActive && Platform.isAndroid) {
    await tapButton(tester, _localization.cancel);
  }
  if (walletsExist) {
    /// Login Screen
    await enterText(tester, TextFormField, password);
    await tapButton(tester, _localization.unlockWallet);

    /// Dashboard
    /// Tap on the first PaddedButton on the screen, which is the identicon
    /// and brings up the wallet list.
    await tapButton(tester, PaddedButton, index: 0);
    await tapButton(tester, FontAwesomeIcons.circlePlus);
  }

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

  /// If the wallet database does not exist we need to enter the password.
  if (!walletsExist) {
    await enterText(tester, TextFormField, password, index: 0);
    await enterText(tester, TextFormField, password, index: 1);
    await tapButton(tester, _localization.continueLabel);
  }

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

  // Select second address in the list
  await tapButton(tester, Select, index: 0);
  await tapButton(tester, "wit1vzm7xrguwf5uzjx72l65stgj3npfn292tya50u",
      index: 2);

  /// Enter Message to sign
  await enterText(tester, TextField, _localization.messageToBeSigned);
  // Scroll Sign message button into view
  await scrollUntilVisible(tester, widgetByText(_localization.signMessage).last,
      lastScroll: true);
  await tapButton(tester, _localization.signMessage);

  if (Platform.isIOS || Platform.isAndroid) {
    // Show modal to verify password
    expect(widgetByText(_localization.enterYourPassword), findsWidgets);

    // Enter password for verification and continue
    await enterText(tester, TextFormField, password);
    await tapButton(tester, _localization.continueLabel);
  }

  // Scroll Copy JSON button into view
  await scrollUntilVisible(tester, widgetByText(_localization.copyJson).first,
      lastScroll: true);
  await tester.pumpAndSettle();
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
