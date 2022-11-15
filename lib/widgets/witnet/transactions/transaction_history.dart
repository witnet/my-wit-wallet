import 'package:flutter/material.dart';
import 'package:witnet/explorer.dart';

import 'package:witnet_wallet/widgets/transactions_list.dart';

class TransactionHistory extends StatelessWidget {
  final ThemeData themeData;
  final List<String?> txHashes;
  final List<ValueTransferInfo> valueTransfers;
  TransactionHistory(
      {required this.themeData,
      required this.txHashes,
      required this.valueTransfers});

  @override
  Widget build(BuildContext context) {
    Iterable<ValueTransferInfo> vtts =
        valueTransfers.where((vtt) => txHashes.contains(vtt.txnHash));
    return Column(
      children: [
        TransactionsList(transactionList: vtts.toList()),
      ],
    );
  }
}
