import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/get_navigation_color.dart';
import 'package:my_wit_wallet/util/is_active_route.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

typedef void VoidCallback();

class BottomNavigation extends StatelessWidget {
  BottomNavigation(
      {required this.onSendReceiveAction, required this.currentScreen});
  final VoidCallback onSendReceiveAction;
  final String currentScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double mainIconHeight = 40;
    final double iconHeight = 20;

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PaddedButton(
        color:
            getNavigationColor(context: context, route: DashboardScreen.route),
        padding: EdgeInsets.zero,
        text: localization.history,
        onPressed: currentScreen != DashboardScreen.route
            ? () => {
                  BlocProvider.of<VTTCreateBloc>(context)
                      .add(ResetTransactionEvent()),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.push(
                      context,
                      CustomPageRoute(
                          builder: (BuildContext context) {
                            return DashboardScreen();
                          },
                          maintainState: false,
                          settings:
                              RouteSettings(name: DashboardScreen.route))),
                }
            : () {},
        icon: witnetEyeIcon(theme, height: mainIconHeight),
        type: ButtonType.iconButton,
      ),
      SizedBox(width: 16),
      PaddedButton(
        color:
            getNavigationColor(context: context, route: CreateVttScreen.route),
        padding: EdgeInsets.zero,
        text: localization.history,
        onPressed: onSendReceiveAction,
        icon: isActiveRoute(context, CreateVttScreen.route)
            ? svgThemeImage(theme,
                name: 'send-receive-active', height: iconHeight)
            : svgThemeImage(theme, name: 'send-receive', height: iconHeight),
        type: ButtonType.iconButton,
      ),
      SizedBox(width: 16),
      PaddedButton(
        color:
            getNavigationColor(context: context, route: CreateVttScreen.route),
        padding: EdgeInsets.zero,
        text: localization.history,
        onPressed: currentScreen != CreateVttScreen.route
            ? () => {
                  BlocProvider.of<VTTCreateBloc>(context)
                      .add(ResetTransactionEvent()),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.push(
                      context,
                      CustomPageRoute(
                          builder: (BuildContext context) {
                            return CreateVttScreen();
                          },
                          maintainState: false,
                          settings:
                              RouteSettings(name: CreateVttScreen.route))),
                }
            : () {},
        // TODO: add current stake route
        icon: isActiveRoute(context, CreateVttScreen.route)
            ? svgThemeImage(theme, name: 'stake-active', height: iconHeight)
            : svgThemeImage(theme, name: 'stake', height: iconHeight),
        type: ButtonType.iconButton,
      ),
    ]);
  }
}
