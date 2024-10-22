import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

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
        PaddedButton(
            padding: EdgeInsets.all(8),
            text: localization.continueLabel,
            type: ButtonType.primary,
            sizeCover: false,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(originRouteName)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.pushReplacementNamed(context, originRouteName)
                }),
      ],
      icon: FontAwesomeIcons.circleExclamation,
      title: error,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        svgThemeImage(theme, name: iconName, height: 100),
        SizedBox(height: 16),
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
                          child: PaddedButton(
                              color: WitnetPallet.darkGrey,
                              padding: EdgeInsets.zero,
                              label: localization.copyAddressToClipboard,
                              text: localization.copyAddressToClipboard,
                              type: ButtonType.iconButton,
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
