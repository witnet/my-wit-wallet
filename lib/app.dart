import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/bloc_providers.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/login/view/login_screen.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

import 'bloc/theme/theme_bloc.dart';

class WitnetWalletApp extends StatelessWidget {
  final WalletTheme initialTheme;

  WitnetWalletApp(this.initialTheme);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getProviders(context, initialTheme),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (previousState, state) {
          return previousState != state;
        },
        builder: _buildWithTheme,
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.trackpad,
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

Widget _buildWithTheme(BuildContext context, ThemeState state) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    scrollBehavior: MyCustomScrollBehavior().copyWith(overscroll: true, physics: const ClampingScrollPhysics(parent: RangeMaintainingScrollPhysics())),
    title: 'myWitWallet',
    home: LoginScreen(),
    theme: state.themeData,
    routes: {
      CreateWalletScreen.route: (context) => CreateWalletScreen(),
      DashboardScreen.route: (context) => DashboardScreen(),
      CreateVttScreen.route: (context) => CreateVttScreen(),
      PreferencePage.route: (context) => PreferencePage(),
      ReceiveTransactionScreen.route: (context) => ReceiveTransactionScreen()
    },
    onUnknownRoute: (RouteSettings settings) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) =>
            Scaffold(body: Center(child: Text('Not Found'))),
      );
    },
  );
}
