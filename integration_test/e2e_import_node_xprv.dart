import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/select.dart';
import 'test_utils.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';

bool walletsExist = false;
String password = dotenv.env['PASSWORD'] ?? "password";
String nodeXprv = dotenv.env['NODE_XPRV'] ?? '';

Future<void> e2eImportXprvTest(WidgetTester tester) async {
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

  /// Create or Import Wallet
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

  await tapButton(tester, "Blocks");

  expect(find.text('Block ID'), findsWidgets);
  expect(find.text('Timestamp'), findsWidgets);
  expect(find.text('2021-05-04 09:05:15'), findsWidgets);
  expect(find.text('Epoch'), findsWidgets);
  expect(find.text('387686'), findsWidgets);
  expect(find.text('Reward'), findsWidgets);
  expect(find.text('250 WIT'), findsWidgets);
  expect(find.text('Fees'), findsWidgets);
  expect(find.text('0.0000001 WIT'), findsWidgets);
  expect(find.text('Value transfer count'), findsWidgets);
  expect(find.text('0'), findsWidgets);
  expect(find.text('DR count'), findsWidgets);
  expect(find.text('0'), findsWidgets);
  expect(find.text('Commit count'), findsWidgets);
  expect(find.text('100'), findsWidgets);
  expect(find.text('Reveal count'), findsWidgets);
  expect(find.text('0'), findsWidgets);
  expect(find.text('Tally count'), findsWidgets);
  expect(find.text('0'), findsWidgets);

  /// Tap on the first PaddedButton on the screen, which is the identicon
  /// and brings up the wallet list.
  await tapButton(tester, PaddedButton, index: 0);

  /// Select HD wallet from the wallets list
  await tapButton(tester, "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");

  /// HD Wallets should not show Transactions/Blocks stepbar
  expect(widgetByText('Blocks'), findsNothing);
}