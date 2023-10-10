import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildSigningTxModal(ThemeData theme, BuildContext context) {
  AppLocalizations _localization = AppLocalizations.of(context)!;
  return buildAlertDialog(
      context: context,
      actions: [],
      title: _localization.txnSigning,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        svgThemeImage(theme, name: 'signing-transaction', height: 100),
        SizedBox(height: 16),
        Text(_localization.txnSigning01, style: theme.textTheme.bodyLarge)
      ]));
}
