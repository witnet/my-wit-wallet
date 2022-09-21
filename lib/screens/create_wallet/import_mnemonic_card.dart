import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/crypto.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';

import 'bloc/create_wallet_bloc.dart';

//genius merge win culture lemon remember work native omit digital canal update

class EnterMnemonicCard extends StatefulWidget {
  EnterMnemonicCard({Key? key}) : super(key: key);

  EnterMnemonicCardState createState() => EnterMnemonicCardState();
}

class EnterMnemonicCardState extends State<EnterMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  final TextEditingController textController = TextEditingController();
  int numLines = 0;

  Widget _buildConfirmField() {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            AutoSizeText(
              'Please type your secret word phrase used for recovery. ',
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ), //Textstyle
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ), //Textstyle
            ), //Text
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void onBack() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void onNext() {
    Locator.instance<ApiCreateWallet>().setSeed(mnemonic, 'mnemonic');
    //WalletType type = BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().walletType,
        data: {}));
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

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: onBack,
            child: Text('Cancel'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: validMnemonic(mnemonic) ? onNext : null,
            child: Text('Confirm'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final cardWidth = min(deviceSize.width * 0.95, 360.0);
    const cardPadding = 10.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: cardWidth,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: deviceSize.height * 0.25,
                  width: deviceSize.width,
                  child: witnetLogo(theme),
                ),
                _buildConfirmField(),
                _buildButtonRow(),
              ]),
        ),
      ],
    );
  }
}
