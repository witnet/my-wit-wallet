import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/theme/theme_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';

import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'crypto/crypto_bloc.dart';
import 'explorer/explorer_bloc.dart';

List<BlocProvider> getProviders(
    BuildContext context, WalletTheme initialTheme) {
  ThemeData currentTheme = walletThemeData[initialTheme]!;
  return [
    /// BlocAuth is the gatekeeper of login and authorized ui.
    BlocProvider<LoginBloc>(create: (BuildContext context) => LoginBloc()),

    /// BlocTheme controls the global theme data.
    BlocProvider<ThemeBloc>(
        create: (BuildContext context) =>
            ThemeBloc(ThemeState(themeData: currentTheme))),

    /// BlocCrypto manages an isolate to run intensive cryptographic methods.
    BlocProvider<CryptoBloc>(
        create: (BuildContext context) => CryptoBloc(CryptoReadyState())),

    /// BlocCreateWallet manages all wallet creation options
    BlocProvider<CreateWalletBloc>(
      create: (BuildContext context) => CreateWalletBloc(
        CreateWalletState(
          walletType: WalletType.imported,
          nodeAddress: null,
          message: null,
          walletAddress: null,
          status: CreateWalletStatus.Imported,
          xprvString: null,
        ),
      ),
    ),

    /// BlocExplorer manages all interactions with the external witnet blockchain explorer
    BlocProvider<ExplorerBloc>(
        create: (BuildContext context) => ExplorerBloc(ExplorerState.ready())),

    /// BlocCreateVTT is the logic behind value transfer transaction construction.
    BlocProvider<VTTCreateBloc>(
      create: (BuildContext context) => VTTCreateBloc(),
    ),


    /// BlocDashboard manages the ui for the main dashboard
    BlocProvider<DashboardBloc>(
      create: (BuildContext context) => DashboardBloc(),
    )
  ];
}
