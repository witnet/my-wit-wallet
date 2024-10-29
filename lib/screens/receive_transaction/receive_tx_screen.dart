import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/screens/receive_transaction/address_list_view.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';
import 'package:my_wit_wallet/widgets/qr/qr_address_generator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/preferences.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/new_address_modal.dart';

class ReceiveTransactionScreen extends StatefulWidget {
  static final route = '/receive-transaction';
  @override
  ReceiveTransactionScreenState createState() =>
      ReceiveTransactionScreenState();
}

class ReceiveTransactionScreenState extends State<ReceiveTransactionScreen>
    with TickerProviderStateMixin {
  Account? selectedAccount;
  late AnimationController _loadingController;
  bool isLoading = false;
  bool enableButton = true;
  bool showAddressList = false;
  ScrollController scrollController = ScrollController(keepScrollOffset: false);
  ApiDatabase db = Locator.instance.get<ApiDatabase>();
  Wallet get currentWallet => db.walletStorage.currentWallet;
  bool get isHdWallet => currentWallet.walletType == WalletType.hd;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    _setCurrentWallet(
        db.walletStorage.currentWallet, db.walletStorage.currentAccount);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _showAddressList() {
    setState(() {
      showAddressList = true;
    });
  }

  void _hideAddressList() {
    setState(() {
      showAddressList = false;
    });
  }

  List<Widget> _actions() {
    final theme = Theme.of(context);
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          text: localization.copyAddressLabel,
          type: ButtonType.primary,
          enabled: enableButton,
          isLoading: isLoading,
          onPressed: () async {
            await Clipboard.setData(
                ClipboardData(text: selectedAccount?.address ?? ''));
            if (await Clipboard.hasStrings()) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(buildCopiedSnackbar(
                  theme, localization.copyAddressConfirmed));
            }
          }),
      SizedBox(height: 8),
      isHdWallet
          ? PaddedButton(
              padding: EdgeInsets.zero,
              text: localization.addressList,
              type: ButtonType.secondary,
              enabled: enableButton,
              isLoading: isLoading,
              onPressed: _showAddressList)
          : Container(),
    ];
  }

  void _generateNewAddress() async {
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    Wallet currentWallet = db.walletStorage.currentWallet;
    int extAccountsLength = currentWallet.externalAccounts.length;
    Account ac = await Locator.instance.get<ApiCrypto>().generateAccount(
          currentWallet,
          KeyType.external,
          extAccountsLength,
        );
    setState(() {
      currentWallet.externalAccounts[extAccountsLength] = ac;
    });
    await db.addAccount(ac);
    await db.loadWalletsDatabase();
    await ApiPreferences.setCurrentAddress(AddressEntry(
      walletId: ac.walletId,
      addressIdx: int.parse(ac.path.split('/').last),
      keyType: '0',
    ));
    BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateWalletEvent(
      currentWallet: currentWallet,
      currentAddress: ac.address,
    ));
    BlocProvider.of<ExplorerBloc>(context)
        .add(SyncSingleAccountEvent(ExplorerStatus.singleSync, ac));
  }

  void _showNewAddressModal() {
    final theme = Theme.of(context);
    buildNewAddressModal(
        theme: theme,
        onAction: () => {
              _generateNewAddress(),
              Navigator.popUntil(
                  context, ModalRoute.withName(ReceiveTransactionScreen.route)),
              ScaffoldMessenger.of(context).clearSnackBars(),
            },
        context: context,
        originRouteName: ReceiveTransactionScreen.route,
        originRoute: ReceiveTransactionScreen());
  }

  Widget _buildGenerateNewAddressBtn() {
    return BlocListener<ExplorerBloc, ExplorerState>(
      listener: (BuildContext context, ExplorerState state) {},
      child:
          BlocBuilder<ExplorerBloc, ExplorerState>(builder: (context, state) {
        if (isHdWallet) {
          return PaddedButton(
            onPressed: _showNewAddressModal,
            padding: EdgeInsets.only(top: 8),
            text: localization.genNewAddressLabel,
            label: localization.genNewAddressLabel,
            type: ButtonType.iconButton,
            iconSize: 20,
            icon: Icon(
              FontAwesomeIcons.arrowsRotate,
              size: 20,
            ),
            enabled: state.status != ExplorerStatus.singleSync,
          );
        } else {
          return Container();
        }
      }),
    );
  }

  _setCurrentWallet(Wallet? currentWallet, Account currentAccount) {
    setState(() {
      selectedAccount = currentAccount;
    });
  }

  Widget _buildReceiveTransactionScreen() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Text(localization.receive,
                      style: theme.textTheme.titleLarge)),
            ),
            Stack(children: [
              Padding(
                padding: EdgeInsets.only(top: 24, right: 40, left: 40),
                child: QrAddressGenerator(
                  data: selectedAccount!.address,
                ),
              ),
              Positioned(
                  right: 0, top: 0, child: _buildGenerateNewAddressBtn()),
            ]),
            SizedBox(height: 16),
            DashedRect(
              color: WitnetPallet.brightCyan,
              textStyle: extendedTheme.monoLargeText,
              strokeWidth: 1.0,
              gap: 3.0,
              text: selectedAccount!.address,
            ),
            SizedBox(height: 24),
            ..._actions(),
            SizedBox(height: 24),
          ],
        ));
  }

  Widget _buildAddressList() {
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    return AddressListView(
        scrollController: scrollController,
        currentWallet: db.walletStorage.currentWallet,
        close: _hideAddressList);
  }

  BlocListener _dashboardBlocListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        ApiDatabase database = Locator.instance.get<ApiDatabase>();
        setState(() {
          selectedAccount = database.walletStorage.currentAccount;
        });
      },
      child: _dashboardBlocBuilder(),
    );
  }

  BlocBuilder _dashboardBlocBuilder() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        return DashboardLayout(
          panel: PanelUtils(),
          dashboardChild: showAddressList
              ? _buildAddressList()
              : _buildReceiveTransactionScreen(),
          actions: [],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: _dashboardBlocListener(),
    );
  }
}
