import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/preferences.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/address.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';

import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';

class AddressList extends StatefulWidget {
  final List<Account> accountList;

  final Wallet currentWallet;

  const AddressList({
    required this.accountList,
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildAddressItem(Account account) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    final isAddressSelected = account.address == currentAddress;
    final textStyle = isAddressSelected
        ? theme.textTheme.labelMedium
        : theme.textTheme.bodyText1;
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
                              '${account.balance.availableNanoWit.standardizeWitUnits()} Wit',
                              textAlign: TextAlign.end,
                              style: textStyle,
                            ),
                          ),
                        ]))),
            onTap: () {
              ApiDashboard api = Locator.instance.get<ApiDashboard>();
              ApiPreferences.setCurrentAddress(AddressEntry(
                  walletId: widget.currentWallet.id,
                  addressIdx: account.index.toString()));
              //set current account address

              setState(() {
              api.setCurrentAccount(account);

              });
              BlocProvider.of<DashboardBloc>(context)
                  .add(DashboardUpdateWalletEvent(
                currentWallet: widget.currentWallet,
                currentAddress: account.address,
              ));
            }));
  }

  BlocListener _dashboardBlocListener(){
    return BlocListener<DashboardBloc, DashboardState>(
        listener: (BuildContext context, DashboardState state) {
          if (state.status == DashboardStatus.Ready) {
            setState(() {
              currentAddress = state.currentAddress;
            });
          }
        },
        child: _dashboardBlocBuilder(),
    );
  }

  BlocBuilder _dashboardBlocBuilder(){
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.currentWallet.allAccounts().values.toList().length,
          itemBuilder: (context, index) {
            return _buildAddressItem(widget.currentWallet.allAccounts().values.toList()[index]);
          },
        );
      },
    );
  }



  Widget build(BuildContext context) {
    return _dashboardBlocListener();
  }
}
