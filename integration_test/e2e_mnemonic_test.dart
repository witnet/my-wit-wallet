import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/create_wallet/generate_mnemonic_card.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'test_utils.dart';

Future<void> e2eImportMnemonicTest(WidgetTester tester) async {
  await initializeTest(tester);

  /// Assess what is on the screen
  walletsExist = isTextOnScreen("Unlock wallet");
  bool biometricsActive = isTextOnScreen("CANCEL");

  /// Cancel the Biometrics popup
  if (walletsExist && biometricsActive) await tapButton(tester, "CANCEL");

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

  /// Get the currentWallet loaded in the dashboard
  final DashboardScreenState dashboardScreenState =
      tester.state(widgetByType(DashboardScreen));
  dashboardScreenState.currentWallet!.printDebug();
  Wallet? currentWallet = dashboardScreenState.currentWallet;
  /// Verify the imported wallet and the current address
  expect(currentWallet!.externalAccounts[0]!.address,
      "wit174la8pevl74hczcpfepgmt036zkmjen4hu8zzs");
}

Future<void> e2eCreateMnemonicTest(WidgetTester tester) async {
  await initializeTest(tester);

  /// Assess what is on the screen
  walletsExist = isTextOnScreen("Unlock wallet");
  bool biometricsActive = isTextOnScreen("CANCEL");

  /// Cancel the Biometrics popup
  if (walletsExist && biometricsActive) await tapButton(tester, "CANCEL");

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
  await tapButton(tester, "Create new wallet");

  /// Wallet Security
  await scrollUntilVisible(
      tester, widgetByLabel("I will be careful, I promise!"));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, "Continue");

  /// Get the generated mnemonic
  final GenerateMnemonicCardState generateMnemonicCardState =
      tester.state(widgetByType(GenerateMnemonicCard));
  String generatedMnemonic = generateMnemonicCardState.mnemonic;
  await tapButton(tester, "Continue");

  /// Enter Mnemonic
  await enterText(tester, TextField, generatedMnemonic);
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
}
