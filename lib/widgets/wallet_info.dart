import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/buttons/icon_btn.dart';
import 'package:my_wit_wallet/widgets/copy_button.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

typedef void VoidCallback();

class WalletInfo extends StatefulWidget {
  WalletInfo({required this.currentWallet, required this.onShowBalanceDetails});
  final Wallet currentWallet;
  final VoidCallback onShowBalanceDetails;

  @override
  WalletInfoState createState() => WalletInfoState();
}

class WalletInfoState extends State<WalletInfo> {
  bool isAddressCopied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      Account currentAccount =
          Locator.instance.get<ApiDatabase>().walletStorage.currentAccount;
      return Container(
          padding: EdgeInsets.only(top: 8, bottom: 8, right: 16, left: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
            color: WitnetPallet.brightCyan,
          ),
          child: Stack(
            children: [
              Positioned(
                  top: -100,
                  right: -60,
                  child: svgImage(
                    name: 'dots-bg-dark',
                    height: 230,
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                      label: localization.balance,
                      button: true,
                      enabled: true,
                      child: IntrinsicWidth(
                          child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: widget.onShowBalanceDetails,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: WitnetPallet.opacityBlack,
                                        borderRadius: BorderRadius.all(
                                            extendedTheme.borderRadius!)),
                                    padding: EdgeInsets.only(
                                        left: 8, top: 0, bottom: 0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                              '${widget.currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.titleLarge!
                                                  .copyWith(
                                                      color:
                                                          WitnetPallet.black)),
                                          Flexible(
                                            child: IconBtn(
                                                padding: EdgeInsets.zero,
                                                label: localization
                                                    .showBalanceDetails,
                                                text: localization
                                                    .showBalanceDetails,
                                                iconBtnType: IconBtnType.icon,
                                                iconSize: 12,
                                                onPressed:
                                                    widget.onShowBalanceDetails,
                                                icon: Icon(
                                                  color: WitnetPallet.black,
                                                  FontAwesomeIcons.sortDown,
                                                  size: 12,
                                                )),
                                          ),
                                        ]),
                                  ),
                                ),
                              )))),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currentAccount.address.cropMiddle(18),
                          overflow: TextOverflow.ellipsis,
                          style: extendedTheme.monoMediumText!
                              .copyWith(color: WitnetPallet.black),
                        ),
                        SizedBox(width: 4),
                        CopyButton(
                            copyContent: currentAccount.address,
                            color: WitnetPallet.black),
                      ]),
                ],
              )
            ],
          ));
    });
  }
}
