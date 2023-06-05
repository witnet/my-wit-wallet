import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/identicon.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/preferences.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

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
  List<String> walletIdList = [];
  Wallet? selectedWallet;
  Account? selectedAccount;
  Map<String, dynamic>? selectedAddressList;
  late Function onSelected;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  @override
  void initState() {
    super.initState();
    _getCurrentWallet();
    _getWallets();
    _getSelectedAccount();
    _setDashboardState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getCurrentWallet() async {
    WalletStorage walletStorage = database.walletStorage;
    setState(() {
      selectedWallet = walletStorage.currentWallet;
    });
  }

  void _getSelectedAccount() {
    String? selectedAddressValue =
        selectedAddressList?[selectedWallet?.id]!.split('/').last;
    bool isAddressSaved =
        selectedAddressValue != '' && selectedAddressValue != null;
    Account? currentAccount = selectedWallet?.externalAccounts[
        isAddressSaved ? int.parse(selectedAddressValue) : 0];
    setState(() {
      selectedAccount = currentAccount;
    });
  }

  void _setDashboardState() {
    BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateWalletEvent(
      currentWallet: selectedWallet,
      currentAddress: selectedAccount!.address,
    ));
  }

  void _getWallets() {
    WalletStorage walletStorage = database.walletStorage;
    setState(() {
      selectedWallet = walletStorage.currentWallet;
      selectedAddressList = walletStorage.currentAddressList;
      walletStorage.wallets.forEach((key, value) {
        walletIdList.add(value.id);
      });
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
      text: 'Create or import',
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
    final textStyle = TextStyle(
        fontFamily: 'Almarai',
        color: WitnetPallet.white,
        fontSize: 14,
        fontWeight: FontWeight.normal);
    final isSelectedWallet = walletId == selectedWallet?.id;
    Wallet? currentWallet = database.walletStorage.wallets[walletId];
    String? balance =
        currentWallet!.balanceNanoWit().availableNanoWit.toString();
    String currentWalletAccount =
        database.walletStorage.currentAddressList![walletId]!;
    Map<int, Account>? accountsList =
        currentWalletAccount.split('/').first == '0'
            ? currentWallet.externalAccounts
            : currentWallet.internalAccounts;
    int currentAccountIndex = int.parse(currentWalletAccount.split('/').last);
    String? address = accountsList[currentAccountIndex]?.address.toString();

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
              child: Identicon(seed: walletId, size: 8),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      database.walletStorage.wallets[walletId]!.name,
                      style: textStyle,
                    ),
                    Text(
                      address != null ? address : '',
                      overflow: TextOverflow.ellipsis,
                      style: extendedTheme.monoSmallText!
                          .copyWith(color: WitnetPallet.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${num.parse(balance).standardizeWitUnits(inputUnit: WitUnit.nanoWit, outputUnit: WitUnit.Wit)} ${WIT_UNIT[WitUnit.Wit]}',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
          ]),
        ),
        onTap: () {
          setState(() {
            selectedWallet = database.walletStorage.wallets[walletId]!;
            selectedAccount = database
                    .walletStorage.wallets[walletId]!.externalAccounts[
                selectedAddressList?[walletId] != null
                    ? int.parse(selectedAddressList?[walletId].split('/').last)
                    : 0];
          });
          ApiPreferences.setCurrentWallet(walletId);
          BlocProvider.of<DashboardBloc>(context).add(
              DashboardUpdateWalletEvent(
                  currentWallet: selectedWallet,
                  currentAddress: selectedAccount!.address));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: ListView(padding: EdgeInsets.all(8), children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildInitialButtons()]),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: walletIdList.length,
            itemBuilder: (context, index) {
              return _buildWalletItem(walletIdList[index]);
            },
          ),
        ]));
  }
}
