import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
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

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(
        localization.forgetPassword,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 8),
      Container(
          width: 170,
          child: PaddedButton(
            fontSize: 13,
            padding: EdgeInsets.all(0),
            boldText: false,
            color: extendedTheme.errorColor,
            onPressed: () => resetWallet(context),
            text: localization.reestablishWallet,
            type: ButtonType.text,
          ))
    ]);
  }
}
