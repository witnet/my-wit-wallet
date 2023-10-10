import 'package:my_wit_wallet/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final List<String> externalAddresses;
  final List<String> internalAddresses;
  final Account? singleAddressAccount;
  final List<GeneralTransaction> transactions;
  TransactionsList(
      {Key? key,
      required this.themeData,
      required this.details,
      required this.setDetails,
      required this.internalAddresses,
      required this.externalAddresses,
      required this.transactions,
      this.singleAddressAccount})
      : super(key: key);

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  GeneralTransaction? transactionDetails;
  final ScrollController _scroller = ScrollController();
  AppLocalizations get _localization => AppLocalizations.of(context)!;

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
        if ((widget.externalAddresses.contains(element.pkh.address) ||
            widget.internalAddresses.contains(element.pkh.address))) {
          nanoWitvalue += element.value.toInt();
        } else if (widget.singleAddressAccount != null &&
            widget.singleAddressAccount!.address == element.pkh.address) {
          nanoWitvalue += element.value.toInt();
        }
      });
      return nanoWitvalue;
    } else {
      vti.mint!.outputs.forEach((element) {
        if ((widget.externalAddresses.contains(element.pkh.address) ||
            widget.internalAddresses.contains(element.pkh.address))) {
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
      bool isInternalTx = widget.externalAddresses
              .contains(vti.vtt!.outputs[0].pkh.address) ||
          widget.internalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
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

    if (label == _localization.from) {
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
      label = getTransactionLabel(
        widget.externalAddresses,
        widget.internalAddresses,
        transaction.vtt!.inputs,
        widget.singleAddressAccount,
        context,
      );

      address = getTransactionAddress(
          label, transaction.vtt!.inputs, transaction.vtt!.outputs);
    } else {
      label = _localization.from;
      address = 'Mint';
    }

    String txnStatus = _localization.txnStatus(transaction.status);
    String txnTime = transaction.txnTime.formatDuration(context);
    return Semantics(
        button: true,
        enabled: true,
        label: _localization.transaction,
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
                          ? "$txnStatus $txnTime"
                          : txnTime,
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

    if (widget.details != null) {
      return TransactionDetails(
        transaction: widget.details!,
        goToList: () => widget.setDetails(null),
      );
    } else {
      if (widget.transactions.length > 0) {
        return ListView.builder(
          controller: _scroller,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: widget.transactions.length,
          itemBuilder: (context, index) {
            return _buildTransactionItem(widget.transactions[index]);
          },
        );
      } else {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    svgThemeImage(theme, name: 'no-transactions', height: 152),
                    SizedBox(
                      height: 24,
                    ),
                    Text(_localization.noTransactions),
                  ]),
            )
          ],
        );
      }
    }
  }
}
