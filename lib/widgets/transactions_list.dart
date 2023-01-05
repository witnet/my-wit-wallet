import 'package:witnet_wallet/util/extensions/int_extensions.dart';
import 'package:witnet_wallet/util/extensions/string_extensions.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/transaction_details.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';

typedef void VoidCallback(ValueTransferInfo? value);

class TransactionsList extends StatefulWidget {
  final ThemeData themeData;
  final VoidCallback setDetails;
  final ValueTransferInfo? details;
  final List<String?> txHashes;
  final Map<int, Account> externalAddresses;
  final List<ValueTransferInfo> valueTransfers;
  TransactionsList(
      {Key? key,
      required this.themeData,
      required this.details,
      required this.setDetails,
      required this.txHashes,
      required this.externalAddresses,
      required this.valueTransfers})
      : super(key: key);

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  List<String?> addresses = [];
  ValueTransferInfo? transactionDetails;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool receiver(ValueTransferInfo vti) {
    bool _receiver = false;
    vti.outputs.forEach((element) {
      if (addresses.contains(element.pkh.address)) {
        _receiver = true;
      }
    });
    return _receiver;
  }

  bool sender(ValueTransferInfo vti) {
    bool _sender = false;
    vti.inputs.forEach((element) {
      if (addresses.contains(element.address)) {
        _sender = true;
      }
    });
    return _sender;
  }

  int receiveValue(ValueTransferInfo vti) {
    int nanoWitvalue = 0;
    vti.outputs.forEach((element) {
      if (addresses.contains(element.pkh.address)) {
        nanoWitvalue += element.value.toInt();
      }
    });
    return nanoWitvalue;
  }

  int sendValue(ValueTransferInfo vti) {
    int value = 0;
    vti.outputs.forEach((element) {
      if (!addresses.contains(element.pkh.address)) {
        value += element.value.toInt();
      }
    });
    return value;
  }

  Widget _buildTransactionItem(ValueTransferInfo transaction) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    String label = '';
    String address = '';
    transaction.outputs.forEach((element) {
      if (addresses.contains(element.pkh.address)) {
        label = 'from';
      }
    });
    label = label == 'from' ? label : 'to';
    if (label == 'from' && transaction.inputs.length > 1) {
      address = 'Several addresses';
    } else if (label == 'to' && transaction.outputs.length > 1) {
      address = 'Several addresses';
    } else {
      address = label == 'from'
          ? transaction.inputs[0].address.cropMiddle(18)
          : transaction.outputs[0].pkh.address.cropMiddle(18);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.txnTime.formatDuration(),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.caption,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: WitnetPallet.transparent,
                border: Border(
                    bottom: BorderSide(
                  color: extendedTheme.txBorderColor!,
                  width: 0.5,
                )),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: label == 'from'
                            ? Text(
                                ' + ${receiveValue(transaction).standardizeWitUnits()} Wit',
                                style: theme.textTheme.bodyText1?.copyWith(
                                    color: extendedTheme.txValuePositiveColor),
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                ' - ${sendValue(transaction).standardizeWitUnits()} Wit',
                                style: theme.textTheme.bodyText1?.copyWith(
                                    color: extendedTheme.txValueNegativeColor),
                                overflow: TextOverflow.ellipsis,
                              )),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          label.capitalize(),
                          style: theme.textTheme.bodyText2,
                        ),
                        SizedBox(height: 4),
                        Text(
                          address,
                          overflow: TextOverflow.fade,
                          style: theme.textTheme.bodyText1,
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
        onTap: () {
          widget.setDetails(transaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    addresses = widget.externalAddresses.values
        .map((account) => account.address)
        .toList();
    List<ValueTransferInfo> vtts = widget.valueTransfers
        .where((vtt) => widget.txHashes.contains(vtt.txnHash))
        .toList()
      ..sort((t1, t2) => t2.txnTime.compareTo(t1.txnTime));

    if (widget.details != null) {
      return TransactionDetails(
        transaction: widget.details!,
        goToList: () => widget.setDetails(null),
      );
    } else {
      if (vtts.length > 0) {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: vtts.length,
          itemBuilder: (context, index) {
            return _buildTransactionItem(vtts[index]);
          },
        );
      } else {
        return Text('You don\'t have transactions yet');
      }
    }
  }
}
