part of 'test_utils.dart';

Future<void> e2eShowNodeStatsTest(WidgetTester tester) async {
  await initializeTest(tester);

  /// Assess what is on the screen
  walletsExist = isTextOnScreen("Unlock wallet");
  bool biometricsActive = isTextOnScreen("CANCEL");

  /// Cancel the Biometrics popup for linux
  if (walletsExist && biometricsActive && Platform.isAndroid) {
    await tapButton(tester, "CANCEL");
  }
  if (walletsExist) {
    /// Login Screen
    await enterText(tester, TextFormField, password);
    await tapButton(tester, "Unlock wallet");

    /// Dashboard
    /// Tap on the first PaddedButton on the screen, which is the identicon
    /// and brings up the wallet list.
    await tapButton(tester, PaddedButton, index: 0);
    await tapButton(tester, FontAwesomeIcons.circlePlus);
  }

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
  await tapButton(tester, PaddedButton, index: 0);
  await tapButton(tester, FontAwesomeIcons.circlePlus);

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

  /// Enter Node Name
  await enterText(tester, TextField, "Test Node");
  await tapButton(tester, "Continue");

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

  await tapButton(tester, "Stats");

  expect(find.text('Data requests solved'), findsWidgets);
  expect(find.text('Blocks mined'), findsWidgets);
  expect(find.text('Total fees payed'), findsWidgets);
  expect(find.text('Total mining rewards'), findsWidgets);

  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);

  final listFinder = find
      .byType(Scrollable)
      .first; // take first because it is the wallet list scroll
  await tester.scrollUntilVisible(
      find.text("wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs"), -100.0,
      scrollable: listFinder);

  await tester.pumpAndSettle();

  /// Select HD wallet from the wallets list
  await tapButton(tester, "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");

  await tester.pumpAndSettle();

  /// HD Wallets should not show Transactions/Blocks stepbar
  expect(widgetByText('Stats'), findsNothing);
  await teardownTest();
}
