import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/import_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/confirm_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/disclaimer_card.dart';
import 'package:witnet_wallet/screens/create_wallet/generate_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/wallet_detail_card.dart';

import 'build_wallet_card.dart';
import 'enc_xprv_card.dart';
import 'encrypt_wallet_card.dart';
import 'xprv_card.dart';

class CreateWalletScreen extends StatefulWidget {
  static final route = '/create_wallet';
  @override
  _CreateWalletScreenState createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  dynamic currentFormCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: _formCards(),
      ),
    );
  }

  _formCards() {
    return BlocBuilder<BlocCreateWallet, CreateWalletState>(
        builder: (context, state) {
      switch (state.runtimeType) {
        case DisclaimerState:
          currentFormCard = DisclaimerCard();
          break;
        case GenerateMnemonicState:
          currentFormCard = GenerateMnemonicCard();
          break;
        case EnterMnemonicState:
          currentFormCard = EnterMnemonicCard();
          break;
        case EnterXprvState:
          currentFormCard = EnterXprvCard();
          break;
        case EnterEncryptedXprvState:
          currentFormCard = EnterEncryptedXprvCard();
          break;
        case ConfirmMnemonicState:
          currentFormCard = ConfirmMnemonicCard();
          break;
        case WalletDetailState:
          currentFormCard = WalletDetailCard();
          break;
        case EncryptWalletState:
          currentFormCard = EncryptWalletCard();
          break;
        case BuildWalletState:
          currentFormCard = BuildWalletCard();
          break;
        case CompleteState:
          {
            currentFormCard = Container();
            BlocProvider.of<BlocCreateWallet>(context)
                .add(ResetEvent(WalletType.newWallet));
          }
        //case ResetState: break;
      }

      return Center(
        child: currentFormCard,
      );
    });
  }
}
