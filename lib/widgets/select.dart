import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';

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
        color: theme.selectBackgroundColor, //background color of dropdown button
        borderRadius:
            BorderRadius.circular(4), //border raiuds of dropdown button
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: DropdownButton<String>(
            value: selectedItem,
            dropdownColor: theme.dropdownBackgroundColor,
            focusColor: theme.dropdownBackgroundColor,
            iconEnabledColor: theme.dropdownTextColor, //Icon color
            style: TextStyle(
                color: theme.dropdownTextColor, //Font color
                fontSize: 16 //font size on dropdown button
                ),
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
            }, //dropdown background color
            underline: Container(),
            borderRadius: BorderRadius.circular(4), //remove underline
            isExpanded: true,
            items: listItems.map<DropdownMenuItem<String>>((String value) {
              return _buildWalletDropdownItem(value);
            }).toList(),
            onChanged: (String? value) => {onChanged(value)}),
      ),
    );
  }
}
