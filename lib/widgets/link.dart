import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

class CustomLink extends StatelessWidget {
  final String text;
  final String url;

  const CustomLink({
    required this.text,
    required this.url,
  });

  _launchUrl(String searchItem) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(text,
                  style: extendedTheme.monoSmallText!.copyWith(
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline))),
          onTap: () => {_launchUrl(url)},
        ));
  }
}
