import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/crypto.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';

class ConfirmMnemonicCard extends StatefulWidget {
  ConfirmMnemonicCard({Key? key}) : super(key: key);

  ConfirmMnemonicCardState createState() => ConfirmMnemonicCardState();
}

class ConfirmMnemonicCardState extends State<ConfirmMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  final TextEditingController textController = TextEditingController();
  int numLines = 0;
  int _phraseLength = 12;

  Widget _buildConfirmField() {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 10,
            ), //SizedBox
            Text(
              'Recovery Phrase',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ), //Textstyle
            ), //Text
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
                setState(() {
                  print(e);
                  mnemonic = textController.value.text;
                  numLines = '\n'.allMatches(e).length + 1;
                });
              },
              decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0))),
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
        ),
      ),
    );
  }

  void onBack() {
    WalletType type = BlocProvider.of<BlocCreateWallet>(context).state.type;
    BlocProvider.of<BlocCreateWallet>(context).add(PreviousCardEvent(type));
  }

  void onNext() {
    WalletType type = BlocProvider.of<BlocCreateWallet>(context).state.type;
    BlocProvider.of<BlocCreateWallet>(context).add(NextCardEvent(type));
  }

  bool validMnemonic(String mnemonic) {
    assert(Locator.instance.get<ApiCreateWallet>().seedSource == 'mnemonic');
    String _mn = Locator.instance.get<ApiCreateWallet>().seedData!;
    if (mnemonic != _mn) return false;
    return validateMnemonic(mnemonic);
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: onBack,
            child: Text('Go back!'),
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
    return FittedBox(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 50,
              width: cardWidth,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0))),
              child: Padding(
                padding: EdgeInsets.only(top: 1),
                child: Text(
                  'Confirm Word Phrase',
                  style: theme.textTheme.headline4,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: cardPadding,
                right: cardPadding,
                top: cardPadding + 10,
              ),
              width: cardWidth,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildConfirmField(),
                    _buildButtonRow(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
