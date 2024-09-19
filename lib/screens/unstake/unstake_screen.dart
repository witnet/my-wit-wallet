import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart';

class UnstakeScreen extends StatelessWidget {
  static final route = '/unstake';
  @override
  Widget build(BuildContext context) {
    return SendTransactionLayout(
        routeName: UnstakeScreen.route,
        transactionType: TransactionType.Unstake);
  }
}
