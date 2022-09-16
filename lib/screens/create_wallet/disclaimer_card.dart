import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/util/color.dart';

class DisclaimerCard extends StatefulWidget {
  DisclaimerCard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DisclaimerCardState();
}

class DisclaimerCardState extends State<DisclaimerCard>
    with TickerProviderStateMixin {
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

    this._loadingController = AnimationController(
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
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;

    print('type: ${type.name}');
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  Widget _buildDisclaimerTextScrollView(ThemeData theme, double height) {
    return Container(
        alignment: Alignment.topLeft,
        height: height,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                Row(children: [
                  Text(
                    'Please, read carefully before continuing.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ]),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'A wallet is an app that keeps your credentials safe and lets you interface with the Witnet blockchain in many ways: from transferring Wit to someone else to creating smart contracts.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'You should never share your seed phrase with anyone. We at Witnet do not store your seed phrase and will never ask you to share it with us. If you lose your seed phrase, you will permanently lose access to your wallet and your funds.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'If someone sees your seed phrase, they will have access to your wallet and all of your funds.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'We recommend storing your seed phrase on paper somewhere safe. Do not store it in a file on your computer or anywhere electronically.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'By accepting these disclaimers, you commit to comply with the explained restrictions and digitally sign your conformance using your Witnet wallet.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // FIXME: Remove input padding
                CheckboxListTile(
                  activeColor: Colors.cyan,
                  title: Text(
                    "I will be careful, I promise!",
                    // textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
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
        ]));
  }

  Widget _buildButtonRowNext() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: acceptedDisclaimer ? _nextCreateWalletMode : null,
        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
        child: Text('Continue',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
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
    final systembarHeight = MediaQuery.of(context).viewPadding.top;
    final systemBarPaddingTop = MediaQuery.of(context).viewPadding.top + 24;
    final double headerHeight = deviceSize.height *
        0.23; // according to the design almost 1 / 5 of the total height
    final double buttonFooterHeight =
        24 + 24 + 50; // padding bottom + padding top + button height
    final double contentHeight =
        deviceSize.height - headerHeight - buttonFooterHeight - systembarHeight;
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: deviceSize.width,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: systemBarPaddingTop),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(2, 29, 48, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.elliptical(
                        deviceSize.width, deviceSize.width / 4.5),
                    bottomRight: Radius.elliptical(
                        deviceSize.width, deviceSize.width / 4.5),
                  ),
                ),
                height: headerHeight,
                width: deviceSize.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(children: [
                          // TextButton has a default padding
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(16),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Back',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Row(children: [
                            Expanded(
                                child: Text("Create Wallet",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)))
                          ]))
                    ]),
              ),
              _buildDisclaimerTextScrollView(theme, contentHeight),
              _buildButtonRowNext(),
            ],
          ),
        ),
      ],
    );
  }
}
