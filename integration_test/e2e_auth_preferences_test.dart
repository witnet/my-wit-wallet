import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'test_utils.dart';

Future<void> e2eAuthPreferencesTest(WidgetTester tester) async {
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
  // Check if it is desktop
  if (Platform.isIOS || Platform.isAndroid) {
    if (tester.widget<Switch>(find.byType(Switch).at(1)).value == false) {
      // Tap switch to authenticate with Biometrics
      await tapButton(tester, Switch, index: 1);
    }
    // Tap switch again to authenticate with password
    await tapButton(tester, Switch, index: 1);

    // Show modal to verify password
    expect(widgetByText('Input your password'), findsWidgets);

    // Enter password for verification and continue
    await enterText(tester, TextFormField, password);
    await tapButton(tester, "Continue");
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);

    // Avoid switch to password authentication if password is not typed by the user
    await tapButton(tester, Switch, index: 1);
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
    await tapButton(tester, Switch, index: 1);
    await tapButton(tester, "Close");
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
  } else {
    // Auth settings should not appear
    expect(widgetByText('Enable login with biometrics'), findsNothing);
  }
}
