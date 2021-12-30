import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/theme/theme_bloc.dart';
import 'package:witnet_wallet/bloc/cache/cache_bloc.dart' as cache;
import 'package:witnet_wallet/bloc/transactions/value_transfer/create_vtt_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/dashboard_bloc.dart';
import 'auth/auth_bloc.dart';
import '../screens/create_wallet/create_wallet_bloc.dart';

import 'crypto/crypto_bloc.dart';
import 'explorer/explorer_bloc.dart';

List<BlocProvider> getProviders(BuildContext context) {
  return [
    /// BlocAuth is the gatekeeper of login and authorized ui.
    BlocProvider<BlocAuth>(
        create: (BuildContext context) => BlocAuth(LoggedOutState())),

    /// BlocTheme controls the global theme data.
    BlocProvider<BlocTheme>(create: (BuildContext context) => BlocTheme()),

    /// BlocCrypto manages an isolate to run intensive cryptographic methods.
    BlocProvider<BlocCrypto>(
        create: (BuildContext context) => BlocCrypto(CryptoReadyState())),

    /// BlocCreateWallet manages all wallet creation options
    BlocProvider<BlocCreateWallet>(
        create: (BuildContext context) =>
            BlocCreateWallet(DisclaimerState(WalletType.newWallet))),

    /// BlocExplorer manages all interactions with the external witnet blockchain explorer
    BlocProvider<BlocExplorer>(
        create: (BuildContext context) => BlocExplorer(ReadyState())),

    /// BlocCache
    BlocProvider<cache.BlocCache>(
        create: (BuildContext context) =>
            cache.BlocCache(cache.CacheInitialState())),

    /// BlocCreateVTT is the logic behind value transfer transaction construction.
    BlocProvider<BlocCreateVTT>(
      create: (BuildContext context) => BlocCreateVTT(InitialState()),
    ),

    /// BlocDashboard manages the ui for the main dashboard
    BlocProvider<BlocDashboard>(
      create: (BuildContext context) => BlocDashboard(DashboardLoadingState()),
    )
  ];
}
