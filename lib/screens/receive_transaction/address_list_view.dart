import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/address_list.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';

typedef void VoidCallback();

class AddressListView extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback close;
  final Wallet currentWallet;

  AddressListView(
      {Key? key,
      required this.scrollController,
      required this.close,
      required this.currentWallet})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => AddressListViewState();
}

class AddressListViewState extends State<AddressListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (previous, current) {
        return ClosableView(
            title: localization.generatedAddresses,
            closeSetting: widget.close,
            children: [
              AddressList(
                currentWallet: widget.currentWallet,
              ),
            ]);
      },
    );
  }
}
