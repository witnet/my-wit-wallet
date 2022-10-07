import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';

typedef void FunctionCallback(Function? value);

class SelectImportedOption extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  SelectImportedOption({
    Key? key,
    required FunctionCallback this.nextAction,
    required FunctionCallback this.prevAction,
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
            padding: EdgeInsets.only(top: 7, bottom: 7),
            child: _buildInitialButtons(context, theme),
          ),
          Padding(padding: EdgeInsets.all(7)),
        ],
      ),
    );
  }

  void prev() {
    Navigator.pop(context);
  }

  void nextSeed() {
    Locator.instance<ApiCreateWallet>()
      .setWalletType(WalletType.mnemonic);
    BlocProvider.of<CreateWalletBloc>(context)
      .add(ResetEvent(WalletType.mnemonic));
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().walletType,
        data: {}));
  }

  void nextXprv() {
    Locator.instance<ApiCreateWallet>()
      .setWalletType(WalletType.encryptedXprv);
    BlocProvider.of<CreateWalletBloc>(context)
      .add(ResetEvent(WalletType.encryptedXprv));
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().walletType,
        data: {}));
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(nextSeed));
    super.initState();
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Back',
              type: 'secondary',
              onPressed: () => widget.prevAction(prev),
          ),
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Import from seed phrase',
              type: 'primary',
              onPressed: () => widget.nextAction(nextSeed),
          ),
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Import from xprv file',
              type: 'primary',
              onPressed: () => nextXprv(),
          ),
        ],
      ),
    );
  }
}
