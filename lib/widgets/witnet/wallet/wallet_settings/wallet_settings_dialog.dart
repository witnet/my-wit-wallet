import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  AccountCard({required this.account});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    AutoSizeText(
                      account.address,
                      maxLines: 1,
                      minFontSize: 9,
                    ),
                    AutoSizeText(
                      account.path,
                      maxLines: 1,
                      minFontSize: 8,
                      maxFontSize: 10,
                    ),
                    AutoSizeText(
                      '${account.valueTransfers.length.toString()} transactions',
                      maxLines: 1,
                      minFontSize: 8,
                      maxFontSize: 10,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class WalletSettingsDialog extends StatelessWidget {
  WalletSettingsDialog({
    required this.internalAccounts,
    required this.externalAccounts,
  });

  final Map<String, dynamic> externalAccounts;
  final Map<String, Account> internalAccounts;

  Widget _buildWalletInfoContainer(
      BuildContext context, ThemeData theme, Size deviceSize) {
    List<Widget> addressCards = [];
    externalAccounts.forEach((key, value) {
      addressCards.add(AccountCard(account: value));
    });
    return Container(
      height: deviceSize.height * 0.5,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: addressCards,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAccountList(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    List<Widget> addressCards = [];
    externalAccounts.forEach((key, value) {
      addressCards.add(AccountCard(account: value));
    });
    return Stack(
      children: [
        Container(
          height: deviceSize.height * 0.7,
          alignment: Alignment.topCenter,
          margin: EdgeInsets.zero,
          width: (deviceSize.width < 600.0) ? deviceSize.width : 600,
          padding: Paddings.fromLTR(0),
          decoration: BoxDecoration(
              color: theme.cardColor, border: Border.all(color: Colors.black)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Wallet Settings',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              IconButton(
                  onPressed: () {
                    //BlocProvider.of<BlocExplorer>(context).add(UtxoQueryEvent(account));
                  },
                  icon: Icon(
                    FontAwesomeIcons.sync,
                    size: 15,
                  )),
              _buildWalletInfoContainer(context, theme, deviceSize),
            ],
          ),
        ),
      ],
    );
  }

  contentBox(context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Stack(
      children: <Widget>[
        Container(
          height: deviceSize.height * 0.9,
          alignment: Alignment.topCenter,
          margin: EdgeInsets.zero,
          width: (deviceSize.width < 600.0) ? deviceSize.width : 600,
          padding: Paddings.fromLTR(5),
          decoration: BoxDecoration(color: theme.cardColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Wallet Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              buildAccountList(context),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'BACK',
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      insetAnimationDuration: Duration(milliseconds: 100),
      elevation: 0,
      child: contentBox(context),
    );
  }
}
