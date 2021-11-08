import 'package:flutter/material.dart';

class VttBuilderTypeChip extends StatefulWidget {
  const VttBuilderTypeChip({Key? key}) : super(key: key);

  @override
  State<VttBuilderTypeChip> createState() =>
      VttBuilderTypeChipState();
}

class VttBuilderTypeChipState extends State<VttBuilderTypeChip> {
  //default value is `Simple`
  int? _value = 0;
  List<String> items = ['Simple', 'Advanced'];
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