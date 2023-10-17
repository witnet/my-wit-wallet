import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'package:my_wit_wallet/widgets/select.dart';
import 'test_utils.dart';

bool walletsExist = false;
String password = dotenv.env['PASSWORD'] ?? "password";
String nodeXprv = dotenv.env['NODE_XPRV'] ?? '';

Future<void> e2eSignMessageTest(WidgetTester tester) async {
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

  await tapButton(tester, FontAwesomeIcons.gear);

  if (Platform.isIOS || Platform.isAndroid) {
    if (tester.widget<Switch>(find.byType(Switch).at(1)).value == false) {
      // Tap switch to authenticate with Biometrics
      await tapButton(tester, Switch, index: 1);
    }
  }

  await tapButton(tester, "Wallet");

  // Scroll Sign message button into view
  await scrollUntilVisible(tester, widgetByText("Sign message").last,
      lastScroll: true);

  await tapButton(tester, "Sign message");

  // Select second address in the list
  await tapButton(tester, Select, index: 0);
  await tapButton(tester, "wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw",
      index: 2);

  /// Enter Message to sign
  await enterText(tester, TextField, "Message to be signed");
  await tapButton(tester, "Sign message");

  if (Platform.isIOS || Platform.isAndroid) {
    // Show modal to verify password
    expect(widgetByText('Enter your password'), findsWidgets);

    // Enter password for verification and continue
    await enterText(tester, TextFormField, password);
    await tapButton(tester, "Continue");
  }

  // Scroll Copy JSON button into view
  await scrollUntilVisible(tester, widgetByText("Copy JSON").first,
      lastScroll: true);
  await tester.pumpAndSettle();
  await tapButton(tester, "Copy JSON");

  ClipboardData? data = await Clipboard.getData('text/plain');

  /// Verify the imported wallet and the current address
  expect(data?.text, isNotNull);

  // Scroll Close button into view
  await scrollUntilVisible(
      tester, widgetByIcon(FontAwesomeIcons.solidCircleXmark),
      lastScroll: true);

  // Close sign message config view
  await tapButton(tester, FontAwesomeIcons.solidCircleXmark);

  // Go back to wallet config options
  expect(widgetByText('Export the Xprv key of my wallet'), findsWidgets);
}
