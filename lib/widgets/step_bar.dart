import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

typedef void StringCallback(Enum? value);

class StepBar extends StatelessWidget {
  final Enum selectedItem;
  final bool actionable;
  final List<Enum> listItems;
  final StringCallback onChanged;

  const StepBar({
    required this.actionable,
    required this.selectedItem,
    required this.listItems,
    required this.onChanged,
  });

  Color _itemColor(
      Enum item, bool isItemActionable, ExtendedTheme extendedTheme) {
    if (item == selectedItem) {
      return extendedTheme.stepBarActiveColor!;
    } else if (isItemActionable) {
      return extendedTheme.stepBarActionableColor!;
    }
    return extendedTheme.stepBarColor!;
  }

  Widget _buildStepBarItem(Enum item, BuildContext context,
      ExtendedTheme extendedTheme, bool isItemActionable) {
    return Container(
        alignment: Alignment.center,
        child: isItemActionable
            ? PaddedButton(
                padding: EdgeInsets.zero,
                text: item.name.fromPascalCaseToTitle(),
                color: _itemColor(item, isItemActionable, extendedTheme),
                onPressed: () => {onChanged(item)},
                type: ButtonType.stepbar)
            : PaddedButton(
                padding: EdgeInsets.zero,
                enabled: false,
                color: item == selectedItem
                    ? extendedTheme.stepBarActiveColor
                    : extendedTheme.inputIconColor,
                text: item.name.fromPascalCaseToTitle(),
                onPressed: () => {},
                type: ButtonType.stepbar));
  }

  Widget build(BuildContext context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return SizedBox(
        height: 30,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            bool isItemActionable =
                (actionable || (index < selectedItem.index)) ? true : false;
            return _buildStepBarItem(
                listItems[index], context, extendedTheme, isItemActionable);
          },
        ));
  }
}
