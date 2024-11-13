import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

typedef void StringCallback(String? value);

class StepBar extends StatelessWidget {
  final String selectedItem;
  final bool actionable;
  final List<String> listItems;
  final StringCallback onChanged;

  const StepBar({
    required this.actionable,
    required this.selectedItem,
    required this.listItems,
    required this.onChanged,
  });

  Widget _buildStepBarItem(String item, BuildContext context,
      ExtendedTheme extendedTheme, bool isItemActionable) {
    return PaddedButton(
      padding: EdgeInsets.zero,
      enabled: isItemActionable,
      autofocus: item == selectedItem,
      label: item,
      text: item,
      type: ButtonType.stepbar,
      onPressed: () => {
        if (isItemActionable) {onChanged(item)}
      },
    );
  }

  Widget build(BuildContext context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            bool isItemActionable =
                (actionable || (index < listItems.indexOf(selectedItem)));
            return _buildStepBarItem(
                listItems[index], context, extendedTheme, isItemActionable);
          },
        ));
  }
}
