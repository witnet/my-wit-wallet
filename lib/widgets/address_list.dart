import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/address_item.dart';

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

  @override
  void initState() {
    super.initState();
    currentAddress = database.walletStorage.currentAccount.address;
  }

  @override
  void dispose() {
    super.dispose();
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
                      return AddreessItem(
                          account: externalAccounts[index],
                          isLastItem: (externalAccounts.length - 1) == index,
                          currentAddress: currentAddress);
                    },
                  )
                : AddreessItem(
                    account: widget.currentWallet.masterAccount!,
                    isLastItem: true,
                    currentAddress: currentAddress)
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return _dashboardBlocListener();
  }
}
