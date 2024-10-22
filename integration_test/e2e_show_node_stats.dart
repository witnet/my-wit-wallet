part of 'test_utils.dart';

Future<void> e2eShowNodeStatsTest(WidgetTester tester) async {
  await initializeTest(tester);
  AppLocalizations _localization =
      AppLocalizations.of(navigatorKey.currentContext!)!;

  /// Create or Import Wallet from mnemonic
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
  await tapButton(tester, PaddedButton, index: 0);
  await tapButton(tester, FontAwesomeIcons.circlePlus);

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

  /// Enter Node Name
  await enterText(tester, TextField, "Test Node");
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

  await tapButton(tester, _localization.dashboardViewSteps("stats"));

  expect(find.text(_localization.drSolved), findsWidgets);
  expect(find.text(_localization.blocksMined), findsWidgets);
  expect(find.text(_localization.totalFeesPaid), findsWidgets);
  expect(find.text(_localization.totalMiningRewards), findsWidgets);

  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);

  final listFinder = find
      .byType(Scrollable)
      .first; // take first because it is the wallet list scroll
  await tester.scrollUntilVisible(find.text("wit174l...4hu8zzs"), -100.0,
      scrollable: listFinder);

  await tester.pumpAndSettle();

  /// Select HD wallet from the wallets list
  await tapButton(tester, "wit174l...4hu8zzs");

  await tester.pumpAndSettle();

  /// HD Wallets should not show Transactions/Blocks stepbar
  expect(widgetByText(_localization.dashboardViewSteps("stats")), findsNothing);
  await teardownTest();
}
