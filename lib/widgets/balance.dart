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
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

class Balance extends StatefulWidget {
  Balance({required this.panel, required this.currentWallet});
  final PanelUtils panel;
  final Wallet currentWallet;

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
              child: Text(
                '${widget.currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              )),
          SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Semantics(
                    label: localization.currentAddress,
                    child: Text(
                      currentAccount.address.cropMiddle(18),
                      overflow: TextOverflow.ellipsis,
                      style: extendedTheme.monoRegularText!.copyWith(
                          color: theme.textTheme.headlineMedium!.color),
                    ))),
            Flexible(
              child: PaddedButton(
                  padding: EdgeInsets.zero,
                  label: localization.copyAddressToClipboard,
                  text: localization.copyAddressToClipboard,
                  type: ButtonType.iconButton,
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
