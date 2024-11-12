import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/clear_and_redirect.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/sort_wallets_by_name.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/widgets/buttons/icon_btn.dart';
import 'package:my_wit_wallet/widgets/select_wallet_box.dart';

class ListItem {
  bool isSelected = false;
  String data;

  ListItem(this.data);
}

class WalletIdName {
  String id;
  String name;

  WalletIdName({
    required this.id,
    required this.name,
  });
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
  List<WalletIdName> walletIdList = [];
  Wallet? selectedWallet;
  Account? selectedAccount;
  Map<String, dynamic>? selectedAddressList;
  late Function onSelected;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  List<WalletIdName> get sortedWalletsByName =>
      sortWalletListByName(walletIdList);

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
    WalletStorage walletStorage = database.walletStorage;
    setState(() {
      selectedAccount = walletStorage.currentAccount;
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
        walletIdList.add(WalletIdName(id: value.id, name: value.name));
      });
    });
  }

  //Go to create or import wallet view
  void _createImportWallet() {
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.unset);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.unset));
    Navigator.pushNamed(context, CreateWalletScreen.route);
  }

  Widget _buildInitialButtons() {
    final theme = Theme.of(context);
    return IconBtn(
      label: localization.createOrImportLabel,
      padding: EdgeInsets.all(0),
      text: localization.createOrImportLabel,
      color: theme.textTheme.displaySmall!.color,
      onPressed: () => {
        _createImportWallet(),
      },
      icon: Icon(
        FontAwesomeIcons.circlePlus,
        color: theme.textTheme.titleLarge!.color,
        size: 18,
      ),
      iconBtnType: IconBtnType.horizontalText,
    );
  }

  Widget _buildWalletItem(WalletIdName walletIdName) {
    String walletId = walletIdName.id;
    final isSelectedWallet = walletId == selectedWallet?.id;
    Wallet? currentWallet = database.walletStorage.wallets[walletId];

    bool isHdWallet = currentWallet!.walletType == WalletType.hd;
    bool hasBuildError = isHdWallet
        ? currentWallet.externalAccounts.length < 1
        : currentWallet.masterAccount == null;
    if (!hasBuildError) {
      String? balance =
          currentWallet.balanceNanoWit().availableNanoWit.toString();
      String currentWalletAccount;
      if (database.walletStorage.currentAddressList != null &&
          database.walletStorage.currentAddressList![walletId] != null) {
        currentWalletAccount =
            database.walletStorage.currentAddressList![walletId];
      } else {
        currentWalletAccount = isHdWallet ? '0/0' : 'm';
      }

      Map<int, Account>? accountsList = isHdWallet
          ? currentWallet.externalAccounts
          : {0: currentWallet.masterAccount!};
      int currentAccountIndex = currentWalletAccount.contains("/")
          ? int.parse(currentWalletAccount.split('/').last)
          : 0;
      String? address = accountsList[currentAccountIndex]?.address.toString();

      return SelectWalletBox(
        walletId: walletId,
        walletType: database.walletStorage.wallets[walletId]!.walletType,
        label: database.walletStorage.wallets[walletId]!.name,
        isSelected: isSelectedWallet,
        walletName: database.walletStorage.wallets[walletId]!.name,
        balance: num.parse(balance)
            .standardizeWitUnits(
                inputUnit: WitUnit.nanoWit, outputUnit: WitUnit.Wit)
            .formatWithCommaSeparator(),
        address: address ?? '',
        onChanged: (walletId) => {
          setState(() {
            selectedWallet = database.walletStorage.wallets[walletId]!;
          }),
          BlocProvider.of<DashboardBloc>(context).add(
              DashboardUpdateWalletEvent(
                  currentWallet: selectedWallet,
                  currentAddress: selectedAccount!.address)),
          clearAndRedirectToDashboard(context),
        },
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: ListView(padding: EdgeInsets.all(8), children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildInitialButtons()]),
          SizedBox(height: 8),
          ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sortedWalletsByName.length,
              itemBuilder: (context, index) {
                return _buildWalletItem(sortedWalletsByName[index]);
              })
        ]));
  }
}
