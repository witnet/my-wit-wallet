import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'test_utils.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/select.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';

bool walletsExist = false;
String password = dotenv.env['PASSWORD'] ?? "password";
String xprv = dotenv.env['XPRV'] ??
    "xprv12qq5w546kss07l3kw5ag44epc79ya78fvqtnq2q775qx3p8trgqsur443m4cj98p3eaz0k7h7ncn58yccp5kkufkc6ylflctfcyzk45z8fup6tq4uavtv7fsmkg43mmuvddfk5fcx087jqy7x0wjw5j2zc82hupl0acmtgtntjmh34zk7ewg7qy2e8qj60pjs5y4szfzydfc0fern29nvzedra4c8pucgtgrpzgfr8d3vp0yjdn2y8qk2fdjeacvs76k9zely0p8vz7fyvn269y0ksu039hj";

Future<void> e2eImportXprvFromSheikahTest(WidgetTester tester) async {
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

  // Select Sheikah option
  await tapButton(tester, Select, index: 0);
  await tapButton(tester, "Sheikah");
  /// Enter Mnemonic
  await enterText(tester, TextField, xprv, index: 0);
  await enterText(tester, TextField, password, index: 1);
  await tapButton(tester, "Continue");

  /// Enter Wallet Name
  await enterText(tester, TextField, "Test Wallet xprv from Sheikah");
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
