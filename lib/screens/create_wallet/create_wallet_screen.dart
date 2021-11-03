import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/03_confirm_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/01_disclaimer_card.dart';
import 'package:witnet_wallet/screens/create_wallet/05_encrypt_wallet_card.dart';
import 'package:witnet_wallet/screens/create_wallet/02_generate_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/04_wallet_detail_card.dart';

import '06_build_wallet_card.dart';

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
        final theme = Theme.of(context);
        switch(state.runtimeType) {
          case DisclaimerState: currentFormCard = DisclaimerCard();break;
          case GenerateMnemonicState: currentFormCard = GenerateMnemonicCard();break;
          case ConfirmMnemonicState: currentFormCard = ConfirmMnemonicCard();break;
          case WalletDetailState: currentFormCard = WalletDetailCard();break;
          case EncryptWalletState: currentFormCard = EncryptWalletCard();break;
          case BuildWalletState: currentFormCard = BuildWalletCard();break;
          case CompleteState: break;
          case ResetState: break;
        }

      return Center(
        child: currentFormCard,
      );
    });
  }
}