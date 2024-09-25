import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/screens/stake/stake_screen.dart';
import 'package:my_wit_wallet/screens/unstake/unstake_screen.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/get_navigation_color.dart';
import 'package:my_wit_wallet/util/is_desktop_size.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
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
    final double mainIconHeight = 40;
    final double iconHeight = 20;
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NavigationButton(
              button: PaddedButton(
                color: getNavigationColor(
                    context: context, routesList: [DashboardScreen.route]),
                padding: EdgeInsets.zero,
                label: localization.home,
                text: localization.history,
                onPressed: currentScreen != DashboardScreen.route
                    ? () => {
                          BlocProvider.of<TransactionBloc>(context)
                              .add(ResetTransactionEvent()),
                          ScaffoldMessenger.of(context).clearSnackBars(),
                          Navigator.push(
                              context,
                              CustomPageRoute(
                                  builder: (BuildContext context) {
                                    return DashboardScreen();
                                  },
                                  maintainState: false,
                                  settings: RouteSettings(
                                      name: DashboardScreen.route))),
                        }
                    : () {},
                icon: witnetEyeIcon(theme, height: mainIconHeight),
                type: ButtonType.iconButton,
              ),
              routesList: [DashboardScreen.route]),
          SizedBox(width: 16),
          NavigationButton(
              button: PaddedButton(
                color: getNavigationColor(context: context, routesList: [
                  CreateVttScreen.route,
                  ReceiveTransactionScreen.route
                ]),
                label: localization.sendReceiveTx,
                padding: EdgeInsets.zero,
                text: localization.history,
                onPressed: onSendReceiveAction,
                icon: isDesktopSize
                    ? svgThemeImage(theme,
                        name: 'send-receive-desktop', height: iconHeight)
                    : svgThemeImage(theme,
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
                color: getNavigationColor(
                    context: context, routesList: [StakeScreen.route]),
                padding: EdgeInsets.zero,
                text: localization.history,
                label: localization.stakeUnstake,
                iconSize: 16,
                onPressed: onStakeUnstakeAction,
                // TODO: add current stake route
                icon: isDesktopSize
                    ? svgThemeImage(theme,
                        name: 'stake-desktop', height: iconHeight)
                    : svgThemeImage(theme, name: 'stake', height: iconHeight),
                type: ButtonType.iconButton,
              ),
              routesList: [StakeScreen.route, UnstakeScreen.route]),
        ]);
  }
}
