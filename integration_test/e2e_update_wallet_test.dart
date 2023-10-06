import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'package:my_wit_wallet/widgets/select.dart';
import 'test_utils.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

bool walletsExist = false;
String password = dotenv.env['PASSWORD'] ?? "password";
String mnemonic = dotenv.env['MNEMONIC'] ??
    "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
String nodeXprv = dotenv.env['NODE_XPRV'] ?? '';

Future<void> e2eUpdateCurrentWalletTest(WidgetTester tester) async {
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
  await enterText(tester, TextField, "Test Wallet");
  await tapButton(tester, "Continue");

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState =
      tester.state(widgetByType(DashboardScreen));
  await expectLater(dashboardScreenState.currentWallet!.id, 'dae88d1f');
  dashboardScreenState.currentWallet!.printDebug();
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  await tester.pumpAndSettle();

  /// Verify the imported wallet and the current address
  expectLater(currentWallet!.masterAccount!.address,
      "wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw");

  /// Dashboard
  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);
  await tapButton(tester, FontAwesomeIcons.circlePlus);

  /// Create or Import Wallet from mnemonics
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

  await tester.pumpAndSettle();

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState2 =
      tester.state(widgetByType(DashboardScreen));
  dashboardScreenState2.currentWallet!.printDebug();
  Wallet? currentWallet2 = dashboardScreenState2.currentWallet;

  /// Verify the imported wallet and the current address
  expect(currentWallet2!.externalAccounts[0]!.address,
      "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");

  await tester.pumpAndSettle();

  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);

  /// Select another wallet from the wallet list
  final listFinder = find
      .byType(Scrollable)
      .first; // take first because it is the wallet list scroll
  await tester.scrollUntilVisible(
      find.text("wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs"), -100.0,
      scrollable: listFinder);

  await tester.pumpAndSettle();

  /// Select Node wallet from the wallets list
  await tapButton(tester, "wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw");

  await tester.pumpAndSettle();

  final DashboardScreenState dashboardScreenState3 =
      tester.state(widgetByType(DashboardScreen));
  await expectLater(dashboardScreenState3.currentWallet!.id, 'dae88d1f');
  dashboardScreenState3.currentWallet!.printDebug();
  Wallet? currentWallet3 = dashboardScreenState3.currentWallet;

  await tester.pumpAndSettle();

  /// Verify the imported wallet and the current address
  expectLater(currentWallet3!.masterAccount!.address,
      "wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw");
}
