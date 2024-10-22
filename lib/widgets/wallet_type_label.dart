import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

typedef void BoolCallback(bool value);

class WalletTypeLabel extends StatelessWidget {
  final WalletType label;

  const WalletTypeLabel({required this.label});

  Map<WalletType, Color?> walletTypeToBgColor(context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    return {
      WalletType.hd: extendedTheme.hdWalletTypeBgColor,
      WalletType.single: extendedTheme.singleWalletBgColor
    };
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return label == WalletType.single
        ? Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
                color: walletTypeToBgColor(context)[label]),
            child: Padding(
                padding: EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 4),
                child: Text(walletTypeToLabel(context)[label]!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: WitnetPallet.white, fontSize: 9))))
        : Container();
  }
}
