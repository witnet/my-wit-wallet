import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/carousel.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';

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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashboardScreen()));
  }

  void createWallet() {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.newWallet);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.newWallet));
  }

  void importWallet() {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.imported);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.imported));
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/img/witty.png',
          width: 152,
          height: 152,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(height: 16),
        Text(
          'Import a wallet',
          style: theme.textTheme.headline1,
        ),
        Carousel(list: [
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
          'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
          'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'
        ]),
      ],
    );
  }
}
