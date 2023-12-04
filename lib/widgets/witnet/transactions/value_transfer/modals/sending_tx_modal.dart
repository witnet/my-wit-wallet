import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildSendingTransactionModal(ThemeData theme, BuildContext context) {
  return buildAlertDialog(
      context: context,
      actions: [],
      title: localization.txnSending,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 16),
        svgThemeImage(theme, name: 'sending-transaction', height: 100),
        SizedBox(height: 16),
        Text(localization.txnSending01, style: theme.textTheme.bodyLarge)
      ]));
}
