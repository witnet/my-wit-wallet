import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/stake/stake_screen.dart';
import 'package:my_wit_wallet/screens/unstake/unstake_screen.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/current_route.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:flutter/material.dart';

typedef void VoidCallback();

class StakeUnstakeButtons extends StatelessWidget {
  StakeUnstakeButtons({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    Future<void> _goToStakeScreen() async {
      BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
      Navigator.push(
          context,
          CustomPageRoute(
              builder: (BuildContext context) {
                return StakeScreen();
              },
              maintainState: false,
              settings: RouteSettings(name: StakeScreen.route)));
    }

    Future<void> _goToUnstakeScreen() async {
      BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
      Navigator.push(
          context,
          CustomPageRoute(
              builder: (BuildContext context) {
                return UnstakeScreen();
              },
              maintainState: false,
              settings: RouteSettings(name: UnstakeScreen.route)));
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          PaddedButton(
            color: extendedTheme.inputIconColor,
            padding: EdgeInsets.only(left: 16, right: 16),
            text: localization.stake,
            onPressed: currentRoute(context) != StakeScreen.route
                ? _goToStakeScreen
                : () {},
            icon: Container(
                height: 40,
                child: svgThemeImage(theme, name: 'stake-icon', height: 18)),
            type: ButtonType.horizontalIcon,
            alignment: MainAxisAlignment.start,
            iconPosition: IconPosition.left,
          ),
          SizedBox(width: 16),
          PaddedButton(
            color: extendedTheme.inputIconColor,
            padding: EdgeInsets.only(left: 16, right: 16),
            text: localization.unstake,
            onPressed: currentRoute != UnstakeScreen.route
                ? _goToUnstakeScreen
                : () {},
            icon: Container(
                height: 40,
                child: svgThemeImage(theme, name: 'unstake-icon', height: 24)),
            type: ButtonType.horizontalIcon,
            alignment: MainAxisAlignment.start,
            iconPosition: IconPosition.left,
          ),
        ]);
  }
}
