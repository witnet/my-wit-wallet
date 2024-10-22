import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

SnackBar buildCopiedSnackbar(ThemeData theme, String text) {
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return SnackBar(
    width: 150,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(extendedTheme.borderRadius!)),
    clipBehavior: Clip.none,
    content: Text(text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium!
            .copyWith(color: extendedTheme.copiedSnackbarText)),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    backgroundColor: extendedTheme.copiedSnackbarBg,
    elevation: 0,
  );
}

showErrorSnackBar({
  required BuildContext context,
  required ThemeData theme,
  required String text,
  String? log,
  bool showDismiss = true,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
    theme: theme,
    text: text,
    log: log,
    color: theme.colorScheme.error,
    action: showDismiss
        ? () => {
              if (context.mounted)
                {ScaffoldMessenger.of(context).hideCurrentMaterialBanner()}
            }
        : null,
  ));
}

showErrorSnackBarWithTimeout({
  required BuildContext context,
  required ThemeData theme,
  required String text,
  String? log,
}) {
  showErrorSnackBar(
      context: context, theme: theme, text: text, log: log, showDismiss: false);
  Timer(Duration(seconds: 4), () {
    ScaffoldMessenger.of(context).clearSnackBars();
  });
}

SnackBar buildErrorSnackbar(
    {required ThemeData theme,
    required String text,
    String? log,
    Color? color,
    Function? action}) {
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return SnackBar(
    clipBehavior: Clip.none,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(extendedTheme.borderRadius!)),
    action: action != null
        ? SnackBarAction(
            label: 'Dismiss',
            onPressed: () => action(),
            textColor: Colors.white,
          )
        : null,
    content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text,
          textAlign: TextAlign.left,
          style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white)),
      log != null ? SizedBox(height: 8) : Container(),
      log != null
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
                color: WitnetPallet.lightGrey,
              ),
              padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 8,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(log,
                                style: extendedTheme.monoRegularText!.copyWith(
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
                              await Clipboard.setData(ClipboardData(text: log));
                            },
                            icon: Icon(
                              FontAwesomeIcons.copy,
                              size: 10,
                            ))),
                  ]))
          : Container()
    ]),
    duration: Duration(hours: 1),
    behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    elevation: 0,
  );
}
