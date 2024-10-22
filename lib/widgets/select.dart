import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';

typedef void StringCallback(String? value);

class SelectItem {
  final String key;
  final String label;

  SelectItem(this.key, this.label);
}

class Select extends StatelessWidget {
  final String selectedItem;
  final bool cropLabel;
  final int? cropMiddleLength;
  final List<SelectItem> listItems;
  final StringCallback onChanged;

  const Select({
    required this.selectedItem,
    this.cropLabel = false,
    this.cropMiddleLength,
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
    Widget content;
    if (cropMiddleLength != null) {
      content = Text(
        item.cropMiddle(cropMiddleLength!),
        overflow: TextOverflow.ellipsis,
        style: selected
            ? extendedTheme.monoRegularText
                ?.copyWith(color: extendedTheme.selectedTextColor)
            : extendedTheme.monoRegularText
                ?.copyWith(fontWeight: FontWeight.normal),
      );
    } else {
      content = Text(
        item,
        overflow: TextOverflow.ellipsis,
        style: selected
            ? extendedTheme.monoRegularText
                ?.copyWith(color: extendedTheme.selectedTextColor)
            : extendedTheme.monoRegularText
                ?.copyWith(fontWeight: FontWeight.normal),
      );
    }

    return DropdownMenuItem<String>(value: item, child: content);
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: extendedTheme.selectBackgroundColor,
        borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: DropdownButton<String>(
            value: selectedItem,
            dropdownColor: extendedTheme.dropdownBackgroundColor,
            focusColor: extendedTheme.dropdownBackgroundColor,
            iconEnabledColor: extendedTheme.selectedTextColor,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedTheme.dropdownTextColor, fontSize: 16),
            selectedItemBuilder: (BuildContext context) {
              return listItems.map<Widget>((SelectItem item) {
                return Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: cropLabel
                      ? buildCropItem(item.label, context, true)
                      : Text(
                          item.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedTheme.selectedTextColor,
                              fontWeight: FontWeight.normal),
                        ),
                );
              }).toList();
            },
            underline: Container(),
            borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
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
