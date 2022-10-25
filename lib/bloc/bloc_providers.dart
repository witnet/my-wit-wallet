import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/theme/theme_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_status/vtt_status_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';

import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';

import 'crypto/crypto_bloc.dart';
import 'explorer/explorer_bloc.dart';

List<BlocProvider> getProviders(BuildContext context) {
  return [
    /// BlocAuth is the gatekeeper of login and authorized ui.
    BlocProvider<LoginBloc>(create: (BuildContext context) => LoginBloc()),

    /// BlocTheme controls the global theme data.
    BlocProvider<ThemeBloc>(create: (BuildContext context) => ThemeBloc()),

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

    BlocProvider<BlocStatusVtt>(
      create: (BuildContext context) => BlocStatusVtt(UnknownHashState()),
    ),

    /// BlocDashboard manages the ui for the main dashboard
    BlocProvider<DashboardBloc>(
      create: (BuildContext context) => DashboardBloc(),
    )
  ];
}
