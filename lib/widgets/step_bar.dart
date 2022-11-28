import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';

typedef void StringCallback(VTTsteps? value);

class StepBar extends StatelessWidget {
  final VTTsteps selectedItem;
  final bool actionable;
  final List<VTTsteps> listItems;
  final StringCallback onChanged;

  const StepBar({
    required this.actionable,
    required this.selectedItem,
    required this.listItems,
    required this.onChanged,
  });

  Widget _buildStepBarItem(VTTsteps item, BuildContext context) {
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return Container(
        alignment: Alignment.center,
        child: actionable
            ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(item.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: item == selectedItem
                                  ? extendedTheme.stepBarActiveColor
                                  : extendedTheme.stepBarColor))),
                  onTap: () => {onChanged(item)},
                ))
            : Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(item.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: item == selectedItem
                            ? extendedTheme.stepBarActiveColor
                            : extendedTheme.inputIconColor))));
  }

  Widget build(BuildContext context) {
    return SizedBox(
        height: 30,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            return _buildStepBarItem(listItems[index], context);
          },
        ));
  }
}
