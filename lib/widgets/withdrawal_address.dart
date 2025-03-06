import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

class WithdrawalAddress extends StatefulWidget {
  WithdrawalAddress({
    required this.address,
  });

  final String address;
  @override
  _WithdrawerAddressState createState() => _WithdrawerAddressState();
}

class _WithdrawerAddressState extends State<WithdrawalAddress> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          DashedRect(
            color: WitnetPallet.brightCyan,
            textStyle: extendedTheme.monoLargeText,
            strokeWidth: 1.0,
            gap: 3.0,
            text: widget.address,
          ),
          SizedBox(height: 16),
          CustomButton(
              padding: EdgeInsets.zero,
              text: localization.copyStakingAddress,
              type: CustomBtnType.primary,
              enabled: true,
              isLoading: isLoading,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: widget.address));
                if (await Clipboard.hasStrings()) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                      buildCopiedSnackbar(
                          theme, localization.stakingAddressCopied));
                }
              }),
        ]);
  }
}
