import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart';

class CreateVttScreen extends StatelessWidget {
  static final route = '/create-vtt';
  @override
  Widget build(BuildContext context) {
    return SendTransactionLayout(
        routeName: CreateVttScreen.route, transactionType: TransactionType.Vtt);
  }
}
