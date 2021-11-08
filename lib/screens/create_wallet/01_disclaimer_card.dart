import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/widgets/card/card_header.dart';

class DisclaimerCard extends StatefulWidget {
  DisclaimerCard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DisclaimerCardState();
}

class DisclaimerCardState extends State<DisclaimerCard>
    with TickerProviderStateMixin {
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool scrolledToBottom = false;
  late ScrollController _scrollController;
  late AnimationController _loadingController;
  List<AnimationController> _providerControllerList = <AnimationController>[];
  bool _isLoading = false;
  var _isSubmitting = false;
  bool acceptedDisclaimer = false;
  bool get buttonEnabled => !_isLoading && !_isSubmitting;
  String mnemonic = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          // You're at the top.
        } else {
          scrolledToBottom = true;
        }
      }
    });
    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    )..value = 1.0;
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _providerControllerList.forEach((controller) {
      controller.dispose();
    });
  }

  void _nextCreateWalletMode() {
    BlocProvider.of<BlocCreateWallet>(context).add(NextCardEvent());
  }

  Widget _buildDisclaimerTextScrollView(ThemeData theme, Size deviceSize) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black45)),
      height: deviceSize.height * 0.6,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Hey, listen!\nPlease, read carefully before continuing.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'A wallet is an app that keeps your credentials safe and lets you interface with the Witnet blockchain in many ways: from transferring Wit to someone else to creating smart contracts.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'You should never share your seed phrase with anyone. We at Witnet do not store your seed phrase and will never ask you to share it with us. If you lose your seed phrase, you will permanently lose access to your wallet and your funds.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'If someone finds or sees your seed phrase, they will have access to your wallet and all of your funds.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'We recommend storing your seed phrase on paper somewhere safe. Do not store it in a file on your computer or anywhere electronically.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'By accepting these disclaimers, you commit to comply with the explained restrictions and digitally sign your conformance using your Witnet wallet.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              CheckboxListTile(
                activeColor: Colors.cyan,
                title: Text(
                  "I will be careful,\nI promise!",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: acceptedDisclaimer,
                onChanged: (value) {
                  setState(() {
                    print(value);
                    acceptedDisclaimer = !acceptedDisclaimer;
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go back!'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: mnemonic.isNotEmpty
                  ? () {
                      Clipboard.setData(ClipboardData(text: mnemonic));
                    }
                  : null,
              child: Text('Copy'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: acceptedDisclaimer ? _nextCreateWalletMode : null,
              child: Text('Confirm'),
            ),
          ),
        ],
      ),
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
            new CardHeader(title: 'DISCLAIMER', width: cardWidth, height: 50),
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
                    _buildDisclaimerTextScrollView(theme, deviceSize),
                    _buildButtonRow(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
