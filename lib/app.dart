import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/bloc/cache/cache_bloc.dart' as cache;
import 'package:witnet_wallet/bloc/create_vtt/create_vtt_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/create_wallet/import_encrypted_xprv/import_encrypted_xprv_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/import_encrypted_xprv/import_encrypted_xprv_screen.dart';
import 'package:witnet_wallet/screens/create_wallet/import_mnemonic/import_mnemonic_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/import_mnemonic/import_mnemonic_screen.dart';
import 'package:witnet_wallet/screens/create_wallet/import_xprv/import_xprv_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/import_xprv/import_xprv_screen.dart';
import 'package:witnet_wallet/screens/login/login_screen.dart';
import 'package:witnet_wallet/screens/test/test_screen.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/crypto/crypto_bloc.dart';
import 'bloc/explorer/explorer_bloc.dart';
import 'bloc/theme/theme_bloc.dart';

class WitnetWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ///
        BlocProvider<BlocAuth>(
            create: (BuildContext context) => BlocAuth(LoggedOutState())),
        ///
        BlocProvider<BlocTheme>(
            create: (BuildContext context) => BlocTheme()),
        ///
        BlocProvider<BlocCrypto>(
            create: (BuildContext context) => BlocCrypto(CryptoReadyState())),
        ///
        BlocProvider<BlocCreateWallet>(
            create: (BuildContext context) => BlocCreateWallet(DisclaimerState())),
        ///
        BlocProvider<BlocImportMnemonic>(
            create: (BuildContext context) => BlocImportMnemonic(ImportMnemonicDisclaimerState())),
        ///
        BlocProvider<BlocImportXprv>(
            create: (BuildContext context) => BlocImportXprv(ImportXprvDisclaimerState())),
        ///
        BlocProvider<BlocImportEcnryptedXprv>(
            create: (BuildContext context) => BlocImportEcnryptedXprv(ImportEncryptedXprvDisclaimerState())),
        ///
        BlocProvider<BlocExplorer>(
            create: (BuildContext context) => BlocExplorer(ReadyState())),
        ///
        BlocProvider<cache.BlocCache>(
            create: (BuildContext context) => cache.BlocCache(cache.CacheInitialState())),
        ///
        BlocProvider<BlocCreateVTT>(
          create: (BuildContext context) => BlocCreateVTT(InitialState()),
        )
      ],
      child: BlocBuilder<BlocTheme, ThemeState>(
        builder: _buildWithTheme,
      ),
    );
  }
}

Widget _buildWithTheme(BuildContext context, ThemeState state) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Material App',
    home: LoginScreen(),
    theme: state.themeData,
    routes: {
      LoginScreen.route: (context) => LoginScreen(),
      CreateWalletScreen.route: (context) => CreateWalletScreen(),
      ImportMnemonicScreen.route: (context) => ImportMnemonicScreen(),
      ImportXprvScreen.route: (context) => ImportXprvScreen(),
      ImportEncryptedXprvScreen.route: (context) => ImportEncryptedXprvScreen(),
      TestScreen.route: (context) => TestScreen(),
    },
  );
}
