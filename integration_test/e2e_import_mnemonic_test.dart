part of 'test_utils.dart';

Future<void> e2eImportMnemonicTest(WidgetTester tester) async {
  print("10");
  await initializeTest(tester);
  print("11");
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

  /// Create or Import Wallet
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

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState =
      tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  /// Verify the imported wallet and the current address
  expect(currentWallet!.externalAccounts[0]!.address,
      "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");
 // await teardownTest();
  print("12");
}
