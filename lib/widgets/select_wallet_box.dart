import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/identicon.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/widgets/wallet_type_label.dart';

typedef void StringCallback(String? value);

class SelectWalletBox extends StatelessWidget {
  final bool isSelected;
  final String label;
  final StringCallback onChanged;
  final WalletType walletType;
  final String walletId;
  final String walletName;
  final String address;
  final String balance;

  const SelectWalletBox(
      {required this.isSelected,
      required this.label,
      required this.onChanged,
      required this.walletId,
      required this.walletName,
      required this.address,
      required this.walletType,
      required this.balance});

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    final textStyle = TextStyle(
        fontFamily: 'Almarai',
        color: WitnetPallet.white,
        fontSize: 14,
        fontWeight: FontWeight.normal);
    return PaddedButton(
      padding: EdgeInsets.zero,
      label: label,
      text: 'wallet',
      type: ButtonType.boxButton,
      darkBackground: true,
      container: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? extendedTheme.walletActiveItemBackgroundColor
              : extendedTheme.walletListBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.all(
            color: isSelected
                ? extendedTheme.walletActiveItemBorderColor!
                : extendedTheme.walletItemBorderColor!,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(8),
        child: Row(children: [
          Container(
            color: extendedTheme.selectedTextColor,
            width: 30,
            height: 30,
            child: Identicon(seed: walletId, size: 8),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walletName,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  Text(
                    address,
                    overflow: TextOverflow.ellipsis,
                    style: extendedTheme.monoSmallText!
                        .copyWith(color: WitnetPallet.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              WalletTypeLabel(label: walletType),
              SizedBox(height: walletType == WalletType.single ? 8 : 0),
              Text(
                '$balance ${WIT_UNIT[WitUnit.Wit]}',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              )
            ]),
          ),
        ]),
      ),
      onPressed: () {
        onChanged(walletId);
      },
    );
  }
}
