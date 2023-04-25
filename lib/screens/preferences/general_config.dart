import 'package:flutter/material.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/preferences.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/switch.dart';
import 'package:witnet_wallet/bloc/theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';

class GeneralConfig extends StatefulWidget {
  GeneralConfig({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _GeneralConfigState();
}

enum ConfigSteps {
  General,
  Wallet,
}

class _GeneralConfigState extends State<GeneralConfig> {
  bool displayDarkMode = false;

  @override
  void initState() {
    super.initState();
    _getTheme();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getTheme() async {
    String? theme = await ApiPreferences.getTheme();
    if (theme != null && theme == WalletTheme.Dark.name) {
      setState(() {
        displayDarkMode = true;
      });
    } else {
      setState(() {
        displayDarkMode = false;
      });
    }
  }

  Widget themeWidget(heigh, context) {
    return Row(children: [
      CustomSwitch(
          checked: displayDarkMode,
          primaryLabel: 'Dark Mode',
          secondaryLabel: 'Light Mode',
          onChanged: (value) => {
                setState(() {
                  displayDarkMode = !displayDarkMode;
                  final theme =
                      displayDarkMode ? WalletTheme.Dark : WalletTheme.Light;
                  ApiPreferences.setTheme(theme);
                  BlocProvider.of<ThemeBloc>(context).add(ThemeChanged(theme));
                })
              }),
    ]);
  }

  //Log out
  void _logOut() {
    BlocProvider.of<DashboardBloc>(context).add(DashboardResetEvent());
    BlocProvider.of<CryptoBloc>(context).add(CryptoReadyEvent());
    BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 16),
      Text(
        'Theme',
        style: theme.textTheme.titleSmall,
      ),
      themeWidget(deviceSize.height * 0.25, context),
      SizedBox(height: 16),
      Text(
        'Lock your wallet',
        style: theme.textTheme.titleSmall,
      ),
      Container(
        width: 150,
        height: 80,
        child: PaddedButton(
            padding: EdgeInsets.only(bottom: 16, top: 16),
            text: 'Lock wallet',
            type: 'primary',
            enabled: true,
            onPressed: () => _logOut()),
      )
    ]);
  }
}
