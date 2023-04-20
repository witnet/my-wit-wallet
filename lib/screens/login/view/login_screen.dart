import 'dart:async';
import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet_wallet/widgets/layouts/layout.dart';
import 'package:witnet_wallet/widgets/carousel.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/shared/api_database.dart';

class LoginScreen extends StatefulWidget {
  static final route = '/';

  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  String? _password;
  bool isLoading = false;
  String? _passwordInputErrorText;
  Future<WalletStorage>? _loadWallets;

  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _loginFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadWallets = Locator.instance<ApiDatabase>().loadWalletsDatabase();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _loginFocusNode.dispose();
    super.dispose();
  }

  _login() {
    try {
      if (_loginFormKey.currentState!.validate()) {
        BlocProvider.of<LoginBloc>(context)
            .add(LoginSubmittedEvent(password: _password!));
      }
    } catch (err) {
      rethrow;
    }
  }

  Widget _buttonLogin() {
    return PaddedButton(
      padding: EdgeInsets.only(top: 8, bottom: 0),
      text: 'Login',
      isLoading: isLoading,
      type: 'primary',
      onPressed: _login,
    );
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: <Widget>[
        PaddedButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: 'Create new wallet',
            type: 'primary',
            onPressed: () => _createNewWallet(context)),
        PaddedButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: 'Import wallet',
            type: 'secondary',
            onPressed: () => _importWallet(context)),
      ],
    );
  }

  void _createNewWallet(BuildContext context) {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.newWallet);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.newWallet));
  }

  void _importWallet(BuildContext context) {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.imported);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.imported));
  }

  Widget _loginListener() {
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state.status == LoginStatus.LoginInvalid) {
          setState(() {
            _passwordInputErrorText = "Invalid Password";
            BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
          });
        }
        if (state.status == LoginStatus.LoginInProgress) {
          setState(() {
            isLoading = true;
          });
        }
        if (state.status == LoginStatus.LoggedOut) {
          setState(() {
            isLoading = false;
          });
        }
        if (state.status == LoginStatus.LoginSuccess) {
          Navigator.pushReplacementNamed(context, DashboardScreen.route);
        }
      },
      child: _buttonLogin(),
    );
  }

  String? _validatePassword(String? input) {
    if (input != null) {
      if (input.isEmpty) {
        return 'Please input a password';
      }
      return null;
    }
    return 'Please input a password';
  }

  Form _loginForm() {
    return Form(
      key: _loginFormKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: InputLogin(
        hint: 'Password',
        errorText: _passwordInputErrorText,
        obscureText: true,
        textEditingController: _loginController,
        focusNode: _loginFocusNode,
        validator: _validatePassword,
        onChanged: (String? value) {
          if (mounted) {
            setState(() {
              _password = value!;
              if (_loginFormKey.currentState!.validate()) {
                _passwordInputErrorText = null;
              }
            });
          }
        },
        onEditingComplete: () {},
        onFieldSubmitted: (String? value) {
          // hide keyboard
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onTapOutside: (PointerDownEvent? event) {
          if (_loginFocusNode.hasFocus) {
            _loginFormKey.currentState!.validate();
          }
        },
        onTap: () {
          _loginFocusNode.requestFocus();
        },
      ),
    );
  }

  List<Widget> mainComponents() {
    final theme = Theme.of(context);
    return [
      Padding(
        padding: EdgeInsets.only(left: 24, right: 24),
        child: witnetLogo(Theme.of(context)),
      ),
      Text(
        'Welcome',
        style: theme.textTheme.displayLarge,
      ),
      Carousel(list: [
        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
      ])
    ];
  }

  @override
  FutureBuilder<WalletStorage> build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: _loadWallets,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            BlocProvider.of<LoginBloc>(context).add(LoginDoneLoadingEvent(
                walletCount: snapshot.data!.wallets.length));
            // There are wallets stored
            if (snapshot.data!.wallets.isNotEmpty) {
              return Layout(
                navigationActions: [],
                widgetList: [
                  ...mainComponents(),
                  SizedBox(height: 16),
                  _loginForm(),
                ],
                actions: [_loginListener()],
              );
            } else {
              // No wallets stored yet
              return Layout(
                navigationActions: [],
                widgetList: mainComponents(),
                actions: [_buildInitialButtons(context, theme)],
              );
            }
          }
        }
        // Default screen while loading wallets
        return Layout(
          navigationActions: [],
          widgetList: [...mainComponents(), SizedBox(height: 32), SizedBox(height: 32, width: 32, child: CircularProgressIndicator(
            color: theme.textTheme.labelMedium?.color,
            strokeWidth: 2,
            value: null,
            semanticsLabel: 'Circular progress indicator',
          ))],
          actions: [],
        );
      },
    );
  }
}
