import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';

class TransactionsList extends StatefulWidget {
  final List<ValueTransferInfo> transactionList;
  TransactionsList({
    Key? key,
    required this.transactionList,
  }) : super(key: key);

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildTransactionItem(ValueTransferInfo transaction) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: WitnetPallet.transparent,
            border: Border(
                bottom: BorderSide(
              color: WitnetPallet.darkGrey,
              width: 1,
            )),
          ),
          child: Row(children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type,
                      style: theme.textTheme.bodyText1,
                    ),
                    Text(
                      transaction.txnHash,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Text(
                transaction.fee.toString(),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyText1,
              ),
            ),
          ]),
        ),
        onTap: () {
          // TODO: go to transaction details
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.transactionList.length,
      itemBuilder: (context, index) {
        return _buildTransactionItem(widget.transactionList[index]);
      },
    );
  }
}
