import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/globals.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

Widget getCreateImportIcon() {
  String iconName = 'import-wallet';
  if (navigatorKey.currentContext != null) {
    final theme = Theme.of(navigatorKey.currentContext!);
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(navigatorKey.currentContext!)
            .state
            .createWalletType;
    if (type == CreateWalletType.newWallet || type == CreateWalletType.reset) {
      iconName = 'create-or-import-wallet';
    }
    return svgThemeImage(theme, name: iconName, height: 90);
  } else {
    return svgImage(name: iconName);
  }
}
