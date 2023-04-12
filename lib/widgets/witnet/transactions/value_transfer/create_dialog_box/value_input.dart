import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../auto_size_text.dart';

class ValueInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ValueInputState();
}

class ValueInputState extends State<ValueInput>
    with SingleTickerProviderStateMixin {
  double witValue = 0;
  late TextEditingController _valueController;
  @override
  void initState() {
    _valueController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              TextField(
                textAlign: TextAlign.right,
                controller: _valueController,
                onChanged: (String value) {
                  setState(() {
                    if (value == '') {
                      witValue = 0;
                    } else
                      witValue = double.parse(value);
                  });
                },
                decoration: new InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,9}')),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Image.asset('assets/img/favicon.ico'),
              //Icon(FontAwesomeIcons.box,size: 15,)
            ],
          ),
        ),
        SizedBox(
          width: 7,
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              //Icon(FontAwesomeIcons.box,size: 15,)
              AutoSizeText(
                'WIT',
                maxLines: 1,
                minFontSize: 9,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 7,
        ),
      ],
    );
  }
}
