import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/address_list.dart';
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

  AppLocalizations get _localization => AppLocalizations.of(context)!;

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

  List<Widget> _actions() {
    final theme = Theme.of(context);
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          text: _localization.copyAddressLabel,
          type: ButtonType.primary,
          enabled: enableButton,
          isLoading: isLoading,
          onPressed: () async {
            await Clipboard.setData(
                ClipboardData(text: selectedAccount?.address ?? ''));
            if (await Clipboard.hasStrings()) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(buildCopiedSnackbar(
                  theme, _localization.copyAddressConfirmed));
            }
          }),
      BlocListener<ExplorerBloc, ExplorerState>(
        listener: (BuildContext context, ExplorerState state) {},
        child:
            BlocBuilder<ExplorerBloc, ExplorerState>(builder: (context, state) {
          ApiDatabase db = Locator.instance.get<ApiDatabase>();
          Wallet currentWallet = db.walletStorage.currentWallet;
          bool isHdWallet = currentWallet.walletType == WalletType.hd;
          if (isHdWallet) {
            return PaddedButton(
              onPressed: () async {
                ApiDatabase db = Locator.instance.get<ApiDatabase>();

                Wallet currentWallet = db.walletStorage.currentWallet;
                int extAccountsLength = currentWallet.externalAccounts.length;
                Account ac =
                    await Locator.instance.get<ApiCrypto>().generateAccount(
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
                BlocProvider.of<DashboardBloc>(context)
                    .add(DashboardUpdateWalletEvent(
                  currentWallet: currentWallet,
                  currentAddress: ac.address,
                ));
                BlocProvider.of<ExplorerBloc>(context)
                    .add(SyncSingleAccountEvent(ExplorerStatus.singleSync, ac));
              },
              padding: EdgeInsets.only(top: 8),
              text: _localization.genNewAddressLabel,
              type: ButtonType.secondary,
              enabled: state.status != ExplorerStatus.singleSync,
            );
          } else {
            return Container();
          }
        }),
      ),
    ];
  }

  _setCurrentWallet(Wallet? currentWallet, Account currentAccount) {
    setState(() {
      selectedAccount = currentAccount;
    });
  }

  Widget _buildReceiveTransactionScreen() {
    final theme = Theme.of(context);
    ApiDatabase db = Locator.instance.get<ApiDatabase>();

    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            QrAddressGenerator(
              data: selectedAccount!.address,
            ),
            SizedBox(height: 24),
            DashedRect(
              color: WitnetPallet.witnetGreen1,
              strokeWidth: 1.0,
              gap: 3.0,
              text: selectedAccount!.address,
            ),
            SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localization.generatedAddresses,
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            SizedBox(height: 16),
            AddressList(
              currentWallet: db.walletStorage.currentWallet,
            ),
          ],
        ));
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
          dashboardChild: _buildReceiveTransactionScreen(),
          actions: _actions(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: _dashboardBlocListener(),
    );
  }
}
