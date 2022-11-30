import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/widgets/address.dart';

class AddressList extends StatefulWidget {
  final List<Address> addressList;
  final String currentAddress;

  const AddressList({
    required this.addressList,
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
                              '${address.balance.availableNanoWit.toString()} nanoWit',
                              textAlign: TextAlign.end,
                              style: textStyle,
                            ),
                          ),
                        ]))),
            onTap: () {
              //set current account address
            }));
  }

  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.addressList.length,
      itemBuilder: (context, index) {
        return _buildAddressItem(widget.addressList[index]);
      },
    );
  }
}
