import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:flutter/material.dart';

typedef void VoidCallback();

class ContainerBackground extends StatelessWidget {
  ContainerBackground({required this.content, this.padding, this.marginTop});
  final Widget content;
  final double? padding;
  final double? marginTop;

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    ;
    return Container(
        margin: EdgeInsets.only(top: marginTop ?? 8),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
            color: extendedTheme.backgroundBox),
        child: Padding(padding: EdgeInsets.all(padding ?? 16), child: content));
  }
}
