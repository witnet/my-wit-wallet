import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

typedef void StringCallback(String? value);

class TapBar extends StatelessWidget {
  final String selectedItem;
  final List<String> listItems;
  final StringCallback onChanged;

  const TapBar({
    required this.selectedItem,
    required this.listItems,
    required this.onChanged,
  });

  Widget _buildTapBarItem(String item, BuildContext context,
      ExtendedTheme extendedTheme) {
    return Container(
        padding: EdgeInsets.only(right: 4, left: 4),
        alignment: Alignment.center,
        child: PaddedButton(
            padding: EdgeInsets.zero,
            text: item.fromPascalCaseToTitle(),
            onPressed: () => {onChanged(item)},
            active: item == selectedItem,
            type: ButtonType.tapbar));
  }

  Widget build(BuildContext context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            return _buildTapBarItem(
                listItems[index], context, extendedTheme);
          },
        ));
  }
}
