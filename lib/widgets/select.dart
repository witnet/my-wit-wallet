import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

DropdownMenuItem<String> _buildWalletDropdownItem(String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}

typedef void StringCallback(String? value);

class Select extends StatelessWidget {
  final String selectedItem;
  final List<String> listItems;
  final StringCallback onChanged;

  const Select({
    required this.selectedItem,
    required this.listItems,
    required this.onChanged,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<ExtendedTheme>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.selectBackgroundColor,
        borderRadius: BorderRadius.circular(4),
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
              return listItems.map<Widget>((String item) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: TextStyle(
                        color: theme.selectedTextColor,
                        fontWeight: FontWeight.normal),
                  ),
                );
              }).toList();
            },
            underline: Container(),
            borderRadius: BorderRadius.circular(4),
            isExpanded: true,
            items: listItems
                .map<DropdownMenuItem<String>>(_buildWalletDropdownItem)
                .toList(),
            onChanged: onChanged),
      ),
    );
  }
}
