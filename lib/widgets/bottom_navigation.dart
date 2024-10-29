import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/screens/stake/stake_screen.dart';
import 'package:my_wit_wallet/screens/unstake/unstake_screen.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/clear_and_redirect.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/navigation_button.dart';

typedef void VoidCallback();

class BottomNavigation extends StatelessWidget {
  BottomNavigation(
      {this.coloredBg = false,
      required this.currentScreen,
      required this.onSendReceiveAction,
      required this.onStakeUnstakeAction});
  final bool coloredBg;
  final VoidCallback onSendReceiveAction;
  final VoidCallback onStakeUnstakeAction;
  final String currentScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    final double mainIconHeight = 40;
    final double iconHeight = 20;
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NavigationButton(
              button: PaddedButton(
                padding: EdgeInsets.only(bottom: 8, top: 8),
                color: extendedTheme.navigationColor,
                label: localization.home,
                text: localization.history,
                onPressed: () => clearAndRedirectToDashboard(context),
                icon:
                    svgImage(name: 'myWitWallet-logo', height: mainIconHeight),
                type: ButtonType.iconButton,
              ),
              routesList: [DashboardScreen.route]),
          SizedBox(width: 16),
          NavigationButton(
              button: PaddedButton(
                color: extendedTheme.navigationColor,
                label: localization.sendReceiveTx,
                padding: EdgeInsets.only(bottom: 8, top: 8),
                text: localization.history,
                onPressed: onSendReceiveAction,
                icon: svgThemeImage(theme,
                    name: 'send-receive', height: iconHeight),
                type: ButtonType.iconButton,
              ),
              routesList: [
                CreateVttScreen.route,
                ReceiveTransactionScreen.route
              ]),
          SizedBox(width: 16),
          NavigationButton(
              button: PaddedButton(
                color: extendedTheme.navigationColor,
                padding: EdgeInsets.only(bottom: 8, top: 8),
                text: localization.history,
                label: localization.stakeUnstake,
                iconSize: 16,
                onPressed: onStakeUnstakeAction,
                // TODO: add current stake route
                icon: svgThemeImage(theme, name: 'stake', height: iconHeight),
                type: ButtonType.iconButton,
              ),
              routesList: [StakeScreen.route, UnstakeScreen.route]),
        ]);
  }
}
