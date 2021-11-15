import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/bloc/bloc_providers.dart';
import 'package:witnet_wallet/bloc/cache/cache_bloc.dart' as cache;
import 'package:witnet_wallet/bloc/create_vtt/create_vtt_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/login/login_screen.dart';
import 'package:witnet_wallet/screens/test/test_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/crypto/crypto_bloc.dart';
import 'bloc/explorer/explorer_bloc.dart';
import 'bloc/theme/theme_bloc.dart';

class WitnetWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getProviders(context),
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
    localizationsDelegates: [
      AppLocalizations.delegate, // Add this line
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    // usage example: Text(AppLocalizations.of(context)!.helloWorld);
    supportedLocales: [
      Locale('en', ''), // English, no country code
      Locale('es', ''), // Spanish, no country code
      Locale('ru', ''), // Russian, no country code
    ],
    home: LoginScreen(),
    theme: state.themeData,
    routes: {
      LoginScreen.route: (context) => LoginScreen(),
      CreateWalletScreen.route: (context) => CreateWalletScreen(),
      TestScreen.route: (context) => TestScreen(),
    },
  );
}
