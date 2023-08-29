import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildSendingTransactionModal(ThemeData theme, BuildContext context) {
  return buildAlertDialog(
      context: context,
      actions: [],
      title: 'Sending transaction',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        svgThemeImage(theme, name: 'sending-transaction', height: 100),
        SizedBox(height: 16),
        Text('The transaction is being sent', style: theme.textTheme.bodyLarge)
      ]));
}
