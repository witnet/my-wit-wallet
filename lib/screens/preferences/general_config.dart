import 'package:flutter/material.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/util/preferences.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/switch.dart';
import 'package:my_wit_wallet/bloc/theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/unlock_keychain_modal.dart';

enum AuthPreferences { Password, Biometrics }

class GeneralConfig extends StatefulWidget {
  GeneralConfig({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => GeneralConfigState();
}

enum ConfigSteps {
  General,
  Wallet,
}

class GeneralConfigState extends State<GeneralConfig> {
  bool displayDarkMode = false;
  bool authWithBiometrics = false;
  FocusNode _switchThemeFocusNode = FocusNode();
  bool _isThemeSwitchFocus = false;
  FocusNode _switchAuthModeFocusNode = FocusNode();
  bool _isAuthModeSwitchFocus = false;

  @override
  void initState() {
    super.initState();
    _switchThemeFocusNode.addListener(_handleFocus);
    _getTheme();
    _getAuthPreferences();
  }

  @override
  void dispose() {
    _switchThemeFocusNode.removeListener(_handleFocus);
    super.dispose();
  }

  void _handleFocus() {
    setState(() {
      _isThemeSwitchFocus = _switchThemeFocusNode.hasFocus;
    });
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

  Future<void> _getAuthPreferences() async {
    String? authPreferences = await ApiPreferences.getAuthPreferences();
    if (authPreferences != null &&
        authPreferences == AuthPreferences.Biometrics.name) {
      setState(() {
        authWithBiometrics = true;
      });
    } else {
      setState(() {
        authWithBiometrics = false;
      });
    }
  }

  Widget themeWidget(context) {
    return Row(children: [
      CustomSwitch(
          focusNode: _switchThemeFocusNode,
          isFocused: _isThemeSwitchFocus,
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

  Widget biometricsAuth(ThemeData theme, BuildContext context) {
    return Row(children: [
      CustomSwitch(
          focusNode: _switchAuthModeFocusNode,
          isFocused: _isAuthModeSwitchFocus,
          checked: authWithBiometrics,
          primaryLabel: 'Biometrics',
          secondaryLabel: 'Password',
          onChanged: (value) => {
                setState(() {
                  authWithBiometrics = !authWithBiometrics;
                  final authMode = authWithBiometrics
                      ? AuthPreferences.Biometrics
                      : AuthPreferences.Password;
                  ApiPreferences.setAuthPreferences(authMode);
                  if (authMode == AuthPreferences.Password) {
                    unlockKeychainModal(
                        theme: theme,
                        context: context,
                        routeToRedirect: PreferencePage.route);
                  }
                })
              }),
    ]);
  }

  //Log out
  void _logOut() {
    BlocProvider.of<ExplorerBloc>(context)
        .add(CancelSyncWalletEvent(ExplorerStatus.unknown));
    BlocProvider.of<DashboardBloc>(context).add(DashboardResetEvent());
    BlocProvider.of<CryptoBloc>(context).add(CryptoReadyEvent());
    Navigator.of(context).popUntil((route) => route.isFirst);
    BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 16),
          Text(
            'Theme',
            style: theme.textTheme.titleSmall,
          ),
          themeWidget(context),
          SizedBox(height: 16),
          Text(
            'Enable login with biometrics',
            style: theme.textTheme.titleSmall,
          ),
          biometricsAuth(theme, context),
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
                type: ButtonType.primary,
                enabled: true,
                onPressed: () => _logOut()),
          ),
          SizedBox(height: 16),
          Text(
            'Version $VERSION_NUMBER',
            style: theme.textTheme.titleSmall,
          )
        ]));
  }
}
