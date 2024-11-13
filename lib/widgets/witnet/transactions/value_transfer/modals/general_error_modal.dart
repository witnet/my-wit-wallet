import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/buttons/icon_btn.dart';

void buildGeneralExceptionModal({
  required ThemeData theme,
  required BuildContext context,
  required String originRouteName,
  required Widget originRoute,
  required String message,
  required String error,
  String iconName = 'transaction-error',
  String? errorMessage,
}) {
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return buildAlertDialog(
      context: context,
      actions: [
        CustomButton(
            padding: EdgeInsets.all(8),
            text: localization.continueLabel,
            type: CustomBtnType.primary,
            sizeCover: false,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(originRouteName)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.pushReplacementNamed(context, originRouteName)
                }),
      ],
      image: svgThemeImage(theme, name: iconName, height: 100),
      title: error,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: theme.textTheme.bodyLarge),
        SizedBox(height: 16),
        errorMessage != null
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
                  color: WitnetPallet.lightGrey,
                ),
                padding: EdgeInsets.only(left: 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          flex: 8,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(errorMessage,
                                  style: extendedTheme.monoRegularText!
                                      .copyWith(
                                          color: WitnetPallet.darkGrey,
                                          fontSize: 12)))),
                      Flexible(
                          flex: 1,
                          child: IconBtn(
                              color: WitnetPallet.darkGrey,
                              padding: EdgeInsets.zero,
                              label: localization.copyAddressToClipboard,
                              text: localization.copyAddressToClipboard,
                              iconBtnType: IconBtnType.icon,
                              iconSize: 10,
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: errorMessage));
                              },
                              icon: Icon(
                                FontAwesomeIcons.copy,
                                size: 10,
                              ))),
                    ]))
            : Container()
      ]));
}
