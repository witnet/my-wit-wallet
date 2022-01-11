import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/styled_button.dart';

class CreateOrRecoverCard extends StatefulWidget {
  CreateOrRecoverCard({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  final Function onBack;
  @override
  CreateOrRecoverCardState createState() => CreateOrRecoverCardState();
}

class CreateOrRecoverCardState extends State<CreateOrRecoverCard>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;

  bool _showShadow = true;
  final _formKey = GlobalKey<FormState>();
  var size;
  late AnimationController _logoController;
  late AnimationController _titleController;
  static const loadingDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _logoController.forward();
          _titleController.forward();
        }
        if (status == AnimationStatus.reverse) {
          _logoController.reverse();
          _titleController.reverse();
        }
      });
    _logoController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );
    _titleController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: StyledButton(
              // double.infinity is the width and 30 is the height
              minimumSize: Size(double.infinity, 30),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 30),
              ),
              child: new Text('Create New Wallet'),
              onPressed: () {
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.newWallet);
                Navigator.pushNamed(context, CreateWalletScreen.route);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: StyledButton(
              // double.infinity is the width and 30 is the height
              minimumSize: Size(double.infinity, 30),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 30),
              ),
              child: new Text('Recover Wallet from Secret Word Phrase'),
              onPressed: () {
                BlocProvider.of<BlocCrypto>(context).add(CryptoReadyEvent());
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.mnemonic);
                Navigator.pushNamed(context, CreateWalletScreen.route);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              // double.infinity is the width and 30 is the height

              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 30),
              ),
              child: new Text('Import Node from XPRV'),
              onPressed: null,
              // {
              //   Locator.instance<ApiCreateWallet>()
              //       .setWalletType(WalletType.xprv);
              //   Navigator.pushNamed(context, CreateWalletScreen.route);
              // },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: StyledButton(
              // double.infinity is the width and 30 is the height
              minimumSize: Size(double.infinity, 30),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 30),
              ),
              child: new Text('Import Wallet from Encrypted XPRV'),
              onPressed: () {
                Locator.instance<ApiCreateWallet>()
                    .setWalletType(WalletType.encryptedXprv);
                Navigator.pushNamed(context, CreateWalletScreen.route);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _formLogin() {
    final deviceSize = MediaQuery.of(context).size;
    size = deviceSize;
    final cardWidth = min(deviceSize.width * 0.95, 360.0);
    const cardPadding = 10.0;
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
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
                _buildInitialButtons(context, theme),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(
                    height: size.height * 0.014,
                    color: theme.primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onBack();
                  },
                  child: Text(
                    'Back to Login',
                    textAlign: TextAlign.left,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to the PreferencePage
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PreferencePage(),
                    ));
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(child: _formLogin());
  }
}
