import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart';

class StakeScreen extends StatelessWidget {
  static final route = '/stake';
  @override
  Widget build(BuildContext context) {
    return SendTransactionLayout(
        routeName: StakeScreen.route, transactionType: TransactionType.Stake);
  }
}
