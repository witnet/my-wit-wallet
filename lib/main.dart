
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:witnet_wallet/app.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'bloc/crypto/crypto_isolate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  Locator.setup();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(WitnetWalletApp());
}

