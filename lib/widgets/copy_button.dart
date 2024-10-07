import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

typedef void VoidCallback();

class CopyButton extends StatefulWidget {
  final String copyContent;
  final Color? color;
  CopyButton({required this.copyContent, this.color});

  @override
  CopyButtonState createState() => CopyButtonState();
}

class CopyButtonState extends State<CopyButton> {
  bool isAddressCopied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    return PaddedButton(
        padding: EdgeInsets.zero,
        label: localization.copyAddressToClipboard,
        text: localization.copyAddressToClipboard,
        type: ButtonType.iconButton,
        color: widget.color != null
            ? extendedTheme.headerTextColor
            : theme.textTheme.bodyMedium!.color,
        iconSize: 12,
        onPressed: () async {
          if (!isAddressCopied) {
            await Clipboard.setData(ClipboardData(text: widget.copyContent));
            if (await Clipboard.hasStrings()) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                  buildCopiedSnackbar(theme, localization.addressCopied));
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
          color: widget.color != null
              ? extendedTheme.headerTextColor
              : theme.textTheme.bodyMedium!.color,
          isAddressCopied ? FontAwesomeIcons.check : FontAwesomeIcons.copy,
          size: 12,
        ));
  }
}
