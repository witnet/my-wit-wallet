import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/preferences.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/address.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';

class AddressList extends StatefulWidget {
  final List<Address> addressList;
  final String currentAddress;
  final Wallet currentWallet;

  const AddressList({
    required this.addressList,
    required this.currentWallet,
    required this.currentAddress,
  });

  @override
  State<StatefulWidget> createState() => AddressListState();
}

class AddressListState extends State<AddressList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildAddressItem(Address address) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    final isAddressSelected = address.address == widget.currentAddress;
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
                              address.address,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${address.balance.availableNanoWit.standardizeWitUnits()} Wit',
                              textAlign: TextAlign.end,
                              style: textStyle,
                            ),
                          ),
                        ]))),
            onTap: () {
              ApiPreferences.setCurrentAddress(AddressEntry(
                  walletId: widget.currentWallet.id,
                  addressIdx: address.index.toString()));
              //set current account address
              BlocProvider.of<DashboardBloc>(context)
                  .add(DashboardUpdateWalletEvent(
                currentWallet: widget.currentWallet,
                currentAddress: address,
              ));
            }));
  }

  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.addressList.length,
      itemBuilder: (context, index) {
        return _buildAddressItem(widget.addressList[index]);
      },
    );
  }
}
