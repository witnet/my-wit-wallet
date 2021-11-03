import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'import_encrypted_xprv_bloc.dart';

class WalletDetailCard extends StatefulWidget {
  WalletDetailCard({Key? key}) : super(key: key);
  WalletDetailCardState createState() => WalletDetailCardState();
}

class WalletDetailCardState extends State<WalletDetailCard>
    with TickerProviderStateMixin {
  void onBack() => BlocProvider.of<BlocImportEcnryptedXprv>(context)
      .add(PreviousCardEvent());

  void onNext() {
    Locator.instance.get<ApiCreateWallet>().setWalletName(_walletName);
    Locator.instance
        .get<ApiCreateWallet>()
        .setWalletDescription(_walletDescription);
    BlocProvider.of<BlocImportEcnryptedXprv>(context).add(NextCardEvent());
  }

  late TextEditingController _nameController;
  late TextEditingController _descController;

  String _walletName = '';
  String _walletDescription = '';
  void setWalletName(String walletName) {
    setState(() {
      _walletName = walletName;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
  }

  Widget _buildUserField(double width) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'Wallet Name'),
            controller: _nameController,
            onSubmitted: (String value) => null,
            onChanged: (String value) {
              setState(() {
                _walletName = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField(double width) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Wallet Description'),
            controller: _descController,
            onSubmitted: (String value) => null,
          )
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Identify your Wallet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ), //Textstyle
        ), //Text
        SizedBox(
          height: 10,
        ),
        Text(
          'Keep track of and describe your Witnet wallet by filling in the boxes below.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ), //Textstyle
        ), //Text
        SizedBox(
          height: 10,
        ),

        SizedBox(height: 10), //SizedBox
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: ElevatedButton(
            onPressed: onBack,
            child: Text('Go back!'),
          ), // ElevatedButton
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10),
          child: ElevatedButton(
            onPressed: _walletName.length > 0 ? onNext : null,
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
                  'Wallet Details',
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
                    _buildInfoText(),
                    _buildUserField(textFieldWidth),
                    _buildDescriptionField(textFieldWidth),
                    _buildButtonRow(),
                    SizedBox(height: 10),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
