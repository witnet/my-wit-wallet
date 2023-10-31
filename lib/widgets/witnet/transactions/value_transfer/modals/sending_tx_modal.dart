import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localize_string.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildSendingTransactionModal(ThemeData theme, BuildContext context) {
  return buildAlertDialog(
      context: context,
      actions: [],
      title: localization.txnSending,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        svgThemeImage(theme, name: 'sending-transaction', height: 100),
        SizedBox(height: 16),
        Text(localization.txnSending01, style: theme.textTheme.bodyLarge)
      ]));
}
