import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_address.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_label.dart';
import 'package:my_wit_wallet/widgets/transaction_details.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

typedef void VoidCallback(GeneralTransaction? value);

class TransactionsList extends StatefulWidget {
  final ThemeData themeData;
  final VoidCallback setDetails;
  final GeneralTransaction? details;
  // final MintInfo? mints;
  final Map<int, Account> externalAddresses;
  final Map<int, Account> internalAddresses;
  final Account? singleAddressAccount;
  final List<GeneralTransaction> valueTransfers;
  TransactionsList(
      {Key? key,
      required this.themeData,
      required this.details,
      required this.setDetails,
      required this.internalAddresses,
      required this.externalAddresses,
      required this.valueTransfers,
      this.singleAddressAccount})
      : super(key: key);

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  List<String?> externalAddresses = [];
  List<String?> internalAddresses = [];
  GeneralTransaction? transactionDetails;
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

  int receiveValue(GeneralTransaction vti) {
    int nanoWitvalue = 0;
    if (vti.txnType == TransactionType.value_transfer) {
      vti.vtt!.outputs.forEach((element) {
        if ((externalAddresses.contains(element.pkh.address) ||
            internalAddresses.contains(element.pkh.address))) {
          nanoWitvalue += element.value.toInt();
        } else if (widget.singleAddressAccount != null &&
            widget.singleAddressAccount!.address == element.pkh.address) {
          nanoWitvalue += element.value.toInt();
        }
      });
      return nanoWitvalue;
    } else {
      vti.mint!.outputs.forEach((element) {
        if ((externalAddresses.contains(element.pkh.address) ||
            internalAddresses.contains(element.pkh.address))) {
          nanoWitvalue += element.value.toInt();
        } else if (widget.singleAddressAccount != null &&
            widget.singleAddressAccount!.address == element.pkh.address) {
          nanoWitvalue += element.value.toInt();
        }
      });
      return nanoWitvalue;
    }
  }

  int sendValue(GeneralTransaction vti) {
    if (vti.txnType == TransactionType.value_transfer) {
      bool isInternalTx =
          externalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
              internalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
              widget.singleAddressAccount?.address ==
                  vti.vtt!.outputs[0].pkh.address;
      return isInternalTx ? vti.fee : vti.vtt!.outputs[0].value.toInt();
    } else {
      return 0;
    }
  }

  Widget buildTransactionValue(label, transaction) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    if (label == 'from') {
      return Text(
        ' + ${receiveValue(transaction).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: extendedTheme.txValuePositiveColor),
        overflow: TextOverflow.ellipsis,
      );
    } else if (sendValue(transaction).standardizeWitUnits().toString() != '0') {
      return Text(
        ' - ${sendValue(transaction).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: extendedTheme.txValueNegativeColor),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        '${sendValue(transaction).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildTransactionItem(GeneralTransaction transaction) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    String label;
    String address;
    TransactionType txnType = transaction.txnType;

    if (txnType == TransactionType.value_transfer) {
      label = getTransactionLabel(externalAddresses, internalAddresses,
          transaction.vtt!.inputs, widget.singleAddressAccount);
      address = getTransactionAddress(
          label, transaction.vtt!.inputs, transaction.vtt!.outputs);
    } else {
      label = 'from';
      address = 'Mint';
    }

    return Semantics(
        button: true,
        enabled: true,
        label: 'Transaction',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
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
                            Expanded(
                                child:
                                    buildTransactionValue(label, transaction)),
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
                )),
            onTap: () {
              widget.setDetails(transaction);
            },
          ),
        ));
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
          padding: EdgeInsets.zero,
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
