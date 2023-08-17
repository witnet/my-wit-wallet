import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'test_utils.dart';

Future<void> e2eReEstablishWallets(WidgetTester tester) async {
  await initializeTest(tester);
  await tester.pumpAndSettle();

  /// Assess what is on the screen
  walletsExist = isTextOnScreen("Unlock wallet");
  bool biometricsActive = isTextOnScreen("CANCEL");

  if (walletsExist && biometricsActive && Platform.isAndroid) {
    await tapButton(tester, "CANCEL");
  }
  if (walletsExist) {
    /// Login Screen
    await enterText(tester, TextFormField, password);
    await tapButton(tester, "Unlock wallet");
  }

  await tapButton(tester, FontAwesomeIcons.gear);
  await tapButton(tester, 'Lock wallet');

  /// Cancel the Biometrics popup for linux
  if (walletsExist && biometricsActive) {
    if (Platform.isAndroid) {
      await tapButton(tester, "CANCEL");
    }
  }
  // Scroll Save button into view
  final listFinder = find
      .byType(Scrollable)
      .last; // take last because the tab bar up top is also a Scrollable
  await tester.scrollUntilVisible(find.byType(PaddedButton).at(0), -100.0,
      scrollable: listFinder);
  await tester.pumpAndSettle();

  await tapButton(tester, PaddedButton, index: 0);
  await scrollUntilVisible(
      tester, widgetByLabel("I will be careful, I promise!"));
  await tapButton(tester, LabeledCheckbox);
  await tapButton(tester, "Continue");
  await tapButton(tester, "Re-establish");
  await tapButton(tester, "Continue", index: 1);
  await tapButton(tester, "Back", index: 0);
  bool isStorageDeleted = isTextOnScreen('Create new wallet');
  expect(isStorageDeleted, true);
}
