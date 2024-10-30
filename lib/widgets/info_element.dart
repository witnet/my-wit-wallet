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
  final bool horizontal;
  final TextStyle? contentFontStyle;
  final Widget? content;

  const InfoElement(
      {required this.label,
      required this.text,
      this.horizontal = false,
      this.plainText = false,
      this.isLastItem = false,
      this.contentFontStyle,
      this.url,
      this.color,
      this.copyText,
      this.content});

  Widget buildContentWithCopyIcon(BuildContext context, ThemeData theme) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildContent(theme),
          Flexible(child: CopyButton(copyContent: copyText ?? '')),
        ]);
  }

  TextStyle getContentStyle(ThemeData theme) {
    Color? color =
        this.color != null ? this.color : theme.textTheme.titleMedium!.color;
    TextStyle? style = this.contentFontStyle != null
        ? this.contentFontStyle
        : theme.textTheme.titleMedium;
    return style!.copyWith(color: color);
  }

  Widget buildContent(ThemeData theme) {
    if (content != null) {
      return content!;
    }
    return url != null
        ? CustomLink(text: text, url: url ?? '', color: color)
        : Text(
            text,
            style: getContentStyle(theme),
            textAlign: TextAlign.end,
          );
  }

  Widget _buildHorizontalElement(ThemeData theme, BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Expanded(
              child: copyText != null
                  ? buildContentWithCopyIcon(context, theme)
                  : buildContent(theme)),
          SizedBox(height: isLastItem ? 0 : 16),
        ]);
  }

  Widget _buildElement(ThemeData theme, BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (horizontal) {
      return _buildHorizontalElement(theme, context);
    }
    return _buildElement(theme, context);
  }
}
