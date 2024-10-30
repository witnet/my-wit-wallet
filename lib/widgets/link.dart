import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

class CustomLink extends StatelessWidget {
  final String text;
  final String url;
  final Color? color;
  final TextStyle? style;

  const CustomLink(
      {required this.text, required this.url, required this.color, this.style});

  _launchUrl(String searchItem) async {
    try {
      await launchUrlString(url);
    } catch (err) {
      throw 'Could not launch $err';
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    Color? contentColor =
        color != null ? color : extendedTheme.monoRegularText!.color;
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Padding(
              padding: EdgeInsets.zero,
              child: Text(text,
                  style: style ??
                      extendedTheme.monoBoldText!.copyWith(
                          color: contentColor,
                          decorationColor: contentColor,
                          decoration: TextDecoration.underline))),
          onTap: () => {_launchUrl(url)},
        ));
  }
}
