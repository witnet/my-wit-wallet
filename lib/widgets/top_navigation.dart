import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/is_active_route.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/buttons/icon_btn.dart';
import 'package:my_wit_wallet/widgets/identicon.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/navigation_button.dart';
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
    BlocProvider.of<TransactionBloc>(context).add(ResetTransactionEvent());
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconBtn(
                  padding: EdgeInsets.zero,
                  label: '${localization.showWalletList} button',
                  text: localization.showWalletList,
                  iconBtnType: IconBtnType.icon,
                  color: WitnetPallet.black,
                  iconSize: 24,
                  icon: Container(
                      decoration: BoxDecoration(
                          color: currentWallet.walletType == WalletType.single
                              ? WitnetPallet.brown
                              : WitnetPallet.brightCyan,
                          border: Border.all(
                              color:
                                  currentWallet.walletType == WalletType.single
                                      ? WitnetPallet.brown
                                      : WitnetPallet.brightCyan),
                          borderRadius:
                              BorderRadius.all(extendedTheme.borderRadius!)),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(extendedTheme.borderRadius!),
                        child: Container(
                          decoration: BoxDecoration(
                              color: WitnetPallet.black,
                              border: Border.all(color: WitnetPallet.black)),
                          width: 30,
                          height: 30,
                          child: Identicon(seed: walletId, size: 8),
                        ),
                      )),
                  onPressed: onShowWalletList),
              Positioned(
                  top: 2,
                  right: -8,
                  child: WalletTypeLabel(label: currentWallet.walletType)),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16),
                  Text(currentWallet.name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: extendedTheme.headerTextColor,
                      ))
                ],
              )),
        ],
      ),
      NavigationButton(
          button: IconBtn(
              padding: EdgeInsets.zero,
              label: localization.settings,
              text: localization.settings,
              color: WitnetPallet.black,
              iconSize: 22,
              icon: Icon(FontAwesomeIcons.gear,
                  size: 22, color: extendedTheme.navigationColor),
              onPressed: !isActiveRoute(context, [PreferencePage.route])
                  ? () => _goToSettings(context)
                  : () {},
              iconBtnType: IconBtnType.icon),
          routesList: [PreferencePage.route])
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
