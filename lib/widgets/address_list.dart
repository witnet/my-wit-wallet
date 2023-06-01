import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    currentAddress =
        Locator.instance<ApiDatabase>().walletStorage.currentAccount.address;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildAddressItem(Account account, ThemeData theme) {
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    final isAddressSelected = account.address == currentAddress;
    final textStyle = isAddressSelected
        ? extendedTheme.monoMediumText
        : extendedTheme.monoRegularText;
    return MouseRegion(
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
                            child: Text(
                              '${account.balance.availableNanoWit.standardizeWitUnits()} ${WitUnit.Wit.name}',
                              textAlign: TextAlign.end,
                              style: textStyle!.copyWith(fontFamily: 'Almarai'),
                            ),
                          ),
                        ]))),
            onTap: () async {
              await ApiPreferences.setCurrentAddress(AddressEntry(
                walletId: widget.currentWallet.id,
                addressIdx: account.index.toString(),
                keyType: account.keyType == KeyType.internal ? 1 : 0,
              ));

              BlocProvider.of<DashboardBloc>(context)
                  .add(DashboardUpdateWalletEvent(
                currentWallet: widget.currentWallet,
                currentAddress: account.address,
              ));
            }));
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
            padding: EdgeInsets.all(16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Internal balance',
                          style: theme.textTheme.displaySmall,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Tooltip(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.colorScheme.background,
                            ),
                            textStyle: theme.textTheme.bodyMedium,
                            height: 60,
                            message:
                                'The internal balance corresponds to the sum of all the change accounts available balance',
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Icon(FontAwesomeIcons.circleQuestion,
                                    size: 12,
                                    color: extendedTheme.inputIconColor))),
                      ]),
                  Expanded(
                    child: Text(
                      '${internalBalance.standardizeWitUnits()} ${WitUnit.Wit.name}',
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
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemCount: externalAccounts.length,
              itemBuilder: (context, index) {
                return _buildAddressItem(externalAccounts[index], theme);
              },
            ),
            SizedBox(height: 24),
            _internalAccountsBalance(theme)
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return _dashboardBlocListener();
  }
}
