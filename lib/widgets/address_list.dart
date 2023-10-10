import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/preferences.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';

class AddressList extends StatefulWidget {
  final Wallet currentWallet;

  const AddressList({
    required this.currentWallet,
  });

  @override
  State<StatefulWidget> createState() => AddressListState();
}

class AddressListState extends State<AddressList> {
  String? currentAddress;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    currentAddress = database.walletStorage.currentAccount.address;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _syncSpinnerOrBalanceDisplay(Account account, ThemeData theme) {
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    final isAddressSelected = account.address == currentAddress;
    final textStyle = isAddressSelected
        ? extendedTheme.monoMediumText
        : extendedTheme.monoRegularText;
    return BlocBuilder<ExplorerBloc, ExplorerState>(
        builder: (BuildContext context, ExplorerState state) {
      if (state.status == ExplorerStatus.singleSync &&
          state.data['address'] == account.address) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: theme.textTheme.labelMedium?.color,
                  strokeWidth: 2,
                  value: null,
                  semanticsLabel: 'Circular progress indicator',
                ))
          ],
        );
      } else {
        return Text(
            '${account.balance.availableNanoWit.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
            textAlign: TextAlign.end,
            style: textStyle!.copyWith(fontFamily: 'Almarai'));
      }
    });
  }

  Widget _buildAddressItem(Account account, ThemeData theme) {
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    final isAddressSelected = account.address == currentAddress;
    final textStyle = isAddressSelected
        ? extendedTheme.monoMediumText
        : extendedTheme.monoRegularText;
    return Semantics(
        button: true,
        enabled: true,
        label: _localization.generatedAddress,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: WitnetPallet.transparent,
                    border: Border(
                        bottom: BorderSide(
                      color: extendedTheme.txBorderColor!,
                      width: 1,
                    )),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            account.address,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle,
                          ),
                        ),
                        Expanded(
                          child: _syncSpinnerOrBalanceDisplay(account, theme),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  String _keytype = '';
                  if (account.keyType == KeyType.master) {
                    _keytype = 'm';
                  } else {
                    _keytype = account.keyType == KeyType.internal ? '1' : '0';
                  }
                  await ApiPreferences.setCurrentAddress(AddressEntry(
                    walletId: widget.currentWallet.id,
                    addressIdx: account.keyType == KeyType.master
                        ? null
                        : account.index,
                    keyType: _keytype,
                  ));
                  BlocProvider.of<DashboardBloc>(context)
                      .add(DashboardUpdateWalletEvent(
                    currentWallet: widget.currentWallet,
                    currentAddress: account.address,
                  ));
                })));
  }

  Widget _internalAccountsBalance(ThemeData theme) {
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    int internalBalance = 0;
    List<Account> internalAccounts =
        widget.currentWallet.internalAccounts.values.toList();
    internalAccounts.forEach(
        (account) => internalBalance += account.balance.availableNanoWit);
    return Container(
        child: Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 70),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localization.internalBalance,
                          style: theme.textTheme.displaySmall,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Tooltip(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.colorScheme.background,
                            ),
                            textStyle: theme.textTheme.bodyMedium,
                            height: 60,
                            message: _localization.internalBalanceHint,
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Icon(FontAwesomeIcons.circleQuestion,
                                    size: 12,
                                    color: extendedTheme.inputIconColor))),
                      ]),
                  Expanded(
                    child: Text(
                      '${internalBalance.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                      textAlign: TextAlign.end,
                      style: extendedTheme.monoRegularText!
                          .copyWith(fontFamily: 'Almarai'),
                    ),
                  ),
                ])));
  }

  BlocListener _dashboardBlocListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        if (state.status == DashboardStatus.Ready) {
          setState(() {
            currentAddress = Locator.instance<ApiDatabase>()
                .walletStorage
                .currentAccount
                .address;
          });
        }
      },
      child: _dashboardBlocBuilder(),
    );
  }

  BlocBuilder _dashboardBlocBuilder() {
    final theme = Theme.of(context);
    List<Account> externalAccounts =
        widget.currentWallet.orderedExternalAccounts().values.toList();
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        return Column(
          children: [
            widget.currentWallet.walletType == WalletType.hd
                ? ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: externalAccounts.length,
                    itemBuilder: (context, index) {
                      return _buildAddressItem(externalAccounts[index], theme);
                    },
                  )
                : _buildAddressItem(widget.currentWallet.masterAccount!, theme),
            SizedBox(height: 24),
            widget.currentWallet.walletType == WalletType.hd
                ? _internalAccountsBalance(theme)
                : Container(),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return _dashboardBlocListener();
  }
}
