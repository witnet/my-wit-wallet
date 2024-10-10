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
        fontFamily: theme.textTheme.bodyLarge?.fontFamily, fontSize: 16);
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
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(
            color: isSelected
                ? extendedTheme.walletActiveItemBorderColor!
                : extendedTheme.walletItemBorderColor!,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(8),
        child: Row(children: [
          SizedBox(width: 8),
          Container(
              decoration: BoxDecoration(
                  color: WitnetPallet.black,
                  border: Border.all(color: WitnetPallet.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(24))),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                child: Container(
                  decoration: BoxDecoration(
                      color: WitnetPallet.black,
                      border: Border.all(color: WitnetPallet.black)),
                  width: 30,
                  height: 30,
                  child: Identicon(seed: walletId, size: 8),
                ),
              )),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walletName,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(fontSize: 12, height: 1.3),
                  ),
                  Text(
                    address,
                    overflow: TextOverflow.ellipsis,
                    style: extendedTheme.monoRegularText?.copyWith(height: 1.3),
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
                style: textStyle.copyWith(fontSize: 13),
              )
            ]),
          ),
          SizedBox(width: 8),
        ]),
      ),
      onPressed: () {
        onChanged(walletId);
      },
    );
  }
}
