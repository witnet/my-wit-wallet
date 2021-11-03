
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:witnet_wallet/app.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'bloc/crypto/crypto_isolate.dart';

void main() async{
  Locator.setup();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(WitnetWalletApp());
}

