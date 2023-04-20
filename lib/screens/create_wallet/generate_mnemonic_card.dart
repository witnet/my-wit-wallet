import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/dashed_rect.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';

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

  Future<String> _genMnemonic() async {
    return await Locator.instance
        .get<ApiCrypto>()
        .generateMnemonic(_radioWordCount, _language);
  }

  Widget _buildInfoTextScrollBox(Size deviceSize) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'These $_radioWordCount apparently random words are your secret recovery phrase. They will allow you to recover your Wit coins if you uninstall this app or forget your wallet lock password.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'You must write down your secret recovery phrase on a piece of paper and store it somewhere safe. Do not store it in a file in your device or anywhere else electronically. If you lose your secret recovery phrase, you may permanently lose access to your wallet and your Wit coins.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'You should never share your secret recovery phrase with anyone. If someone finds or sees your secret recovery phrase, they will have full access to your wallet and your Wit coins.',
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
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    Locator.instance.get<ApiCreateWallet>().setSeed(mnemonic, 'mnemonic');
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: 'Back',
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
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
        'Write down your secret recovery phrase',
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
