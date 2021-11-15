import 'package:flutter/material.dart';

class UtxoSelectionStrategyChip extends StatefulWidget {
  const UtxoSelectionStrategyChip({Key? key}) : super(key: key);

  @override
  State<UtxoSelectionStrategyChip> createState() =>
      UtxoSelectionStrategyChipState();
}

class UtxoSelectionStrategyChipState extends State<UtxoSelectionStrategyChip> {
  // default value is small first
  int? _value = 2;
  List<String> items = ['Random', 'Big First', 'Small First'];
  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 5,
      spacing: 5,
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
