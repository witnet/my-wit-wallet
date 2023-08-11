import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

class ReEstablishWallet extends StatelessWidget {
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
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(
          'Did you forget your password?, You can delete your wallet and configure a new one!',
          textAlign: TextAlign.center),
      SizedBox(height: 8),
      Container(
          width: 148,
          child: PaddedButton(
            fontSize: 14,
            padding: EdgeInsets.all(0),
            color: extendedTheme.errorColor,
            onPressed: () => resetWallet(context),
            text: 'Re-establish wallet',
            type: ButtonType.text,
          ))
    ]);
  }
}
