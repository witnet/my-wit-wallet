import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/bloc_providers.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/login/view/init_screen.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

import 'bloc/theme/theme_bloc.dart';
import 'constants.dart' as CONSTANTS;

class MyWitWalletApp extends StatefulWidget {
  final WalletTheme initialTheme;

  MyWitWalletApp(this.initialTheme);

  @override
  _MyWitWalletState createState() => _MyWitWalletState();
}

class _MyWitWalletState extends State<MyWitWalletApp> {
  String _title = CONSTANTS.APP_TITLE;
  late Locale _locale;
  late Widget _home;

  Map<String, WidgetBuilder> _routes = {
    CreateWalletScreen.route: (context) => CreateWalletScreen(),
    DashboardScreen.route: (context) => DashboardScreen(),
    CreateVttScreen.route: (context) => CreateVttScreen(),
    PreferencePage.route: (context) => PreferencePage(),
    ReceiveTransactionScreen.route: (context) => ReceiveTransactionScreen()
  };

  List<LocalizationsDelegate<dynamic>> _localizationsDelegates =
      CONSTANTS.localizationDelegates;
  _Route _defaultRoute = _appRoute;

  String _initialRoute = InitScreen.route;

  ScrollBehavior _scrollBehavior = _ScrollBehavior();

  Iterable<Locale> _supportedLocales = CONSTANTS.SUPPORTED_LOCALES.values;

  @override
  void initState() {
    super.initState();

    // Set the locale to the platform local or "en" if it is not supported.
    _locale = CONSTANTS.SUPPORTED_LOCALES[Platform.localeName] ??
        CONSTANTS.SUPPORTED_LOCALES["en"]!;
    _home = InitScreen();
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Widget _buildWithTheme(BuildContext context, ThemeState state) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: _scrollBehavior,
      title: _title,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: _supportedLocales,
      locale: _locale,
      home: _home,
      initialRoute: _initialRoute,
      routes: _routes,
      theme: state.themeData,
      onUnknownRoute: _defaultRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getProviders(context, widget.initialTheme),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (previousState, state) {
          return previousState != state;
        },
        builder: _buildWithTheme,
      ),
    );
  }
}

typedef Route<dynamic> _Route(RouteSettings settings);

Route<dynamic> _appRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (BuildContext context) =>
        Scaffold(body: Center(child: Text('Not Found'))),
  );
}

class _ScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.trackpad,
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
