import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_import_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/re_establish_wallet_disclaimer.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/screens/create_wallet/import_mnemonic_card.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/confirm_mnemonic_card.dart';
import 'package:my_wit_wallet/screens/create_wallet/disclaimer_card.dart';
import 'package:my_wit_wallet/screens/create_wallet/generate_mnemonic_card.dart';
import 'package:my_wit_wallet/screens/create_wallet/wallet_detail_card.dart';
import 'package:my_wit_wallet/screens/create_wallet/select_imported_option.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';

import 'build_wallet_card.dart';
import 'enc_xprv_card.dart';
import 'encrypt_wallet_card.dart';

class CreateWalletScreen extends StatefulWidget {
  static final route = '/create-wallet';
  @override
  CreateWalletScreenState createState() => CreateWalletScreenState();
}

class CreateWalletScreenState extends State<CreateWalletScreen> {
  ScrollController scrollController = ScrollController(keepScrollOffset: false);
  GlobalKey<EnterXprvCardState> walletConfigState =
      GlobalKey<EnterXprvCardState>();
  GlobalKey<EnterMnemonicCardState> enterMnemonicState =
      GlobalKey<EnterMnemonicCardState>();
  GlobalKey<ConfirmMnemonicCardState> confirmMnemonicState =
      GlobalKey<ConfirmMnemonicCardState>();
  GlobalKey<EncryptWalletCardState> encryptWalletState =
      GlobalKey<EncryptWalletCardState>();
  dynamic nextAction;
  dynamic secondaryAction;
  dynamic prevAction;
  bool clearActions = true;
  bool isLoading = false;
  bool hideButton = false;

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Bottom page actions
  List<Widget> _actions() {
    List<Widget> actions = [];

    if (!hideButton) {
      actions = [
        PaddedButton(
            padding: EdgeInsets.only(bottom: 0),
            text: nextAction != null
                ? nextAction().label
                : _localization.continueLabel,
            type: ButtonType.primary,
            isLoading: isLoading,
            enabled: nextAction != null,
            onPressed: () async {
              setState(() => isLoading = true);
              if (nextAction != null) await nextAction().action();
              if (clearActions) _clearNextActions();
              setState(() => isLoading = false);
            }),
      ];
    }
    if (secondaryAction != null) {
      actions = [
        ...actions,
        PaddedButton(
            padding: EdgeInsets.only(top: 8),
            text: nextAction != null ? secondaryAction().label : '',
            type: ButtonType.secondary,
            enabled: nextAction != null,
            onPressed: () => {
                  nextAction != null ? secondaryAction().action() : null,
                  _clearNextActions()
                }),
      ];
    }
    return actions;
  }

  List<Widget> _navigationActions() {
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          text: prevAction != null ? prevAction().label : '',
          type: ButtonType.text,
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
      scrollController: scrollController,
      navigationActions: _navigationActions(),
      widgetList: [
        _formCards(),
        if (_actions().length > 0)
          SizedBox(
            height: 32,
          ),
      ],
      actions: _actions(),
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

  _setClearActions(bool clearNextActions) {
    setState(() {
      clearActions = clearNextActions;
    });
  }

  _hideButton(bool hide) {
    setState(() {
      hideButton = hide;
    });
  }

  _navigationCards() {
    return {
      CreateWalletStatus.Disclaimer: DisclaimerCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.GenerateMnemonic: GenerateMnemonicCard(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.EnterMnemonic: EnterMnemonicCard(
          key: enterMnemonicState,
          nextAction: _setNextAction,
          prevAction: _setPrevAction),
      CreateWalletStatus.EnterXprv: EnterEncryptedXprvCard(
        key: walletConfigState,
        nextAction: _setNextAction,
        prevAction: _setPrevAction,
        clearActions: _setClearActions,
      ),
      CreateWalletStatus.ValidXprv: null,
      CreateWalletStatus.EnterEncryptedXprv: EnterEncryptedXprvCard(
        key: walletConfigState,
        nextAction: _setNextAction,
        prevAction: _setPrevAction,
        clearActions: _setClearActions,
      ),
      CreateWalletStatus.ConfirmMnemonic: ConfirmMnemonicCard(
          key: confirmMnemonicState,
          nextAction: _setNextAction,
          prevAction: _setPrevAction),
      CreateWalletStatus.WalletDetail: WalletDetailCard(
          nextAction: _setNextAction,
          prevAction: _setPrevAction,
          clearActions: _setClearActions),
      CreateWalletStatus.EncryptWallet: EncryptWalletCard(
        key: encryptWalletState,
        nextAction: _setNextAction,
        prevAction: _setPrevAction,
        clearActions: _setClearActions,
      ),
      CreateWalletStatus.BuildWallet: BuildWalletCard(
          nextAction: _setNextAction,
          prevAction: _setPrevAction,
          hideButton: _hideButton),
      CreateWalletStatus.Imported: SelectImportedOption(
        nextAction: _setNextAction,
        secondaryAction: _setSecondaryAction,
        prevAction: _setPrevAction,
        clearActions: _setClearActions,
      ),
      CreateWalletStatus.CreateImport: CreateImportWallet(
          nextAction: _setNextAction,
          secondaryAction: _setSecondaryAction,
          prevAction: _setPrevAction),
      CreateWalletStatus.Reset: ReEstablishWalletDisclaimer(
          nextAction: _setNextAction, prevAction: _setPrevAction),
      CreateWalletStatus.CreateWallet: null,
      CreateWalletStatus.Complete: Container(),
      CreateWalletStatus.Loading: null,
      CreateWalletStatus.LoadingException: null,
    };
  }

  _formCards() {
    return BlocListener<CreateWalletBloc, CreateWalletState>(
      listenWhen: (CreateWalletState prevState, CreateWalletState nextState) {
        if (prevState != nextState) {
          scrollController.jumpTo(0.0);
        }
        return true;
      },
      listener: (context, state) {},
      child: BlocBuilder<CreateWalletBloc, CreateWalletState>(
          builder: (context, state) {
        return Center(
          child: _navigationCards()[state.status],
        );
      }),
    );
  }
}
