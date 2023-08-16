import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/main.dart' as myWitWallet;
import 'test_utils.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';

bool walletsExist = false;
String password = dotenv.env['PASSWORD'] ?? "password";
String mnemonic = dotenv.env['MNEMONIC'] ??
    "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";

void main() async {
  testWidgets("Import Mnemonic Test", (WidgetTester tester) async {
    myWitWallet.main();
    await tester.pumpAndSettle();

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
  });
}
