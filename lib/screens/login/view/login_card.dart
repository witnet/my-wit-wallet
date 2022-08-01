import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/login/view/login_form.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/shared/api_auth.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/util/storage/path_provider_interface.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/button_login.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:witnet_wallet/widgets/wallet_list.dart';

class LoginCard extends StatefulWidget {
  LoginCard({
    Key? key,
    required this.onCreateOrRecover,
  }) : super(key: key);

  final Function onCreateOrRecover;
  @override
  LoginCardState createState() => LoginCardState();
}

class LoginCardState extends State<LoginCard> with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _passInertiaController;
  late String selectedWallet;
  String password = '';
  bool _showShadow = true;
  final _formKey = GlobalKey<FormState>();
  var size;
  final _loginController = TextEditingController();
  final _passController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  late AnimationController _logoController;
  late AnimationController _titleController;
  static const loadingDuration = Duration(milliseconds: 400);
  late Interval _passTextFieldLoadingAnimationInterval;
  late Interval _textButtonLoadingAnimationInterval;
  var _isLoading = false;
  @override
  void initState() {
    super.initState();

  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity,
                    30), // double.infinity is the width and 30 is the height
              ),
              child: new Text('Create New Wallet'),
              onPressed: () {
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.newWallet);
                Navigator.pushNamed(context, CreateWalletScreen.route);
                BlocProvider.of<CreateWalletBloc>(context)
                    .add(ResetEvent(WalletType.newWallet));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity,
                    30), // double.infinity is the width and 30 is the height
              ),
              child: new Text('Recover Wallet from Secret Word Phrase'),
              onPressed: () {
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.mnemonic);
                Navigator.pushNamed(context, CreateWalletScreen.route);
                BlocProvider.of<CreateWalletBloc>(context)
                    .add(ResetEvent(WalletType.mnemonic));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // double.infinity is the width and 30 is the height
                  minimumSize: Size(double.infinity, 30),
                ),
                child: new Text('Import Node from XPRV'),
                onPressed: null
                // {
                //   Locator.instance<ApiCreateWallet>()
                //       .setWalletType(WalletType.xprv);
                //   Navigator.pushNamed(context, CreateWalletScreen.route);
                //   BlocProvider.of<BlocCreateWallet>(context)
                //       .add(ResetEvent(WalletType.xprv));
                // },
                ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // double.infinity is the width and 30 is the height
                minimumSize: Size(double.infinity, 30),
              ),
              child: new Text('Import Wallet from Encrypted XPRV'),
              onPressed: () {
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.encryptedXprv);
                Navigator.pushNamed(context, CreateWalletScreen.route);
                BlocProvider.of<CreateWalletBloc>(context)
                    .add(ResetEvent(WalletType.encryptedXprv));
              },
            ),
          ),
        ],
      ),
    );
  }

  /*
  _login() {
    if (_formKey.currentState!.validate()) {
      if (password.isNotEmpty) {
        BlocProvider.of<BlocAuth>(context).add(LoginEvent(password: password));
      } else {
        BlocProvider.of<BlocAuth>(context).add(LoginErrorEvent(
            exception:
                AuthException(code: -2, message: 'Password cannot be blank.')));
      }
    }
  }
  */

  String? validatorPassword(String value) {
    //final regExp = RegExp("^(?=.*[A-Z].*[A-Z])(?=.*[!@#\$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8}\$");
    // regExp.hasMatch(value)
  }
  /*
  Widget _formLogin() {
    return BlocBuilder<BlocAuth, AuthState>(buildWhen: (previousState, state) {
      if (state is LoggedInState) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
        BlocProvider.of<BlocDashboard>(context)
            .add(DashboardLoadEvent(dbWallet: state.wallet));
      }
      return true;
    }, builder: (context, state) {
      final deviceSize = MediaQuery.of(context).size;
      size = deviceSize;
      final cardWidth = min(deviceSize.width, 360.0);
      const cardPadding = 10.0;
      final textFieldWidth = cardWidth - (cardPadding * 2);
      return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // new CardHeader(
            //    title: 'Unlock Wallet', width: cardWidth, height: 50),
            Container(
              padding: EdgeInsets.only(
                left: cardPadding,
                right: cardPadding,
                top: cardPadding + 10,
              ),
              width: cardWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //AutoSizeText('Unlock Wallet',maxLines: 1,minFontSize: 14,),
                  _buildWalletField(context, textFieldWidth),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      // Navigate to the PreferencePage
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PreferencePage(),
                      ));
                    },
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
  */
  /*
  Widget _buttonLogin() {
    return BlocBuilder<BlocAuth, AuthState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        if (state is LoadingLoginState) {
          return Column(children: [
            ButtonLogin(
              isLoading: true,
              label: 'LOGIN ...',
              onPressed: () => {},
            ),
            SpinKitCircle(
              color: theme.primaryColor,
            )
          ]);
        } else if (state is LoggedInState) {
          return ButtonLogin(
            label: 'CONECTED!',
            onPressed: () => {},
          );
        } else if (state is LoginErrorState) {
          return Column(
            children: [
              ButtonLogin(
                label: 'login',
                onPressed: () => _login(),
              ),
              Text(
                '${state.exception.message}',
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
  */
  /*
  Widget _buildWalletField(BuildContext context, double width) {
    final theme = Theme.of(context);
    PathProviderInterface interface = PathProviderInterface();
    return Container(
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
                            Container(
                              child: AutoSizeText(
                                'Select Wallet:',
                                textAlign: TextAlign.left,
                              ),
                              alignment: Alignment.topLeft,
                            ),
                            WalletListWidget(
                              walletFiles: snapshot.data!,
                              width: width,
                            ),
                            _buildPasswordField(theme),
                            Padding(
                              padding: Paddings.fromLTR(10),
                              child: _buttonLogin(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Divider(
                                height: size.height * 0.014,
                                color: theme.primaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                widget.onCreateOrRecover();
                              },
                              child: Text(
                                'Create, import or recover a wallet',
                                textAlign: TextAlign.left,
                              ),
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
                      })
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
  */





  @override
  Widget build(BuildContext context) {
    //return _formLogin();
    return Flex(direction: Axis.vertical,
    children: [
      Padding(
          padding: const EdgeInsets.all(0),
          child: LoginForm())
    ],);
    return Padding(
      padding: const EdgeInsets.all(0),
      child: LoginForm());
    }
}
