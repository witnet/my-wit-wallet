import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';

import '../../auto_size_text.dart';

class FeeTypeSelectorChip extends StatefulWidget {
  const FeeTypeSelectorChip({Key? key}) : super(key: key);

  @override
  State<FeeTypeSelectorChip> createState() => FeeTypeSelectorChipState();
}

class FeeTypeSelectorChipState extends State<FeeTypeSelectorChip> {
  int? _value = 0;
  List<String> items = ['Weighted', 'Absolute'];
  late TextEditingController _valueController;
  int absoluteFeeNanoWit = 0;
  @override
  void initState() {
    _valueController = TextEditingController();

    super.initState();
  }

  Widget _buildAbsoluteFeeInput() {
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
                      absoluteFeeNanoWit = 0;
                    } else
                      absoluteFeeNanoWit = int.parse(value);
                    BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
                        feeType: FeeType.Absolute,
                        feeNanoWit: absoluteFeeNanoWit));
                  });
                },
                decoration: new InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                'NANO WIT',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
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
                    if (_value == 0) {
                      BlocProvider.of<VTTCreateBloc>(context)
                          .add(UpdateFeeEvent(feeType: FeeType.Weighted));
                    } else {
                      BlocProvider.of<VTTCreateBloc>(context)
                          .add(UpdateFeeEvent(feeType: FeeType.Absolute));
                    }
                  });
                },
              );
            },
          ).toList(),
        ),
        SizedBox(
          height: 5,
        ),
        if (_value == 1) _buildAbsoluteFeeInput(),
      ],
    );
  }
}
