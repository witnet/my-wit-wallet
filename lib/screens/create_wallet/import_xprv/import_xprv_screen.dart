import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '01_disclaimer_card.dart';
import '02_xprv_card.dart';
import '03_wallet_detail_card.dart';
import '04_encrypt_wallet_card.dart';
import '05_build_wallet_card.dart';
import 'import_xprv_bloc.dart';

class ImportXprvScreen extends StatefulWidget {
  static final route = '/import_xprv';
  @override
  _ImportXprvScreenState createState() => _ImportXprvScreenState();
}

class _ImportXprvScreenState extends State<ImportXprvScreen> {
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
    return BlocBuilder<BlocImportXprv, ImportXprvState>(
        builder: (context, state) {
      final theme = Theme.of(context);
      switch (state.runtimeType) {
        case ImportXprvDisclaimerState:
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
