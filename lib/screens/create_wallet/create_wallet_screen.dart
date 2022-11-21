import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_import_wallet.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/screens/create_wallet/import_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/confirm_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/disclaimer_card.dart';
import 'package:witnet_wallet/screens/create_wallet/generate_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/wallet_detail_card.dart';
import 'package:witnet_wallet/screens/create_wallet/select_imported_option.dart';
import 'package:witnet_wallet/widgets/layouts/layout.dart';

import 'build_wallet_card.dart';
import 'enc_xprv_card.dart';
import 'encrypt_wallet_card.dart';
import 'xprv_card.dart';

class CreateWalletScreen extends StatefulWidget {
  static final route = '/create-wallet';
  @override
  CreateWalletScreenState createState() => CreateWalletScreenState();
}

class CreateWalletScreenState extends State<CreateWalletScreen> {
  dynamic nextAction;
  dynamic secondaryAction;
  dynamic prevAction;
  double bottomSize = 80;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  List<Widget> _navigationActions() {
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
      navigationActions: _navigationActions(),
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

  _navigationCards() {
    return {
      CreateWalletStatus.Disclaimer: DisclaimerCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.GenerateMnemonic: GenerateMnemonicCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.EnterMnemonic: EnterMnemonicCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.EnterXprv:
          EnterXprvCard(nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.ValidXprv: null,
      CreateWalletStatus.EnterEncryptedXprv: EnterEncryptedXprvCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.ConfirmMnemonic: ConfirmMnemonicCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.WalletDetail: WalletDetailCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.EncryptWallet: EncryptWalletCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.BuildWallet: BuildWalletCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.Imported: SelectImportedOption(
          nextAction: _setNextAction,
          secondaryAction: _setSecondaryAction,
          prevAction: _setPrevAction),
      CreateWalletStatus.CreateImport: CreateImportWallet(
          nextAction: _setNextAction,
          secondaryAction: _setSecondaryAction,
          prevAction: _setPrevAction),
      CreateWalletStatus.CreateWallet: null,
      CreateWalletStatus.Complete: Container(),
      CreateWalletStatus.Loading: null,
      CreateWalletStatus.LoadingException: null,
      CreateWalletStatus.Reset: null,
    };
  }

  _formCards() {
    return BlocBuilder<CreateWalletBloc, CreateWalletState>(
        builder: (context, state) {
      // TODO: DELETE IF UNNECESSARY
      // if (state.status == CreateWalletStatus.Complete) {
      //   BlocProvider.of<CreateWalletBloc>(context)
      //       .add(ResetEvent(WalletType.unset));
      // }
      return Center(
        child: _navigationCards()[state.status],
      );
    });
  }
}
