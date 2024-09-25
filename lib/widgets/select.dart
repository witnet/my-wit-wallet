import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

typedef void StringCallback(String? value);

class SelectItem {
  final String key;
  final String label;

  SelectItem(this.key, this.label);
}

class Select extends StatelessWidget {
  final String selectedItem;
  final bool cropLabel;
  final List<SelectItem> listItems;
  final StringCallback onChanged;

  const Select({
    required this.selectedItem,
    this.cropLabel = false,
    required this.listItems,
    required this.onChanged,
  });

  DropdownMenuItem<String> _buildWalletDropdownItem(
      SelectItem value, BuildContext context) {
    return DropdownMenuItem<String>(
      value: value.key,
      child: cropLabel
          ? buildCropItem(value.label, context, false)
          : Text(value.label),
    );
  }

  Widget buildCropItem(String item, BuildContext context, bool selected) {
    ThemeData theme = Theme.of(context);
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    return Text(
      item,
      overflow: TextOverflow.ellipsis,
      style: selected
          ? TextStyle(
              fontFamily: extendedTheme.monoRegularText!.fontFamily,
              fontWeight: FontWeight.normal,
              color: extendedTheme.selectedTextColor)
          : TextStyle(
              fontFamily: extendedTheme.monoRegularText!.fontFamily,
              fontWeight: FontWeight.normal),
    );
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<ExtendedTheme>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.selectBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: DropdownButton<String>(
            value: selectedItem,
            dropdownColor: theme.dropdownBackgroundColor,
            focusColor: theme.dropdownBackgroundColor,
            iconEnabledColor: theme.selectedTextColor,
            style: TextStyle(color: theme.dropdownTextColor, fontSize: 16),
            selectedItemBuilder: (BuildContext context) {
              return listItems.map<Widget>((SelectItem item) {
                return Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: cropLabel
                      ? buildCropItem(item.label, context, true)
                      : Text(
                          item.label,
                          style: TextStyle(
                              color: theme.selectedTextColor,
                              fontWeight: FontWeight.normal),
                        ),
                );
              }).toList();
            },
            underline: Container(),
            borderRadius: BorderRadius.circular(24),
            isExpanded: true,
            items: listItems
                .map<DropdownMenuItem<String>>((SelectItem item) =>
                    _buildWalletDropdownItem(item, context))
                .toList(),
            onChanged: onChanged),
      ),
    );
  }
}
