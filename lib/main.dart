import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:witnet_wallet/app.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  Locator.setup();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
  await apiDatabase.openDatabase();

  runApp(WitnetWalletApp());
}
