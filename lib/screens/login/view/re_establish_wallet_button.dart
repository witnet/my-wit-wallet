import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

class ReEstablishWalletBtn extends StatelessWidget {
  void resetWallet(BuildContext context) {
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.reset);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.reset));
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    AppLocalizations _localization = AppLocalizations.of(context)!;

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(_localization.forgetPassword, textAlign: TextAlign.center),
      SizedBox(height: 8),
      Container(
          width: 148,
          child: PaddedButton(
            fontSize: 14,
            padding: EdgeInsets.all(0),
            color: extendedTheme.errorColor,
            onPressed: () => resetWallet(context),
            text: _localization.reestablishWallet,
            type: ButtonType.text,
          ))
    ]);
  }
}
