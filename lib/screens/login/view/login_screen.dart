import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/login/view/login_form.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet_wallet/widgets/layouts/layout.dart';
import 'package:witnet_wallet/widgets/carousel.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/shared/api_database.dart';

final GlobalKey<LoginFormState> loginState = GlobalKey<LoginFormState>();

class LoginScreen extends StatefulWidget {
  static final route = '/';

  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  Wallet? currentWallet;
  String? loginError;
  List<String>? walletsList;
  List<Widget> componentsList = [];

  @override
  void initState() {
    super.initState();
    _getWallets();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _login() {
    try {
      BlocProvider.of<LoginBloc>(context)
          .add(LoginSubmittedEvent(password: currentWallet!.password));
    } catch (err) {
      rethrow;
    }
  }

  Widget _buttonLogin() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return PaddedButton(
          padding: EdgeInsets.only(top: 8, bottom: 0),
          text: 'Login',
          type: 'primary',
          onPressed: () => {
            if (loginState.currentState?.validate(force: true) == true)
              {_login()},
          },
        );
      },
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

  _setWallet(wallet) {
    setState(() {
      currentWallet = wallet;
    });
  }

  void _getWallets() async {
    WalletStorage walletStorage =
        await Locator.instance<ApiDatabase>().loadWalletsDatabase();
    List<String> walletNames = List<String>.from(walletStorage.wallets.keys);
    if (walletStorage.wallets.length > 0) {
      setState(() {
        walletsList = walletNames;
        componentsList = [
          ...mainComponents(),
          SizedBox(height: 16),
          LoginForm(
            key: loginState,
            currentWallet: walletNames[0],
            setWallet: (wallet) => {_setWallet(wallet)},
            loginError: loginError,
          ),
        ];
      });
    } else {
      setState(() {
        componentsList = mainComponents();
        walletsList = null;
      });
    }
  }

  List<Widget> mainComponents() {
    final theme = Theme.of(context);
    return [
      Padding(
        padding: EdgeInsets.only(left: 24, right: 24),
        child: witnetLogo(theme),
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

  Widget _buildLayout() {
    final theme = Theme.of(context);
    return Layout(
      navigationActions: [],
      widgetList: componentsList,
      actions: [
        walletsList != null
            ? _buttonLogin()
            : _buildInitialButtons(context, theme)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }
}
