import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/util/preferences.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet_wallet/widgets/address.dart';
import 'package:witnet_wallet/util/extensions/int_extensions.dart';

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
  List<String> walletNameList = [];
  Wallet? selectedWallet;
  Address? selectedAddress;
  Map<String, dynamic>? selectedAddressList;
  Map<String, Wallet>? wallets;
  late Function onSelected;

  @override
  void initState() {
    super.initState();
    _getDashboardData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getDashboardData() async {
    // Get selected addresses stored locally for each of the wallets created
    await _getSelectedAddressList();
    // Get data of all wallets created
    await _getWallets();
    // Set as currentWallet the wallet stored locally or the default value
    await _getCurrentWallet();
    // Set selected address for the current wallet
    _getSelectedAddress();
    // Set current wallet and current address
    _setDashboardState();
  }

  Future _getCurrentWallet() async {
    String? storedCurrentWalletName = await ApiPreferences.getCurrentWallet();
    bool isWalletSaved =
        storedCurrentWalletName != '' && storedCurrentWalletName != null;
    String walletIdToSelect =
        isWalletSaved ? storedCurrentWalletName : wallets!.values.first.name;
    Wallet? walletToSet = wallets![walletIdToSelect];
    setState(() {
      selectedWallet = walletToSet;
    });
  }

  void _getSelectedAddress() {
    String? selectedAddressValue = selectedAddressList?[selectedWallet?.id];
    bool isAddressSaved =
        selectedAddressValue != '' && selectedAddressValue != null;
    Account? currentAccount = selectedWallet?.externalAccounts[
        isAddressSaved ? int.parse(selectedAddressValue) : 0];
    setState(() {
      selectedAddress = Address(
          address: currentAccount!.address,
          balance: currentAccount.balance(),
          index: isAddressSaved ? int.parse(selectedAddressValue) : 0);
    });
  }

  void _setDashboardState() {
    BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateWalletEvent(
      currentWallet: selectedWallet,
      currentAddress: selectedAddress,
    ));
  }

  Future _getSelectedAddressList() async {
    final result = await ApiPreferences.getCurrentAddressList();
    setState(() {
      selectedAddressList = result;
    });
  }

  Future _getWallets() async {
    WalletStorage walletStorage =
        await Locator.instance<ApiDatabase>().loadWalletsDatabase();
    setState(() {
      walletNameList = List<String>.from(walletStorage.wallets.keys);
      wallets = walletStorage.wallets;
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

  Widget _buildWalletItem(String walletId) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    final isSelectedWallet = walletId == selectedWallet?.id;
    String? balance = wallets?[walletId]!
        .balanceNanoWit()
        .availableNanoWit
        .standardizeWitUnits();
    String? address = wallets?[walletId]
        ?.externalAccounts[selectedAddressList?[walletId] != null
            ? int.parse(selectedAddressList?[walletId])
            : 0]
        ?.address
        .toString();
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
          child: Row(children: [
            Container(
              color: extendedTheme.selectedTextColor,
              width: 30,
              height: 30,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      walletId,
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
            Expanded(
              child: Text(
                balance != null ? '$balance Wit' : '',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
          ]),
        ),
        onTap: () {
          Account? currentAccount = wallets?[walletId]?.externalAccounts[
              selectedAddressList?[walletId] != null
                  ? int.parse(selectedAddressList?[walletId])
                  : 0];
          ApiPreferences.setCurrentWallet(walletId);
          BlocProvider.of<DashboardBloc>(context).add(
              DashboardUpdateWalletEvent(
                  currentWallet: wallets?[walletId],
                  currentAddress: Address(
                      address: currentAccount!.address,
                      balance: currentAccount.balance(),
                      index: 0)));
          setState(() {
            selectedWallet = wallets?[walletId];
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
        physics: NeverScrollableScrollPhysics(),
        itemCount: walletNameList.length,
        itemBuilder: (context, index) {
          return _buildWalletItem(walletNameList[index]);
        },
      ),
    ]);
  }
}
