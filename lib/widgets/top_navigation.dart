import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/get_navigation_color.dart';
import 'package:my_wit_wallet/util/is_active_route.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/identicon.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/wallet_type_label.dart';

typedef void VoidCallback();

class TopNavigation extends StatelessWidget {
  TopNavigation({
    required this.currentScreen,
    required this.currentWallet,
    required this.onShowWalletList,
  });
  final String currentScreen;
  final Wallet currentWallet;
  final VoidCallback onShowWalletList;

  Future<void> _goToSettings(BuildContext context) async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.push(
        context,
        CustomPageRoute(
            builder: (BuildContext context) {
              return PreferencePage();
            },
            maintainState: false,
            settings: RouteSettings(name: PreferencePage.route)));
  }

  List<Widget> getNavigationActions(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    String walletId = currentWallet.id;
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          label: '${localization.showWalletList} button',
          text: localization.showWalletList,
          type: ButtonType.iconButton,
          iconSize: 30,
          icon: Container(
            color: WitnetPallet.white,
            width: 28,
            height: 28,
            child: Identicon(seed: walletId, size: 8),
          ),
          onPressed: onShowWalletList),
      Expanded(
          child: Padding(
              padding: EdgeInsets.only(left: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: extendedTheme.tooltipBgColor,
                      ),
                      height: 50,
                      richMessage: TextSpan(
                        text: currentWallet.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                      child: Text(currentWallet.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: extendedTheme.headerTextColor,
                              fontSize: 16))),
                  SizedBox(
                      height: currentWallet.walletType == WalletType.single
                          ? 8
                          : 0),
                  WalletTypeLabel(label: currentWallet.walletType),
                ],
              ))),
      PaddedButton(
          padding: EdgeInsets.zero,
          label: localization.settings,
          text: localization.settings,
          iconSize: 28,
          icon: Icon(FontAwesomeIcons.gear,
              size: 28,
              color: getNavigationColor(
                  context: context, route: PreferencePage.route)),
          onPressed: !isActiveRoute(context, PreferencePage.route)
              ? () => _goToSettings(context)
              : () {},
          type: ButtonType.iconButton)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
