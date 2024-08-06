part of 'test_utils.dart';

Future<void> e2eExportHdXprvTest(WidgetTester tester) async {
  await initializeTest(tester);

  AppLocalizations _localization = AppLocalizations.of(navigatorKey.currentContext!)!;

  /// Assess what is on the screen
  walletsExist = isTextOnScreen(_localization.unlockWallet);
  bool biometricsActive = isTextOnScreen(_localization.cancel);

  /// Create or Import Wallet
  await tapButton(tester, _localization.importWalletLabel);
  await tapButton(tester, _localization.importXprvLabel);

  /// Wallet Security
  await scrollUntilVisible(tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Shiekah Compatible Encrypted Xprv
  await enterText(tester, TextField, sheikahXprv, index: 0);
  await enterText(tester, TextField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet");
  await tapButton(tester, _localization.continueLabel);

  /// If the wallet database does not exist we need to enter the password.
  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);

  await tester.pumpAndSettle();

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState = tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  await tapButton(tester, FontAwesomeIcons.gear);
  await tapButton(tester, _localization.preferenceTabs('wallet'));

  await tapButton(tester, _localization.exportXprv);

  await enterText(tester, TextFormField, password, index: 0);

  await scrollUntilVisible(tester, widgetByText(_localization.verifyLabel).first, lastScroll: true);

  await tapButton(tester, _localization.verifyLabel);

  await tester.pumpAndSettle();

  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);

  await scrollUntilVisible(tester, widgetByText(_localization.generateXprv).first, lastScroll: true);

  await tapButton(tester, _localization.generateXprv);

  /// Scroll Save button into view
  await scrollUntilVisible(tester, widgetByText(_localization.copyXprvLabel).first, lastScroll: true);
  await tester.pumpAndSettle();
  await tapButton(tester, _localization.copyXprvLabel);

  /// Data from the copied xprv
  ClipboardData? data = await Clipboard.getData('text/plain');

  /// Dashboard
  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);
  await tapButton(tester, FontAwesomeIcons.circlePlus);

  /// Create or Import Wallet
  await tapButton(tester, _localization.importWalletLabel);
  await tapButton(tester, _localization.importXprvLabel);

  /// Wait until popover disappears 
  await Future.delayed(Duration(seconds: 7 ));

  /// Wallet Security
  await scrollUntilVisible(tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Sheikah Compatible Encrypted Xprv
  await enterText(tester, TextField, data?.text ?? '', index: 0);
  await enterText(tester, TextField, password, index: 1);
  await tapButton(tester, _localization.continueLabel);

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet");
  await tapButton(tester, _localization.continueLabel);

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState2 = tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet2 = dashboardScreenState2.currentWallet;

  /// Verify the imported wallet and the current address corresponds to the exported xprv
  expect(currentWallet2!.externalAccounts[0]!.address, currentWallet!.externalAccounts[0]!.address);

  await teardownTest();
}