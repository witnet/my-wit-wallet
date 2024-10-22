import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/transactions_list/transaction_details.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:my_wit_wallet/widgets/container_background.dart';
import 'package:witnet/explorer.dart';

typedef void GeneralTransactionCallback(GeneralTransaction? value);

class TransactionsItem extends StatefulWidget {
  final GeneralTransaction transaction;
  final GeneralTransactionCallback showDetails;
  TransactionsItem(
      {Key? key, required this.transaction, required this.showDetails})
      : super(key: key);

  @override
  TransactionsItemState createState() => TransactionsItemState();
}

class TransactionsItemState extends State<TransactionsItem> {
  GeneralTransaction? transactionDetails;
  final ScrollController _scroller = ScrollController();
  dynamic nextAction;
  TransactionUtils? transactionUtils;

  @override
  void initState() {
    super.initState();
    transactionUtils = TransactionUtils(vti: widget.transaction);
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  Widget buildTransactionStatus(ThemeData theme) {
    TxStatusLabel transactionStatus = widget.transaction.status;
    String localizedtxnStatus = localization.txnStatus(transactionStatus.name);
    String txnTime = widget.transaction.txnTime.formatDuration(context);
    List<Widget> pendingStatus = [];
    String transacionStatusCopy = txnTime;

    if (transactionStatus != TxStatusLabel.confirmed) {
      transacionStatusCopy = "$localizedtxnStatus $txnTime";
      if (transactionStatus == TxStatusLabel.pending) {
        pendingStatus = [
          Icon(FontAwesomeIcons.clock,
              size: 10, color: theme.textTheme.bodySmall!.color),
          SizedBox(width: 4)
        ];
      }
    }

    return Row(
      children: [
        ...pendingStatus,
        Text(
          transacionStatusCopy,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }

  Color? getAmountColor(String prefix) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    int _lockedValue = transactionUtils!.lockedValue();
    if (_lockedValue > 0) {
      return WitnetPallet.mediumGrey;
    } else if (prefix == '-') {
      return extendedTheme.txValueNegativeColor;
    } else if (prefix == '+') {
      return extendedTheme.txValuePositiveColor;
    } else {
      return theme.textTheme.bodyMedium!.color;
    }
  }

  Widget buildTransactionValue(label) {
    final theme = Theme.of(context);
    TransactionValue transactionValue = transactionUtils!.getTransactionValue();

    return Text(' ${transactionValue.prefix} ${transactionValue.amount}',
        style: theme.textTheme.titleMedium?.copyWith(
          color: getAmountColor(transactionValue.prefix),
          overflow: TextOverflow.ellipsis,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    String label = transactionUtils!.getLabel();
    String address = transactionUtils!.getOrigin();
    int _lockedWit = transactionUtils!.lockedValue();
    return Semantics(
        button: true,
        enabled: true,
        label: localization.transaction,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTransactionStatus(theme),
                    ContainerBackground(
                      content: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(
                                  children: [
                                    _lockedWit > 0
                                        ? Icon(FontAwesomeIcons.lock, size: 11)
                                        : Container(),
                                    _lockedWit > 0
                                        ? SizedBox(width: 10)
                                        : Container(),
                                    Expanded(
                                        flex: 1,
                                        child: buildTransactionValue(label)),
                                  ],
                                ),
                              ])),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                label.capitalize(),
                                style: theme.textTheme.labelLarge,
                              ),
                              SizedBox(height: 4),
                              Text(address,
                                  overflow: TextOverflow.fade,
                                  style: extendedTheme.monoSmallText)
                            ],
                          )),
                        ],
                      ),
                    ),
                  ],
                )),
            onTap: () {
              widget.showDetails(widget.transaction);
            },
          ),
        ));
  }
}
