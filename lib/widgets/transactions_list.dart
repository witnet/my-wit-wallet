import 'dart:developer';

import 'package:witnet_wallet/util/extensions/timestamp_extensions.dart';
import 'package:witnet_wallet/util/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/transaction_details.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet/utils.dart';
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

  String formatBalance(int value) {
    double wit = nanoWitToWit(value);
    if (wit > 1.0) {
      return '${wit.toStringAsPrecision(9)} WIT';
    }
    return '${value.toString()} nanoWit';
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
    vti.inputs.forEach((element) {
      if (addresses.contains(element.address)) {
        value += element.value;
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
        address = element.pkh.address;
      }
    });

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: WitnetPallet.transparent,
            border: Border(
                bottom: BorderSide(
              color: extendedTheme.txBorderColor!,
              width: 1.5,
            )),
          ),
          child: Row(children: [
            Expanded(
                child: label == 'from'
                    ? Text(
                        ' + ${formatBalance(receiveValue(transaction))}',
                        style: theme.textTheme.bodyText1?.copyWith(
                            color: extendedTheme.txValuePositiveColor),
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        ' - ${formatBalance(sendValue(transaction))}',
                        style: theme.textTheme.bodyText1?.copyWith(
                            color: extendedTheme.txValueNegativeColor),
                        overflow: TextOverflow.ellipsis,
                      )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      label.capitalize(),
                      style: theme.textTheme.bodyText2,
                    ),
                    SizedBox(height: 4),
                    Text(
                      address,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Text(
                transaction.txnTime.formatDuration(),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.caption,
              ),
            ),
          ]),
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
        .toList();
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
