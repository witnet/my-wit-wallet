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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Recovery Phrase',
          style: theme.textTheme.headline2,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          'Please type your $_phraseLength word seed phrase exactly as shown to you on the previous screen. This will ensure that you have noted down your seed phrase correctly.',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          style: theme.textTheme.headline2,
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
          height: 16,
        ),
        Text(
          'Please ensure you do not add any extra spaces between words or at the beginning or end of the phrase.',
          style: theme.textTheme.bodyText1,
        ),
      ],
    );
  }
}
