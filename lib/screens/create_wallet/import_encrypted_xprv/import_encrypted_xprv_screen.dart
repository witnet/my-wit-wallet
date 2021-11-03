import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '01_disclaimer_card.dart';
import '02_enc_xprv_card.dart';
import '03_wallet_detail_card.dart';
import '04_encrypt_wallet_card.dart';
import '05_build_wallet_card.dart';
import 'import_encrypted_xprv_bloc.dart';

class ImportEncryptedXprvScreen extends StatefulWidget {
  static final route = '/import_encrypted_xprv';
  @override
  _ImportXprvScreenState createState() => _ImportXprvScreenState();
}

class _ImportXprvScreenState extends State<ImportEncryptedXprvScreen> {
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
    return BlocBuilder<BlocImportEcnryptedXprv, ImportEncryptedXprvState>(
        builder: (context, state) {
      final theme = Theme.of(context);
      switch (state.runtimeType) {
        case ImportEncryptedXprvDisclaimerState:
          currentFormCard = DisclaimerCard();
          break;
        case EnterXprvState:
          currentFormCard = EnterXprvCard();
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
