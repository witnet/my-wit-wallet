import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

class CustomLink extends StatelessWidget {
  final String text;
  final String url;
  final Color? color;

  const CustomLink(
      {required this.text, required this.url, required this.color});

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
        color != null ? color : extendedTheme.monoSmallText!.color;
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(text,
                  style: extendedTheme.monoSmallText!.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w400,
                      decorationColor: contentColor,
                      decoration: TextDecoration.underline))),
          onTap: () => {_launchUrl(url)},
        ));
  }
}
