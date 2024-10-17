import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/copy_button.dart';
import 'package:my_wit_wallet/widgets/link.dart';

class InfoElement extends StatelessWidget {
  final String label;
  final String text;
  final String? url;
  final bool plainText;
  final Color? color;
  final bool isLastItem;
  final String? copyText;

  const InfoElement({
    required this.label,
    required this.text,
    this.plainText = false,
    this.isLastItem = false,
    this.url,
    this.color,
    this.copyText,
  });

  Widget buildContentWithCopyIcon(BuildContext context, ThemeData theme) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildContent(theme),
          Flexible(child: CopyButton(copyContent: copyText ?? '')),
        ]);
  }

  Widget buildContent(ThemeData theme) {
    return url != null
        ? CustomLink(text: text, url: url ?? '', color: color)
        : Text(text,
            style: (color != null
                ? theme.textTheme.bodyMedium?.copyWith(color: color)
                : theme.textTheme.bodyMedium));
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: theme.textTheme.titleMedium,
      ),
      SizedBox(height: 4),
      copyText != null
          ? buildContentWithCopyIcon(context, theme)
          : buildContent(theme),
      SizedBox(height: isLastItem ? 0 : 16),
    ]);
  }
}
