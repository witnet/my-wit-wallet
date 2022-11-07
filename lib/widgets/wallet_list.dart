import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

class ListItem {
  bool isSelected = false;
  String data;

  ListItem(this.data);
}

class WalletList extends StatefulWidget {
  const WalletList({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  State<StatefulWidget> createState() => WalletListState();
}

class WalletListState extends State<WalletList> {
  List<String> walletList = [];
  late String selectedWallet = '';
  bool walletsExist = false;
  bool walletSelected = false;
  Map<String, Wallet>? wallets;
  late Function onSelected;

  @override
  void initState() {
    super.initState();
    _getWallets();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getWallets() async {
    WalletStorage walletStorage =
        await Locator.instance<ApiDatabase>().loadWalletsDatabase();
    BlocProvider.of<DashboardBloc>(context)
        .add(DashboardUpdateWalletEvent(currentWallet: walletStorage.wallets.values.first));
    List<String> walletNames = List<String>.from(walletStorage.wallets.keys);
    setState(() {
      walletList = walletNames;
      wallets = walletStorage.wallets;
      selectedWallet = walletNames[0];
    });
  }

  //Go to create or import wallet view
  void _createImportWallet() {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.unset);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.unset));
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
  }

  Widget _buildInitialButtons() {
    return PaddedButton(
      padding: EdgeInsets.all(0),
      text: 'Add new',
      onPressed: () => {
        _createImportWallet(),
      },
      icon: Icon(
        FontAwesomeIcons.circlePlus,
        size: 18,
      ),
      type: 'horizontal-icon',
    );
  }

  Widget _buildWalletItem(walletName) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    final isSelectedWallet = walletName == selectedWallet;
    String? balance =
        wallets?[walletName]!.balanceNanoWit().availableNanoWit.toString();
    String? address =
        wallets?[walletName]?.externalAccounts[0]?.address.toString();
    final textStyle = TextStyle(
        fontFamily: 'NotoSans',
        color: WitnetPallet.white,
        fontSize: 14,
        fontWeight: FontWeight.normal);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelectedWallet
                ? extendedTheme.walletActiveItemBackgroundColor
                : extendedTheme.walletListBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(
              color: isSelectedWallet
                  ? extendedTheme.walletActiveItemBorderColor!
                  : extendedTheme.walletItemBorderColor!,
              width: 1,
            ),
          ),
          margin: EdgeInsets.all(8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              color: extendedTheme.selectedTextColor,
              width: 30,
              height: 30,
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      walletName,
                      style: textStyle,
                    ),
                    Text(
                      address != null ? address : '',
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ),
            Text(
              balance != null ? '$balance nanoWit' : '',
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ]),
        ),
        onTap: () {
          setState(() {
            selectedWallet = walletName!;
            // Set current wallet to show in dashboard;
            BlocProvider.of<DashboardBloc>(context).add(
                DashboardUpdateWalletEvent(
                    currentWallet: wallets?[walletName]));
            walletSelected = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: EdgeInsets.all(8), children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildInitialButtons()]),
      ListView.builder(
        shrinkWrap: true,
        itemCount: walletList.length,
        itemBuilder: (context, index) {
          return _buildWalletItem(walletList[index]);
        },
      ),
    ]);
  }
}
