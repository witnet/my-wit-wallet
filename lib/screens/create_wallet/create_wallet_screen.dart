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
  dynamic secondaryAction;
  dynamic prevAction;
  double bottomSize = 80;

  List<Widget> _actions() {
    List<Widget> actions = [
      PaddedButton(
          padding: EdgeInsets.only(bottom: 8),
          text: nextAction != null ? nextAction().label : 'Continue',
          type: 'primary',
          enabled: nextAction != null,
          onPressed: () => {
                nextAction != null ? nextAction().action() : null,
                _clearNextActions()
              }),
    ];
    if (secondaryAction != null) {
      actions = [
        ...actions,
        PaddedButton(
            padding: EdgeInsets.only(bottom: 8),
            text: nextAction != null ? secondaryAction().label : '',
            type: 'primary',
            enabled: nextAction != null,
            onPressed: () => {
                  nextAction != null ? secondaryAction().action() : null,
                  _clearNextActions()
                }),
      ];
      bottomSize = 120;
    }
    return actions;
  }

  List<Widget> _headerActions() {
    return [
      PaddedButton(
          padding: EdgeInsets.only(bottom: 8),
          text: prevAction != null ? prevAction().label : '',
          type: 'text',
          enabled: prevAction != null,
          onPressed: () => {
                prevAction != null ? prevAction().action() : null,
                _clearAllActions()
              }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      headerActions: _headerActions(),
      widgetList: [
        _formCards(),
      ],
      actions: _actions(),
      actionsSize: bottomSize,
    );
  }

  _clearNextActions() {
    nextAction = null;
    secondaryAction = null;
  }

  _clearAllActions() {
    nextAction = null;
    prevAction = null;
    secondaryAction = null;
  }

  _setNextAction(action) {
    setState(() {
      nextAction = action;
    });
  }

  _setSecondaryAction(action) {
    setState(() {
      secondaryAction = action;
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
          currentFormCard = DisclaimerCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.GenerateMnemonic:
          currentFormCard = GenerateMnemonicCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.EnterMnemonic:
          currentFormCard = EnterMnemonicCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.EnterXprv:
          currentFormCard = EnterXprvCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.ValidXprv:
          break;
        case CreateWalletStatus.EnterEncryptedXprv:
          currentFormCard = EnterEncryptedXprvCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.ConfirmMnemonic:
          currentFormCard = ConfirmMnemonicCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.WalletDetail:
          currentFormCard = WalletDetailCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.EncryptWallet:
          currentFormCard = EncryptWalletCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.BuildWallet:
          currentFormCard = BuildWalletCard(
              nextAction: _setNextAction, prevAction: _setPrevAction);
          break;
        case CreateWalletStatus.Imported:
          currentFormCard = SelectImportedOption(
              nextAction: _setNextAction,
              secondaryAction: _setSecondaryAction,
              prevAction: _setPrevAction);
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
