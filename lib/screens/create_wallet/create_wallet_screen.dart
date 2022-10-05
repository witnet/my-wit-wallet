import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/screens/create_wallet/import_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/confirm_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/disclaimer_card.dart';
import 'package:witnet_wallet/screens/create_wallet/generate_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/wallet_detail_card.dart';
import 'package:witnet_wallet/screens/create_wallet/select_imported_option.dart';
import 'package:witnet_wallet/widgets/layout.dart';

import 'build_wallet_card.dart';
import 'enc_xprv_card.dart';
import 'encrypt_wallet_card.dart';
import 'xprv_card.dart';

class CreateWalletScreen extends StatefulWidget {
  static final route = '/create_wallet';
  @override
  CreateWalletScreenState createState() => CreateWalletScreenState();
}

class CreateWalletScreenState extends State<CreateWalletScreen> {
  dynamic currentFormCard;
  dynamic nextAction;
  dynamic prevAction;

  @override
  Widget build(BuildContext context) {
    return Layout(
      widgetList: [
        _formCards(),
      ],
      actions: [
        PaddedButton(
          padding: EdgeInsets.all(5),
          text: 'Continue',
          type: 'primary',
          enabled: nextAction != null,
          onPressed: () => nextAction != null ? nextAction() : null,
        ),
        PaddedButton(
          padding: EdgeInsets.all(5),
          text: 'Back',
          type: 'secondary',
          onPressed: () => prevAction != null ? prevAction() : null,
        ),
      ],
      actionsSize: 150,
    );
  }

  _setNextAction(action) {
    setState(() {
      nextAction = action;
    });
  }

  _setPrevAction(action) {
    setState(() {
      prevAction = action;
    });
  }


  _formCards() {
    return BlocBuilder<CreateWalletBloc, CreateWalletState>(
        builder: (context, state) {
      switch (state.status) {
        case CreateWalletStatus.Disclaimer:
          currentFormCard = DisclaimerCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.GenerateMnemonic:
          currentFormCard = GenerateMnemonicCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.EnterMnemonic:
          currentFormCard = EnterMnemonicCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.EnterXprv:
          currentFormCard = EnterXprvCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.ValidXprv:
          break;
        case CreateWalletStatus.EnterEncryptedXprv:
          currentFormCard = EnterEncryptedXprvCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.ConfirmMnemonic:
          currentFormCard = ConfirmMnemonicCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.WalletDetail:
          currentFormCard = WalletDetailCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.EncryptWallet:
          currentFormCard = EncryptWalletCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.BuildWallet:
          currentFormCard = BuildWalletCard(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.Imported:
          currentFormCard = SelectImportedOption(nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.CreateWallet:
          // TODO: Handle this case.
          break;
        case CreateWalletStatus.Complete:
          {
            currentFormCard = Container();
            BlocProvider.of<CreateWalletBloc>(context)
                .add(ResetEvent(WalletType.newWallet));
          }
          break;
        case CreateWalletStatus.Loading:
          break;
        case CreateWalletStatus.LoadingException:
          break;
        case CreateWalletStatus.Reset:
          break;
      }

      return Center(
        child: currentFormCard,
      );
    });
  }
}
