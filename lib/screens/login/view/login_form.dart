import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/login/models/models.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/path_provider_interface.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/button_login.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:witnet_wallet/widgets/wallet_list.dart';

class LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  late WalletName walletName;
  late Password password;
  final _passController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _loginController = TextEditingController();
  static const loadingDuration = Duration(milliseconds: 400);
  late AnimationController _loadingController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    password = Password.pure();
    walletName = WalletName.pure();

    _passController.text = '';
    _loginController.text = '';
    _passController.text = '';

    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    )..value = 1.0;

    _loadingController.addStatusListener(handleLoadingAnimationStatus);
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => isLoading = false);
    }
  }

  _login() {
    if (password.value.isNotEmpty) {
      print('LoginSubmittedEvent');
      BlocProvider.of<LoginBloc>(context)
          .add(LoginSubmittedEvent(walletName: walletName, password: password));
    } else {
      BlocProvider.of<LoginBloc>(context).add(LoginExceptionEvent(
        walletName,
        password,
        code: -2,
        message: 'Password cannot be Blank',
      ));
    }
  }

  Widget _buttonLogin() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        if (state.status == LoginStatus.LoginInProgress) {
          return Column(children: [
            ButtonLogin(
              isLoading: true,
              label: 'Login...',
              onPressed: () => {},
            ),
            SpinKitCircle(
              color: theme.primaryColor,
            )
          ]);
        } else if (state.status == LoginStatus.LoginSuccess) {
          return ButtonLogin(
            label: 'Connected!',
            onPressed: () {},
          );
        } else if (state.status == LoginStatus.LoginInvalid) {
          return Column(
            children: [
              ButtonLogin(
                label: 'login',
                onPressed: () => _login(),
              ),
              Text(
                '${state.status}',
                style: TextStyle(color: theme.errorColor),
              ),
            ],
          );
        } else {
          return ButtonLogin(
            label: 'login',
            onPressed: () => _login(),
          );
        }
      },
    );
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Create new wallet',
              onPressed: () => _createNewWallet(context)),
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Import wallet',
              onPressed: () => _importWallet(context)),
        ],
      ),
    );
  }

  Widget _buildWalletField(BuildContext context, double width) {
    final theme = Theme.of(context);
    PathProviderInterface interface = PathProviderInterface();
    return Container(
      /// A [FutureBuilder] to check if any wallet files exist.
      child: FutureBuilder<bool>(
          future: interface.walletsExist(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                children = <Widget>[
                  FutureBuilder(
                      future: interface.getWalletFiles(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> snapshot) {
                        List<Widget> children;
                        if (snapshot.hasData) {
                          children = <Widget>[
                            WalletListWidget(
                              walletFiles: snapshot.data!,
                              width: width,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7, bottom: 7),
                              child: InputLogin(
                                prefixIcon: Icons.lock,
                                hint: 'Password',
                                obscureText: true,
                                textEditingController: _passController,
                                focusNode: _passwordFocusNode,
                                onChanged: (String? value) {
                                  setState(() {
                                    password = Password.dirty(value!);
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7, bottom: 7),
                              child: _buttonLogin(),
                            ),
                          ];
                        } else {
                          children = <Widget>[
                            CircularProgressIndicator(),
                          ];
                        }
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: children,
                          ),
                        );
                      }),
                  Divider(
                    height: 20,
                  ),
                  _buildInitialButtons(context, theme),
                ];
              } else {
                children = <Widget>[_buildInitialButtons(context, theme)];
              }
            } else {
              children = const <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
              ];
            }

            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        String msg = 'Authentication Failure:' + state.message;
        if (state.status == LoginStatus.LoginInvalid) {
          print(msg);
        } else if (state.status == LoginStatus.LoginSuccess) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DashboardScreen()));
        }
      },
      child: Container(
        width: 300,
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 7, bottom: 7),
              child: _buildWalletField(context, 300),
            ),
            Padding(padding: EdgeInsets.all(7)),
          ],
        ),
      ),
    );
  }
}

void _createNewWallet(BuildContext context) {
  Locator.instance<ApiCreateWallet>().setWalletType(WalletType.newWallet);
  Navigator.pushNamed(context, CreateWalletScreen.route);
  BlocProvider.of<CreateWalletBloc>(context)
      .add(ResetEvent(WalletType.newWallet));
}

void _importWallet(BuildContext context) {
  Locator.instance<ApiCreateWallet>().setWalletType(WalletType.unset);
  Navigator.pushNamed(context, CreateWalletScreen.route);
  BlocProvider.of<CreateWalletBloc>(context)
      .add(ResetEvent(WalletType.unset));
}
