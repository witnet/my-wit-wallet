import 'package:flutter/material.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/switch.dart';
import 'package:witnet_wallet/bloc/theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/widgets/layout.dart';

class PreferencePage extends StatefulWidget {
  PreferencePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  bool checked = false;

  Widget themeWidget(heigh, context) {
    return Row(children: [
      CustomSwitch(
          checked: checked,
          primaryLabel: 'Dark Mode',
          secondaryLabel: 'Light Mode',
          onChanged: (value) => {
                setState(() {
                  checked = !checked;
                  BlocProvider.of<ThemeBloc>(context).add(ThemeChanged(
                      checked ? WalletTheme.Dark : WalletTheme.Light));
                })
              }),
    ]);
  }

  //Log out
  void _logOut() {
    BlocProvider.of<DashboardBloc>(context).add(DashboardResetEvent());
    BlocProvider.of<CryptoBloc>(context).add(CryptoReadyEvent());
    BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Layout(
      navigationActions: [],
      widgetList: [
        themeWidget(deviceSize.height * 0.25, context),
        PaddedButton(
          padding: EdgeInsets.only(bottom: 8),
          text: 'Log out',
          type: 'text',
          enabled: true,
          onPressed: () => _logOut()),
      ],
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      actions: [],
      actionsSize: 0,
    );
  }
}
