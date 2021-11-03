import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/import_mnemonic/import_mnemonic_bloc.dart';
import '01_disclaimer_card.dart';
import '02_mnemonic_card.dart';
import '03_wallet_detail_card.dart';
import '04_encrypt_wallet_card.dart';
import '05_build_wallet_card.dart';

class ImportMnemonicScreen extends StatefulWidget {
  static final route = '/import_mnemonic';
  @override
  _CreateWalletScreenState createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<ImportMnemonicScreen> {
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
    return BlocBuilder<BlocImportMnemonic, ImportMnemonicState>(
        builder: (context, state) {
      final theme = Theme.of(context);
      switch (state.runtimeType) {
        case ImportMnemonicDisclaimerState:
          currentFormCard = DisclaimerCard();
          break;
        case EnterMnemonicState:
          currentFormCard = EnterMnemonicCard();
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
      }

      return Center(
        child: currentFormCard,
      );
    });
  }
}
