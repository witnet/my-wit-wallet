import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/transaction_details.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

typedef void VoidCallback(ValueTransferInfo? value);

class TransactionsList extends StatefulWidget {
  final ThemeData themeData;
  final VoidCallback setDetails;
  final ValueTransferInfo? details;
  final Map<int, Account> externalAddresses;
  final Map<int, Account> internalAddresses;
  final List<ValueTransferInfo> valueTransfers;
  TransactionsList(
      {Key? key,
      required this.themeData,
      required this.details,
      required this.setDetails,
      required this.internalAddresses,
      required this.externalAddresses,
      required this.valueTransfers})
      : super(key: key);

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  List<String?> externalAddresses = [];
  List<String?> internalAddresses = [];
  ValueTransferInfo? transactionDetails;
  final ScrollController _scroller = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  int receiveValue(ValueTransferInfo vti) {
    int nanoWitvalue = 0;
    vti.outputs.forEach((element) {
      if ((externalAddresses.contains(element.pkh.address) ||
          internalAddresses.contains(element.pkh.address))) {
        nanoWitvalue += element.value.toInt();
      }
    });
    return nanoWitvalue;
  }

  int sendValue(ValueTransferInfo vti) {
    bool isInternalTx =
        externalAddresses.contains(vti.outputs[0].pkh.address) ||
            internalAddresses.contains(vti.outputs[0].pkh.address);
    return isInternalTx ? vti.fee : vti.outputs[0].value.toInt();
  }

  Widget buildTransactionValue(label, transaction) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    if (label == 'from') {
      return Text(
        ' + ${receiveValue(transaction).standardizeWitUnits()} ${WitUnit.Wit.name}',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: extendedTheme.txValuePositiveColor),
        overflow: TextOverflow.ellipsis,
      );
    } else if (sendValue(transaction).standardizeWitUnits() != '0') {
      return Text(
        ' - ${sendValue(transaction).standardizeWitUnits()} ${WitUnit.Wit.name}',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: extendedTheme.txValueNegativeColor),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        '${sendValue(transaction).standardizeWitUnits()} ${WitUnit.Wit.name}',
        style: theme.textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildTransactionItem(ValueTransferInfo transaction) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    String label = '';
    String address = '';
    transaction.inputs.forEach((element) {
      if (!externalAddresses.contains(element.address) &&
          !internalAddresses.contains(element.address)) {
        label = 'from';
      }
    });
    label = label == 'from' ? label : 'to';
    if (label == 'from' && transaction.inputs.length > 0) {
      address = transaction.inputs[0].address.cropMiddle(18);
    } else if (transaction.outputs.length > 0) {
      address = transaction.outputs[0].pkh.address.cropMiddle(18);
    }
    if (label == 'from' && transaction.inputs.length > 1) {
      address = 'Several addresses';
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.status != "confirmed"
                  ? "${transaction.status} ${transaction.txnTime.formatDuration()}"
                  : "${transaction.txnTime.formatDuration()}",
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
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
                    Expanded(child: buildTransactionValue(label, transaction)),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          label.capitalize(),
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          address,
                          overflow: TextOverflow.fade,
                          style: extendedTheme.monoSmallText!.copyWith(
                              color: theme.textTheme.bodyMedium!.color),
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
    final theme = Theme.of(context);
    externalAddresses = widget.externalAddresses.values
        .map((account) => account.address)
        .toList();
    internalAddresses = widget.internalAddresses.values
        .map((account) => account.address)
        .toList();

    if (widget.details != null) {
      return TransactionDetails(
        transaction: widget.details!,
        goToList: () => widget.setDetails(null),
      );
    } else {
      if (widget.valueTransfers.length > 0) {
        return ListView.builder(
          controller: _scroller,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: widget.valueTransfers.length,
          itemBuilder: (context, index) {
            return _buildTransactionItem(widget.valueTransfers[index]);
          },
        );
      } else {
        return Column(
          children: [
            Text('You don\'t have transactions yet!'),
            SizedBox(
              height: 24,
            ),
            svgThemeImage(theme, name: 'no-transactions', height: 152),
          ],
        );
      }
    }
  }
}
