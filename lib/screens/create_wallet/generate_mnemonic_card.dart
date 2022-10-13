import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/widgets/dashed_rect.dart';

class GenerateMnemonicCard extends StatefulWidget {
  GenerateMnemonicCard({Key? key}) : super(key: key);
  GenerateMnemonicCardState createState() => GenerateMnemonicCardState();
}

class GenerateMnemonicCardState extends State<GenerateMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  String _language = 'English';
  int _radioWordCount = 12;



  void _setLanguage(String language) {
    setState(() {
      _language = language;
    });
  }

  void _handleWordCountChange(int? _count) {
    setState(() {
      _radioWordCount = _count!;
    });
  }

  Future<String> _genMnemonic() async {
    return await Locator.instance
        .get<ApiCrypto>()
        .generateMnemonic(_radioWordCount, _language);
  }

  Widget _buildMnemonicLanguageSelector() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Text(
            'Select Language:',
            style: new TextStyle(fontSize: 16.0),
          ),
          DropdownButton<String>(
            value: _language,
            //elevation: 5,
            items: <String>[
              'ChineseSimplified',
              'ChineseTraditional',
              'English',
              'French',
              'Italian',
              'Japanese',
              'Korean',
              'Spanish',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(), // items
            hint: Text(
              "Please choose a langauage",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            onChanged: (String? value) {
              _setLanguage(value!);
            },
          ),
        ],
      ),
    ]);
  }

  Widget _buildMnemonicLengthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            new Text(
              'Phrase Length:',
              style: new TextStyle(
                fontSize: 16.0,
              ),
            ),
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    new Radio(
                      value: 12,
                      groupValue: _radioWordCount,
                      onChanged: _handleWordCountChange,
                    ),
                    new Text(
                      '12',
                      style: new TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    new Radio(
                      value: 15,
                      groupValue: _radioWordCount,
                      onChanged: _handleWordCountChange,
                    ),
                    new Text(
                      '15',
                      style: new TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    new Radio(
                      value: 18,
                      groupValue: _radioWordCount,
                      onChanged: _handleWordCountChange,
                    ),
                    new Text(
                      '18',
                      style: new TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    new Radio(
                      value: 21,
                      groupValue: _radioWordCount,
                      onChanged: _handleWordCountChange,
                    ),
                    new Text(
                      '21',
                      style: new TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    new Radio(
                      value: 24,
                      groupValue: _radioWordCount,
                      onChanged: _handleWordCountChange,
                    ),
                    new Text(
                      '24',
                      style: new TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTextScrollBox(Size deviceSize) {
    return Container(
      height: deviceSize.height * 0.5,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'These $_radioWordCount random words are your Witnet seed phrase. They will allow you to recover your tokens if you uninstall this application or forget your password:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Please write down these $_radioWordCount words on a piece of paper and store them somewhere private and secure. You must write the complete words in the exact order they are presented to you.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Keeping your seed phrase secret is paramount. If someone gains access to these $_radioWordCount words, they will be able to take and spend your tokens.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Do not store these words on a computer or an electronic device. It is your sole responsibility to store the paper with your seed phrase in a safe place -',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'if you exit this setup or fail to write down or keep your seed phrase safe, we cannot help you access your wallet.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _buildMnemonicLanguageSelector(),
              _buildMnemonicLengthSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMnemonicBox() {
    return FutureBuilder(
        future: _genMnemonic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              mnemonic = snapshot.data as String;
              return DashedRect(
                color: Colors.grey,
                strokeWidth: 1.0,
                gap: 3.0,
                text: mnemonic,
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void onBack() {
    WalletType type = BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void onNext() {
    Locator.instance.get<ApiCreateWallet>().setSeed(mnemonic, 'mnemonic');
    WalletType type = BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(type, data: {}));
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 10),
          child: ElevatedButton(
            onPressed: onBack,
            child: Text('Back'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 5, bottom: 10),
          child: ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: mnemonic));
            },
            child: Text('Copy'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 5, bottom: 10),
          child: ElevatedButton(
            onPressed: onNext,
            child: Text('Next'),
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

                    _buildMnemonicBox(),
                    SizedBox(
                      height: 10,
                    ),
                    _buildInfoTextScrollBox(deviceSize),
                    _buildButtonRow(),
                  ]),
            ),
          ],
        );
  }
}
