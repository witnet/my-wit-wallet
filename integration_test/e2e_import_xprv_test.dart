import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'test_utils.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';

bool walletsExist = false;
String password = dotenv.env['PASSWORD'] ?? "password";
String xprv = dotenv.env['XPRV'] ??
    "xprv1m9datmt8l4qyqa2nf7lxrw76vu3kyy63qndhtpjyezm7rjrlqrqjh23yks7zjwycud9k25g20rjqkl7uyfcvq6e246du73cl8hhcfa2xwm6cun5ma69jrtyyzjzm0nqwurwa8vg5pxhd9wxu2lgrpmwknsl3yk3t4qn5au4mnf33qpnk3gg7e093nkk0kqzhfkecg45jm0qsczellg6hll4nzuldckjvj6xku75gmhjc340jau26t634c98ke3a454mqjsxtvfs53f2464jfyhd605hqs0lu";

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

  /// Enter Mnemonic
  await enterText(tester, TextField, xprv, index: 0);
  await enterText(tester, TextField, password, index: 1);
  await tapButton(tester, "Continue");

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet xprv");
  await tapButton(tester, "Continue");

  /// If the wallet database does not exist we need to enter the password.
  if (!walletsExist) {
    await enterText(tester, TextFormField, password, index: 0);
    await enterText(tester, TextFormField, password, index: 1);
    await tapButton(tester, "Continue");
  }

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState =
      tester.state(widgetByType(DashboardScreen));
  dashboardScreenState.currentWallet!.printDebug();
  Wallet? currentWallet = dashboardScreenState.currentWallet;

  /// Verify the imported wallet and the current address
  expect(currentWallet!.externalAccounts[0]!.address,
      "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");
}
