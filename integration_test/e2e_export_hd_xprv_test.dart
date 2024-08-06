part of 'test_utils.dart';

Future<void> e2eExportHdXprvTest(WidgetTester tester) async {
  // Helper function to ensure a widget is visible and then tap it
Future<void> ensureVisibleAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

  await initializeTest(tester);

  AppLocalizations _localization = AppLocalizations.of(navigatorKey.currentContext!)!;

  // Assess what is on the screen
  walletsExist = isTextOnScreen(_localization.unlockWallet);
  bool biometricsActive = isTextOnScreen(_localization.cancel);

  // Cancel the Biometrics popup for linux
  if (walletsExist && biometricsActive && Platform.isAndroid) {
    await tapButton(tester, _localization.cancel);
  }
  if (walletsExist) {
    // Login Screen
    await enterText(tester, TextFormField, password);
    await tapButton(tester, _localization.unlockWallet);

    // Dashboard
    // Tap on the first PaddedButton on the screen, which is the identicon
    // and brings up the wallet list.
    await ensureVisibleAndTap(tester, find.byType(PaddedButton).first);
    await ensureVisibleAndTap(tester, find.byIcon(FontAwesomeIcons.circlePlus));
  }

  // Create or Import Wallet
  await ensureVisibleAndTap(tester, find.text(_localization.importWalletLabel));
  await ensureVisibleAndTap(tester, find.text(_localization.importXprvLabel));

  // Wallet Security
  await scrollUntilVisible(tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await scrollUntilVisible(tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await ensureVisibleAndTap(tester, find.byType(LabeledCheckbox));
  await tester.takeScreenshot(name: '1');
  await ensureVisibleAndTap(tester, find.text(_localization.continueLabel));
  await tester.takeScreenshot(name: '2');

  // Enter Shiekah Compatible Encrypted Xprv
  await enterText(tester, TextField, sheikahXprv, index: 0);
  await enterText(tester, TextField, password, index: 1);
  await ensureVisibleAndTap(tester, find.text(_localization.continueLabel));

  // Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet");
  await ensureVisibleAndTap(tester, find.text(_localization.continueLabel));

  // If the wallet database does not exist we need to enter the password.
  if (!walletsExist) {
    await enterText(tester, TextFormField, password, index: 0);
    await enterText(tester, TextFormField, password, index: 1);
    await ensureVisibleAndTap(tester, find.text(_localization.continueLabel));
  }

  await tester.pumpAndSettle();

  // Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState = tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  await ensureVisibleAndTap(tester, find.byIcon(FontAwesomeIcons.gear));
  await ensureVisibleAndTap(tester, find.text(_localization.preferenceTabs('wallet')));

  await ensureVisibleAndTap(tester, find.text(_localization.exportXprv));

  await enterText(tester, TextFormField, password, index: 0);

  await scrollUntilVisible(tester, widgetByText(_localization.verifyLabel).first, lastScroll: true);

  await ensureVisibleAndTap(tester, find.text(_localization.verifyLabel));

  await tester.pumpAndSettle();

  await enterText(tester, TextFormField, password, index: 0);
  await enterText(tester, TextFormField, password, index: 1);

  await scrollUntilVisible(tester, widgetByText(_localization.generateXprv).first, lastScroll: true);

  await ensureVisibleAndTap(tester, find.text(_localization.generateXprv));

  // Scroll Save button into view
  await scrollUntilVisible(tester, widgetByText(_localization.copyXprvLabel).first, lastScroll: true);
  await tester.pumpAndSettle();
  await ensureVisibleAndTap(tester, find.text(_localization.copyXprvLabel));

  // Data from the copied xprv
  ClipboardData? data = await Clipboard.getData('text/plain');

  // Dashboard
  // Tap on the first PaddedButton on the screen, which is the identicon
  // and brings up the wallet list.
  await ensureVisibleAndTap(tester, find.byType(PaddedButton).first);
  await ensureVisibleAndTap(tester, find.byIcon(FontAwesomeIcons.circlePlus));

  // Create or Import Wallet
  await ensureVisibleAndTap(tester, find.text(_localization.importWalletLabel));
  await ensureVisibleAndTap(tester, find.text(_localization.importXprvLabel));
  await Future.delayed(Duration(seconds: 7 ));

  // Wallet Security
  await scrollUntilVisible(tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await scrollUntilVisible(tester, widgetByLabel(_localization.walletSecurityConfirmLabel));
  await tester.takeScreenshot(name: '3');
  await Future.delayed(Duration(seconds: 7 ));


  await ensureVisibleAndTap(tester, find.byType(LabeledCheckbox));
  await ensureVisibleAndTap(tester, find.text(_localization.continueLabel));
  await tester.takeScreenshot(name: '4');

  // Enter Sheikah Compatible Encrypted Xprv
  await enterText(tester, TextField, data?.text ?? '', index: 0);
  await enterText(tester, TextField, password, index: 1);
  await ensureVisibleAndTap(tester, find.text(_localization.continueLabel));

  // Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet");
  await ensureVisibleAndTap(tester, find.text(_localization.continueLabel));

  // Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState2 = tester.state(widgetByType(DashboardScreen));
  Wallet? currentWallet2 = dashboardScreenState2.currentWallet;

  // Verify the imported wallet and the current address corresponds to the exported xprv
  expect(currentWallet2!.externalAccounts[0]!.address, currentWallet!.externalAccounts[0]!.address);

  await teardownTest();
}