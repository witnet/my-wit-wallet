import 'dart:io';

import 'package:my_wit_wallet/globals.dart' as globals;

bool showBiometrics() {
  return (!globals.testingActive && Platform.isIOS) || Platform.isAndroid;
}
