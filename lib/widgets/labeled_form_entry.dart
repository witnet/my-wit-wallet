import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

class LabeledFormEntry extends StatelessWidget {
  LabeledFormEntry({
    Key? key,
    this.label,
    required this.formEntry,
  });
  final String? label;
  final Widget formEntry;
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            localization.nameLabel,
            style: theme.textTheme.labelLarge,
          ),
          SizedBox(height: 8),
          this.formEntry,
        ]);
  }
}
