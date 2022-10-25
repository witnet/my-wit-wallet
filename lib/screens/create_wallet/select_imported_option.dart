import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/carousel.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';

typedef void VoidCallback(NavAction? value);

class SelectImportedOption extends StatefulWidget {
  final Function nextAction;
  final Function secondaryAction;
  final Function prevAction;
  SelectImportedOption({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.secondaryAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => ImportedOptionState();
}

class ImportedOptionState extends State<SelectImportedOption> {
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      alignment: const Alignment(0, -1 / 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: _buildInitialButtons(context, theme),
          ),
          Padding(padding: EdgeInsets.all(8)),
        ],
      ),
    );
  }

  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    LoginStatus status = BlocProvider.of<LoginBloc>(context).state.status;
    if (type == WalletType.newWallet && status != LoginStatus.LoginSuccess) {
      Navigator.pushNamed(context, '/');
    } else {
      BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
    }
  }

  void nextSeedAction() {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.mnemonic);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.mnemonic));
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().walletType,
        data: {}));
  }

  void nextXprvAction() {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.encryptedXprv);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.encryptedXprv));
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().walletType,
        data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: 'Back',
      action: prevAction,
    );
  }

  NavAction nextSeed() {
    return NavAction(
      label: 'Import from seed phrase',
      action: nextSeedAction,
    );
  }

  NavAction nextXprv() {
    return NavAction(
      label: 'Import from xprv',
      action: nextXprvAction,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(nextSeed));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.secondaryAction(nextXprv));
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
          'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
        ]),
      ],
    );
  }
}
