import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/colors.dart';

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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: WitnetPallet.darkBlue2, //background color of dropdown button
        border: Border.all(
            color: WitnetPallet.darkBlue2,
            width: 1), //border of dropdown button
        borderRadius:
            BorderRadius.circular(4), //border raiuds of dropdown button
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: DropdownButton<String>(
          value: selectedItem,
          focusColor: WitnetPallet.white,
          iconEnabledColor: WitnetPallet.white, //Icon color
          style: TextStyle(
              color: WitnetPallet.darkGrey, //Font color
              fontSize: 16 //font size on dropdown button
              ),
          selectedItemBuilder: (BuildContext context) {
            return listItems.map<Widget>((String item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: const TextStyle(
                      color: WitnetPallet.white,
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
          onChanged: (String? value) => {
            onChanged(value)
          }),
      ),
    );
  }
}
