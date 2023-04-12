import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';

import 'package:witnet_wallet/util/storage/database/account.dart';
import 'account_info_dialog.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  AccountCard({required this.account});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                flex: 5,
                child: Column(children: [
                  AutoSizeText(
                    account.address,
                    maxLines: 1,
                    minFontSize: 12,
                  )
                ]),
              ),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  '${account.vttHashes.length} ',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  minFontSize: 10,
                  maxFontSize: 12,
                ),
              ),
              Expanded(
                flex: 2,
                child: AutoSizeText(
                  '${nanoWitToWit(account.balance.availableNanoWit).toString()} WIT',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  minFontSize: 10,
                  maxFontSize: 12,
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(FontAwesomeIcons.circleInfo),
                  color: theme.primaryColor,
                  onPressed: () => _showWalletSettingsDialog(context, account),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          ),
        ],
      ),
    );
  }

  Future<void> _showWalletSettingsDialog(
      BuildContext context, Account account) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AccountInfoDialog(
          account: account,
        );
      },
    );
  }
}

class WalletSettingsDialog extends StatefulWidget {
  WalletSettingsDialog({
    required this.walletStorage,
  });

  final Wallet walletStorage;

  @override
  WalletSettingsDialogState createState() => WalletSettingsDialogState();
}

class WalletSettingsDialogState extends State<WalletSettingsDialog> {
  int? selectedAccountIndex;
  bool showZeroBalanceAccounts = false;
  Account? selectedAccount;

  Widget _buildWalletInfoContainer(
      BuildContext context, ThemeData theme, Size deviceSize) {
    List<Widget> externalAddressCards = [];
    List<Widget> internalAddressCards = [];

    Wallet wallet = widget.walletStorage;

    wallet.externalAccounts.forEach((index, account) {
      if (showZeroBalanceAccounts && account.balance.availableNanoWit == 0) {
        externalAddressCards.add(AccountCard(account: account));
      }
      if (account.balance.availableNanoWit > 0)
        externalAddressCards.add(AccountCard(account: account));
    });
    wallet.internalAccounts.forEach((index, account) {
      if (showZeroBalanceAccounts && account.balance.availableNanoWit == 0) {
        internalAddressCards.add(AccountCard(account: account));
      }
      if (account.balance.availableNanoWit > 0)
        internalAddressCards.add(AccountCard(account: account));
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
              Row(
                children: [
                  AutoSizeText(
                    'External Accounts:',
                    minFontSize: 16,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(children: [
                      AutoSizeText(
                        'Address',
                        maxLines: 1,
                        minFontSize: 9,
                      ),
                    ]),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(children: [
                      AutoSizeText(
                        'Transactions',
                        maxLines: 1,
                        minFontSize: 9,
                      ),
                    ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      AutoSizeText(
                        'Balance',
                        maxLines: 1,
                        minFontSize: 9,
                      ),
                    ]),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: externalAddressCards,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  AutoSizeText(
                    'Internal Accounts:',
                    minFontSize: 16,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(children: [
                      AutoSizeText(
                        'Address',
                        maxLines: 1,
                        minFontSize: 9,
                      ),
                    ]),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(children: [
                      AutoSizeText(
                        'Transactions',
                        maxLines: 1,
                        minFontSize: 9,
                      ),
                    ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      AutoSizeText(
                        'Balance',
                        maxLines: 1,
                        minFontSize: 9,
                      ),
                    ]),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: internalAddressCards,
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
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    AutoSizeText(
                      'Show accounts with zero balance',
                      minFontSize: 10,
                    ),
                    Checkbox(
                        value: showZeroBalanceAccounts,
                        onChanged: (value) {
                          setState(() {
                            showZeroBalanceAccounts = value!;
                          });
                        }),
                  ],
                ),
              ),
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
              Row(
                children: [
                  Text(
                    'Wallet Settings',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
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
