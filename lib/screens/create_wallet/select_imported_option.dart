import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';

class SelectImportedOption extends StatefulWidget {
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

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Back',
              onPressed: () {
                Navigator.pop(context);
              }),
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Import from seed phrase',
              onPressed: () {
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.mnemonic);
                BlocProvider.of<CreateWalletBloc>(context)
                    .add(ResetEvent(WalletType.mnemonic));
              }),
          PaddedButton(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              text: 'Import from xprv file',
              onPressed: () {
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.encryptedXprv);
                BlocProvider.of<CreateWalletBloc>(context)
                    .add(ResetEvent(WalletType.encryptedXprv));
              }),
        ],
      ),
    );
  }
}
