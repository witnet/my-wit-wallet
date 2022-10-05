import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/crypto.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'bloc/create_wallet_bloc.dart';

//genius merge win culture lemon remember work native omit digital canal update
typedef void FunctionCallback(Function? value);

class EnterMnemonicCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  EnterMnemonicCard({
    Key? key,
    required FunctionCallback this.nextAction,
    required FunctionCallback this.prevAction,
  }) : super(key: key);

  EnterMnemonicCardState createState() => EnterMnemonicCardState();
}

class EnterMnemonicCardState extends State<EnterMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  final TextEditingController textController = TextEditingController();
  int numLines = 0;

  Widget _buildConfirmField() {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        AutoSizeText(
          'Please type your secret word phrase used for recovery. ',
          maxLines: 1,
          style: theme.textTheme.bodyText1, //Textstyle
        ), //Text
        SizedBox(
          height: 10,
        ),

        TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          controller: textController,
          onChanged: (String e) {
            setState(() {
              mnemonic = textController.value.text;
              numLines = '\n'.allMatches(e).length + 1;
            });
          },
        ),
        SizedBox(
          height: 10,
        ),
        AutoSizeText(
          'Please ensure you do not add any extra spaces between words or at the beginning or end of the phrase.',
          maxLines: 2,
          style: theme.textTheme.bodyText1, //Textstyle
        ), //Text
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
    Locator.instance<ApiCreateWallet>().setSeed(mnemonic, 'mnemonic');
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().walletType,
        data: {}));
  }

  @override
  void initState() {
    print('import mnemonic card');
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    super.initState();
  }


  bool validMnemonic(String mnemonic) {
    List<String> words = mnemonic.split(' ');
    int wordCount = words.length;
    List<int> validMnemonicLengths = [12, 15, 18, 24];
    if (validMnemonicLengths.contains(wordCount)) {
      if (words.last.isEmpty) {
        return false;
      } else {
        try {
          var tmp = validateMnemonic(mnemonic);
          return tmp;
        } catch (e) {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildConfirmField(),
    ]);
  }
}
