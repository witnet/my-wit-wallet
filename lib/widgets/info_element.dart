import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/widgets/copy_button.dart';
import 'package:my_wit_wallet/widgets/link.dart';

enum InfoLayout { horizonal, vertical }

enum ElementType { label, content }

class InfoLink extends InfoElement {
  final String url;
  InfoLink({
    required this.url,
    required super.label,
    required super.text,
    super.isLastItem,
    super.isHashContent,
    super.isContentImportant,
    super.layout,
    super.contentColor,
  });

  Widget buildExternalLink(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: layout == InfoLayout.horizonal
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        CustomLink(
          text: text!,
          url: url,
          color: getContentStyle(theme).color,
          style: getContentStyle(theme)
              .copyWith(decoration: TextDecoration.underline),
        ),
        SizedBox(
          width: 8,
        ),
        Icon(FontAwesomeIcons.arrowUpRightFromSquare,
            color: getContentStyle(theme).color,
            size: getContentStyle(theme).fontSize! - 4)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return super.buildLayout(theme: theme, content: buildExternalLink(theme));
  }
}

class InfoCopy extends InfoElement {
  final String infoToCopy;
  InfoCopy({
    required this.infoToCopy,
    required super.label,
    super.text,
    super.isLastItem,
    super.isHashContent,
    super.isContentImportant,
    super.layout,
    super.contentColor,
    super.customContent,
  });

  Widget buildContentWithCopyIcon(BuildContext context, ThemeData theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          super.buildContent(theme),
          SizedBox(
            width: 8,
          ),
          CopyButton(
              copyContent: infoToCopy,
              color: getStyle(theme, ElementType.content)!.color),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return super.buildLayout(
        theme: theme, content: buildContentWithCopyIcon(context, theme));
  }
}

class InfoElement extends StatelessWidget {
  final String label;
  final InfoLayout layout;
  final bool isLastItem;
  final bool isHashContent;
  final bool isContentImportant;
  final Color? contentColor;
  final String? text;
  final Widget? customContent;

  const InfoElement({
    required this.label,
    this.text,
    this.isLastItem = false,
    this.isHashContent = false,
    this.isContentImportant = false,
    this.layout = InfoLayout.horizonal,
    this.contentColor,
    this.customContent,
  });

  TextStyle? getStyle(ThemeData theme, ElementType elementType) {
    switch (elementType) {
      case ElementType.label:
        return !isContentImportant
            ? theme.textTheme.labelLarge
            : theme.textTheme.bodyMedium;
      case ElementType.content:
        return isContentImportant
            ? theme.textTheme.labelLarge
            : theme.textTheme.bodyMedium;
    }
  }

  TextStyle getContentStyle(ThemeData theme) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    TextStyle? style = getStyle(theme, ElementType.content);
    if (isHashContent) {
      style = extendedTheme.monoMediumText;
    }
    Color? color = this.contentColor != null ? this.contentColor : style!.color;
    return style!.copyWith(color: color);
  }

  Widget buildContent(ThemeData theme) {
    if (customContent != null) {
      return customContent!;
    } else if (text != null) {
      return Text(
        text!,
        style: getContentStyle(theme),
        textAlign:
            layout == InfoLayout.vertical ? TextAlign.start : TextAlign.end,
      );
    } else {
      return Container();
    }
  }

  Widget getLabelWidget(ThemeData theme) {
    return Text(
      label,
      style: getStyle(theme, ElementType.label),
    );
  }

  Widget buildLayout({required ThemeData theme, required Widget content}) {
    switch (layout) {
      case InfoLayout.horizonal:
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getLabelWidget(theme),
                  SizedBox(width: 8),
                  content,
                ],
              ),
              SizedBox(height: isLastItem ? 0 : 8),
            ]);
      case InfoLayout.vertical:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getLabelWidget(theme),
            SizedBox(height: 8),
            content,
            SizedBox(height: isLastItem ? 0 : 8),
          ],
        );
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildLayout(theme: theme, content: buildContent(theme));
  }
}
