import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

typedef void VoidCallback(Action? value);

class CreateImportWallet extends StatefulWidget {
  final Function nextAction;
  final Function secondaryAction;
  final Function prevAction;
  CreateImportWallet({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.secondaryAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => CreateImportWalletState();
}

class Action {
  String label;
  void action;

  Action({
    required this.label,
    required this.action,
  });
}

class CreateImportWalletState extends State<CreateImportWallet> {
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7, bottom: 7),
          child: _buildInitialButtons(context, theme),
        ),
        Padding(padding: EdgeInsets.all(7)),
      ],
    );
  }

  void prevAction() {
    LoginStatus status = BlocProvider.of<LoginBloc>(context).state.status;
    if (status != LoginStatus.LoginSuccess && status != LoginStatus.LoggedIn) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      Navigator.pushReplacementNamed(context, DashboardScreen.route);
    }
  }

  void createWallet() {
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.newWallet);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.newWallet));
  }

  void importWallet() {
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.imported);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.imported));
  }

  Action prev() {
    return Action(
      label: 'Back',
      action: prevAction,
    );
  }

  Action nextCreateAction() {
    return Action(
      label: 'Create new wallet',
      action: createWallet,
    );
  }

  Action nextImportAction() {
    return Action(
      label: 'Import wallet',
      action: importWallet,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(nextCreateAction));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.secondaryAction(nextImportAction));
    super.initState();
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
            child: svgThemeImage(theme,
                name: 'create-or-import-wallet', height: 152)),
        SizedBox(height: 16),
        Text(
          'Create or import your wallet',
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Text(
          'When you created your wallet, you probably wrote down the secret security phrase on a piece of paper. It looks like a list of 12 apparently random words.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Text(
            'If you did not keep the secret security phrase, you can still export a password-protected Xprv key from the settings of your existing wallet.',
            style: theme.textTheme.bodyLarge)
      ],
    );
  }
}
