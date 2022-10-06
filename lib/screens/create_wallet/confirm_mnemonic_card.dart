import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/crypto.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';

typedef void FunctionCallback(Function? value);

class ConfirmMnemonicCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  ConfirmMnemonicCard({
    Key? key,
    required FunctionCallback this.nextAction,
    required FunctionCallback this.prevAction,
  }) : super(key: key);

  ConfirmMnemonicCardState createState() => ConfirmMnemonicCardState();
}

class ConfirmMnemonicCardState extends State<ConfirmMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  final TextEditingController textController = TextEditingController();
  int numLines = 0;
  int _phraseLength = 12;

  Widget _buildConfirmField() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          'Recovery Phrase',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Please type your $_phraseLength word seed phrase exactly as shown to you on the previous screen. This will ensure that you have noted down your seed phrase correctly.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          controller: textController,
          onChanged: (String e) {
            if (validMnemonic(textController.value.text)) {
              widget.nextAction(next);
            } else {
              widget.nextAction(null);
            }
            setState(() {
              mnemonic = textController.value.text;
              numLines = '\n'.allMatches(e).length + 1;
            });
          },
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Please ensure you do not add any extra spaces between words or at the beginning or end of the phrase.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  void prev() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void next() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  bool validMnemonic(String mnemonic) {
    assert(Locator.instance.get<ApiCreateWallet>().seedSource == 'mnemonic');
    String _mn = Locator.instance.get<ApiCreateWallet>().seedData!;
    if (mnemonic != _mn) return false;
    return validateMnemonic(mnemonic);
  }

  @override
  void initState() {
    print('confirm mnemonic card');
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildConfirmField(),
        ]);
  }
}
