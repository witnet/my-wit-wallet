import 'dart:io';

import 'package:my_wit_wallet/globals.dart' as globals;
import 'package:my_wit_wallet/screens/preferences/general_config.dart';
import 'package:my_wit_wallet/util/preferences.dart';

Future<bool> showBiometrics() async {
  String? authPreferences = await ApiPreferences.getAuthPreferences();
  if (authPreferences == AuthPreferences.Biometrics.name) {
    return (!globals.testingActive && Platform.isIOS) || Platform.isAndroid;
  } else {
    return false;
  }
}
