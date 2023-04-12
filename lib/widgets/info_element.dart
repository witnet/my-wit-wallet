import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/link.dart';

class InfoElement extends StatelessWidget {
  final String label;
  final String text;
  final String? url;
  final bool plainText;
  final Color? color;

  const InfoElement({
    required this.label,
    required this.text,
    this.plainText = false,
    this.url,
    this.color,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: plainText
            ? theme.textTheme.bodyLarge
            : theme.textTheme.displaySmall,
      ),
      SizedBox(height: 8),
      url != null
          ? CustomLink(text: text, url: url ?? '')
          : Text(text,
              style: (color != null
                  ? theme.textTheme.bodyLarge?.copyWith(color: color)
                  : theme.textTheme.bodyLarge))
    ]);
  }
}
