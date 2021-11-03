import 'package:flutter/material.dart';

class FeeTypeSelectorChip extends StatefulWidget {
  const FeeTypeSelectorChip({Key? key}) : super(key: key);

  @override
  State<FeeTypeSelectorChip> createState() => FeeTypeSelectorChipState();
}

class FeeTypeSelectorChipState extends State<FeeTypeSelectorChip> {
  int? _value = 0;
  List<String> items = ['Weighted', 'Absolute'];
  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: List<Widget>.generate(
        items.length,
            (int index) {
          return ChoiceChip(
            label: Text('${items[index]}'),
            selected: _value == index,
            onSelected: (bool selected) {
              setState(() {
                _value = index;
              });
            },
          );
        },
      ).toList(),
    );
  }
}