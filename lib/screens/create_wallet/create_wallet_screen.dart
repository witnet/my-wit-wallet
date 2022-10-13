import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/import_mnemonic_card.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
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
    return BlocBuilder<CreateWalletBloc, CreateWalletState>(

        builder: (context, state) {

      switch (state.status) {

        case CreateWalletStatus.Disclaimer:
          currentFormCard = DisclaimerCard();
          break;
        case CreateWalletStatus.GenerateMnemonic:
          currentFormCard = GenerateMnemonicCard();
          break;
        case CreateWalletStatus.EnterMnemonic:
          currentFormCard = EnterMnemonicCard();
          break;
        case CreateWalletStatus.EnterXprv:
          currentFormCard = EnterXprvCard();
          break;
        case CreateWalletStatus.ValidXprv: break;
        case CreateWalletStatus.EnterEncryptedXprv:
          currentFormCard = EnterEncryptedXprvCard();
          break;
        case CreateWalletStatus.ConfirmMnemonic:
          currentFormCard = ConfirmMnemonicCard();
          break;
        case CreateWalletStatus.WalletDetail:
          currentFormCard = WalletDetailCard();
          break;
        case CreateWalletStatus.EncryptWallet:
          currentFormCard = EncryptWalletCard();
          break;
        case CreateWalletStatus.BuildWallet:
          currentFormCard = BuildWalletCard();
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
        case CreateWalletStatus.Loading:break;
        case CreateWalletStatus.LoadingException:break;
        case CreateWalletStatus.Reset:break;
      }

      return Center(
        child: currentFormCard,
      );
    });
  }
}
