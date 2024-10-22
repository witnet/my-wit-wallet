part of 'test_utils.dart';

Future<void> e2eUpdateCurrentWalletTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

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

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState =
      tester.state(widgetByType(DashboardScreen));
  await expectLater(dashboardScreenState.currentWallet!.id, 'ce389a1a');
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  await tester.pumpAndSettle();

  /// Verify the imported wallet and the current address
  expectLater(currentWallet!.masterAccount!.address,
      "wit1vzm7xrguwf5uzjx72l65stgj3npfn292tya50u");

  /// Dashboard
  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);
  await tapButton(tester, FontAwesomeIcons.circlePlus);

  /// Create or Import Wallet from mnemonics
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

  await tester.pumpAndSettle();

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState2 =
      tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet2 = dashboardScreenState2.currentWallet;

  /// Verify the imported wallet and the current address
  expect(currentWallet2!.externalAccounts[0]!.address,
      "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");

  await tester.pumpAndSettle();

  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);

  await tester.pumpAndSettle();

  /// Select Node wallet from the wallets list
  await tapButton(tester, "wit1vzm...2tya50u");

  await tester.pumpAndSettle();

  final DashboardScreenState dashboardScreenState3 =
      tester.state(widgetByType(DashboardScreen));
  await expectLater(dashboardScreenState3.currentWallet!.id, 'ce389a1a');
  Wallet? currentWallet3 = dashboardScreenState3.currentWallet;

  await tester.pumpAndSettle();

  /// Verify the imported wallet and the current address
  expectLater(currentWallet3!.masterAccount!.address.cropMiddle(18),
      "wit1vzm...2tya50u");
  await teardownTest();
}
