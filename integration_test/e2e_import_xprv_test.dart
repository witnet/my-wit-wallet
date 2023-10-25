part of 'test_utils.dart';

Future<void> e2eImportXprvTest(WidgetTester tester) async {
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

  /// Enter Mnemonic
  await enterText(tester, TextField, mwwXprv, index: 0);
  await enterText(tester, TextField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet xprv");
  await tapButton(tester, _localization.continueLabel);

  /// If the wallet database does not exist we need to enter the password.
  if (!walletsExist) {
    await enterText(tester, TextFormField, password, index: 0);
    await enterText(tester, TextFormField, password, index: 1);
    await tapButton(tester, _localization.continueLabel);
  }

  await tester.pumpAndSettle();

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState =
      tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  /// Verify the imported wallet and the current address
  expect(currentWallet!.externalAccounts[0]!.address,
      "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");
  await teardownTest();
}
