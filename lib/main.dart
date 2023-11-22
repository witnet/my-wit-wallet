import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/app.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/log.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/preferences.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  Locator.setup();
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(417, 730),
      minimumSize: Size(417, 730),
      title: 'myWitWallet',
      titleBarStyle: TitleBarStyle.normal,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
  DebugLogger logger = Locator.instance<DebugLogger>();
  await apiDatabase.openDatabase();

  CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();
  await cryptoIsolate.init();

  String? theme = await ApiPreferences.getTheme();
  WalletTheme initialTheme = (theme != null && theme == WalletTheme.Dark.name)
      ? WalletTheme.Dark
      : WalletTheme.Light;
  // TODO: delete log when writing log file is tested in release mode
  logger.log('Initializing....');
  runApp(MyWitWalletApp(initialTheme));
}
