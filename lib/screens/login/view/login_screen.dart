import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/login/view/biometrics_autentication.dart';
import 'package:my_wit_wallet/screens/login/view/re_establish_wallet.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/widgets/carousel.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

class LoginScreen extends StatefulWidget {
  static final route = '/';

  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  PasswordInput _password = PasswordInput.pure();
  bool isLoading = false;
  String? _passwordInputErrorText;
  Future<WalletStorage>? _loadWallets;

  final _loginController = TextEditingController();
  final _loginFocusNode = FocusNode();
  final _showPasswordFocusNode = FocusNode();
  ValidationUtils validationUtils = ValidationUtils();

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
      if (validateForm(force: true)) {
        BlocProvider.of<LoginBloc>(context)
            .add(LoginSubmittedEvent(password: _password.value));
      }
    } catch (err) {
      rethrow;
    }
  }

  Widget _buttonLogin() {
    return PaddedButton(
      padding: EdgeInsets.only(top: 8, bottom: 0),
      text: 'Unlock wallet',
      isLoading: isLoading,
      type: ButtonType.primary,
      onPressed: _login,
    );
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: <Widget>[
        PaddedButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: 'Create new wallet',
            type: ButtonType.primary,
            onPressed: () => _createNewWallet(context)),
        PaddedButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: 'Import wallet',
            type: ButtonType.secondary,
            onPressed: () => _importWallet(context)),
      ],
    );
  }

  void _createNewWallet(BuildContext context) {
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.newWallet);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.newWallet));
  }

  void _importWallet(BuildContext context) {
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.imported);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.imported));
  }

  Widget _loginListener() {
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state.status == LoginStatus.LoginInvalid) {
          setState(() {
            _passwordInputErrorText = "Invalid Password";
            BlocProvider.of<LoginBloc>(context).add(LoginLogoutEvent());
            isLoading = false;
          });
        }
        if (state.status == LoginStatus.LoginInProgress) {
          setState(() {
            isLoading = true;
          });
        }
        if (state.status == LoginStatus.LoginSuccess) {
          Navigator.pushReplacementNamed(context, DashboardScreen.route);
        }
        if (state.status == LoginStatus.LoginCancelled) {
          setState(() {
            isLoading = false;
          });
        }
      },
      child: _buttonLogin(),
    );
  }

  bool formValidation() {
    return _password.valid;
  }

  bool validateForm({force = false}) {
    if (force) {
      setPassword(_password.value, validate: true);
    }
    return formValidation();
  }

  void setPassword(String password, {bool? validate}) {
    setState(() {
      _password = PasswordInput.dirty(
          value: password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus([_loginFocusNode]));
    });
  }

  Form _loginForm() {
    _loginFocusNode.addListener(() => validateForm());
    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      child: InputLogin(
        hint: 'Password',
        errorText: _password.error ?? _passwordInputErrorText,
        showPassFocusNode: _showPasswordFocusNode,
        obscureText: true,
        textEditingController: _loginController,
        focusNode: _loginFocusNode,
        onChanged: (String? value) {
          if (mounted) {
            _passwordInputErrorText = null;
            setPassword(value ?? '');
          }
        },
        onFieldSubmitted: (String? value) {
          // hide keyboard
          FocusManager.instance.primaryFocus?.unfocus();
          _login();
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
        'myWitWallet allows you to send and receive Wit immediately. Bye bye synchronization!',
        'myWitWallet uses state-of-the-art cryptography to store your Wit coins securely.',
        'myWitWallet is completely non-custodial. Your keys will never leave your device.',
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
            // There are wallets stored
            if (snapshot.data!.wallets.isNotEmpty) {
              return Layout(
                navigationActions: [],
                widgetList: [
                  ...mainComponents(),
                  SizedBox(height: 16),
                  _loginForm(),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Platform.isIOS || Platform.isAndroid
                            ? BiometricsAutentication()
                            : Container(),
                        SizedBox(height: 8),
                        ReEstablishWallet(),
                      ])
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
          widgetList: [
            ...mainComponents(),
            SizedBox(height: 32),
            SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  color: theme.textTheme.labelMedium?.color,
                  strokeWidth: 2,
                  value: null,
                  semanticsLabel: 'Circular progress indicator',
                ))
          ],
          actions: [],
        );
      },
    );
  }
}
