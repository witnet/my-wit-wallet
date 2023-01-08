import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';

import 'package:witnet_wallet/util/storage/database/account.dart';

launchExplorerSearch(String searchItem) async {
  String url = 'https://witnet.network/search/$searchItem';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

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
                flex: 1,
                child: Column(children: [
                  AutoSizeText(
                    account.path.split('/').last,
                    maxLines: 1,
                    minFontSize: 9,
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
                  onPressed: () {},
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
}

class VttHashCard extends StatelessWidget {
  final String vttHash;
  VttHashCard({required this.vttHash});

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
                flex: 7,
                child: Column(children: [
                  AutoSizeText(
                    vttHash,
                    maxLines: 1,
                    minFontSize: 9,
                  )
                ]),
              ),
              Expanded(
                flex: 1,
                child: Column(children: [
                  IconButton(
                    iconSize: 15,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: vttHash));
                    },
                    icon: Icon(FontAwesomeIcons.copy),
                    color: theme.primaryColor,
                  )
                ]),
              ),
              Expanded(
                flex: 1,
                child: Column(children: [
                  IconButton(
                    iconSize: 15,
                    onPressed: () => launchExplorerSearch(vttHash),
                    icon: Icon(FontAwesomeIcons.globe),
                    color: theme.primaryColor,
                  )
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccountInfoDialog extends StatefulWidget {
  AccountInfoDialog({
    required this.account,
  });

  final Account account;

  @override
  AccountInfoDialogState createState() => AccountInfoDialogState();
}

class AccountInfoDialogState extends State<AccountInfoDialog> {
  int? selectedAccountIndex;
  bool showZeroBalanceAccounts = false;
  Account? selectedAccount;

  Widget _buildWalletInfoContainer(
      BuildContext context, ThemeData theme, Size deviceSize) {
    List<Widget> vttHashCards = [];

    widget.account.vttHashes.forEach((vttHash) {
      vttHashCards.add(VttHashCard(vttHash: vttHash));
    });
    return Container(
      height: deviceSize.height * 0.5,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: vttHashCards,
          ),
        ),
      ),
    );
  }

  Widget buildAccountWidget(BuildContext context) {
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
          decoration: BoxDecoration(color: theme.cardColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Transactions:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        AutoSizeText(
                          '${widget.account.address}',
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          minFontSize: 9,
                          maxFontSize: 22,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(children: [
                      IconButton(
                        iconSize: 15,
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: '${widget.account.address}'));
                        },
                        icon: Icon(FontAwesomeIcons.copy),
                        color: theme.primaryColor,
                      )
                    ]),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(children: [
                      IconButton(
                        iconSize: 15,
                        onPressed: () =>
                            launchExplorerSearch(widget.account.address),
                        icon: Icon(FontAwesomeIcons.globe),
                        color: theme.primaryColor,
                      )
                    ]),
                  ),
                ],
                //
              ),
              buildAccountWidget(context),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(theme.primaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'BACK',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
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
