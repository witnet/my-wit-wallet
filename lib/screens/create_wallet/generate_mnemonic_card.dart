import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

typedef void VoidCallback(NavAction? value);

class GenerateMnemonicCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  GenerateMnemonicCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  GenerateMnemonicCardState createState() => GenerateMnemonicCardState();
}

class GenerateMnemonicCardState extends State<GenerateMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  String _language = 'English';
  int _radioWordCount = 12;

  Future<String?> _genMnemonic() async {
    final theme = Theme.of(context);
    try {
      return await Locator.instance
          .get<ApiCrypto>()
          .generateMnemonic(_radioWordCount, _language);
    } catch (err) {
      showErrorSnackBarWithTimeout(
        context: context,
        theme: theme,
        text: 'Error generating mnemonics',
        log: '$err',
      );
      return null;
    }
  }

  Widget _buildInfoTextScrollBox(Size deviceSize) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.generateMnemonic01(_radioWordCount),
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          localization.generateMnemonic02,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          localization.generateMnemonic03,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildMnemonicBox(theme) {
    return FutureBuilder(
        future: _genMnemonic(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            mnemonic = snapshot.data as String;
            return DashedRect(
              color: Colors.grey,
              strokeWidth: 1.0,
              gap: 3.0,
              text: mnemonic,
            );
          }
          return Center(
            child: SpinKitCircle(
              color: theme.primaryColor,
            ),
          );
        });
  }

  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    Locator.instance.get<ApiCreateWallet>().setSeed(mnemonic, 'mnemonic');
    Locator.instance.get<ApiCreateWallet>().setWalletType(WalletType.hd);
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: localization.backLabel,
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: localization.continueLabel,
      action: nextAction,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        localization.generateMnemonicHeader,
        style: theme.textTheme.titleLarge,
      ),
      SizedBox(
        height: 16,
      ),
      _buildMnemonicBox(theme),
      SizedBox(
        height: 16,
      ),
      _buildInfoTextScrollBox(deviceSize),
    ]);
  }
}
