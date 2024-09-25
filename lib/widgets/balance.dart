import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

typedef void VoidCallback();

class Balance extends StatefulWidget {
  Balance({required this.currentWallet, required this.onShowBalanceDetails});
  final Wallet currentWallet;
  final VoidCallback onShowBalanceDetails;

  @override
  BalanceState createState() => BalanceState();
}

class BalanceState extends State<Balance> {
  bool isAddressCopied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      Account currentAccount =
          Locator.instance.get<ApiDatabase>().walletStorage.currentAccount;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                          padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    '${widget.currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium!
                                        .copyWith(
                                            color:
                                                extendedTheme.headerTextColor)),
                                Flexible(
                                  child: PaddedButton(
                                      padding: EdgeInsets.zero,
                                      label: localization.showBalanceDetails,
                                      text: localization.showBalanceDetails,
                                      type: ButtonType.iconButton,
                                      iconSize: 12,
                                      onPressed: widget.onShowBalanceDetails,
                                      icon: Icon(
                                        color: extendedTheme.headerTextColor,
                                        FontAwesomeIcons.sortDown,
                                        size: 12,
                                      )),
                                ),
                              ]),
                        ),
                      )))),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Semantics(
                    label: localization.currentAddress,
                    child: Text(
                      currentAccount.address.cropMiddle(18),
                      overflow: TextOverflow.ellipsis,
                      style: extendedTheme.monoRegularText!
                          .copyWith(color: extendedTheme.headerTextColor),
                    ))),
            Flexible(
              child: PaddedButton(
                  padding: EdgeInsets.zero,
                  label: localization.copyAddressToClipboard,
                  text: localization.copyAddressToClipboard,
                  type: ButtonType.iconButton,
                  color: extendedTheme.headerTextColor,
                  iconSize: 12,
                  onPressed: () async {
                    if (!isAddressCopied) {
                      await Clipboard.setData(
                          ClipboardData(text: currentAccount.address));
                      if (await Clipboard.hasStrings()) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            buildCopiedSnackbar(
                                theme, localization.addressCopied));
                        setState(() {
                          isAddressCopied = true;
                        });
                        if (this.mounted) {
                          Timer(Duration(milliseconds: 500), () {
                            setState(() {
                              isAddressCopied = false;
                            });
                          });
                        }
                      }
                    }
                  },
                  icon: Icon(
                    color: extendedTheme.headerTextColor,
                    isAddressCopied
                        ? FontAwesomeIcons.check
                        : FontAwesomeIcons.copy,
                    size: 12,
                  )),
            ),
          ]),
        ],
      );
    });
  }
}
