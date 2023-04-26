import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/value_input.dart';

import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/value_transfer_output_container.dart';

class RecipientAddressInput extends StatefulWidget {
  RecipientAddressInput(
      {Key? key,
      required this.onAddValueTransferOutput,
      required this.validAddressCallback})
      : super(key: key);
  final Function onAddValueTransferOutput;
  final Function validAddressCallback;
  late final String? address;
  @override
  RecipientAddressInputState createState() => RecipientAddressInputState();
}

class RecipientAddressInputState extends State<RecipientAddressInput>
    with SingleTickerProviderStateMixin {
  String address = '';
  double witValue = 0;
  int timeLock = 0;
  late TextEditingController _addressController;
  late TextEditingController _valueController;
  late TextEditingController _timeLockController;

  late AnimationController _loadingController;
  bool? useTimeLock = false;

  @override
  void initState() {
    _addressController = TextEditingController();
    _valueController = TextEditingController();
    _timeLockController = TextEditingController();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    super.initState();
  }

  ValueTransferOutput buildVTO(
      {required String address, required int value, int timeLock = 0}) {
    return ValueTransferOutput.fromJson({
      'pkh': address,
      'value': witToNanoWit(witValue),
      'timelock': timeLock
    });
  }

  Widget buildOutputCards(
      BuildContext context, List<ValueTransferOutput> outputs) {
    List<Widget> _cards = [];

    for (int i = 0; i < outputs.length - 1; i++) {
      _cards.add(ValueTransferOutputContainer(vto: outputs[i]));
      _cards.add(SizedBox(
        height: 3,
      ));
    }

    return Container(
      child: Column(
        children: List<Widget>.from(_cards),
      ),
    );
  }

  Widget outputCards() {
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
        builder: (context, state) {
      if (state.vttCreateStatus == VTTCreateStatus.building) {
        return Container(
          child: Column(
            children: [
              Row(
                children: [
                  buildOutputCards(context, state.vtTransaction.body.outputs),
                ],
              )
            ],
          ),
        );
      }
      return Container(
        child: Column(),
      );
    });
  }

  Widget buildAddressField() {
    return Container(
      decoration: BoxDecoration(
          //border: Border.all(color: Colors.grey)
          ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      TextField(
                        decoration: new InputDecoration(
                          labelText: "To",
                          hintText: 'wit1...',
                        ),
                        controller: _addressController,
                        onSubmitted: (String value) => null,
                        onChanged: (String value) {
                          setState(() {
                            address = value;
                          });
                        },
                      ),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      if (widget.validAddressCallback(address))
                        Icon(
                          FontAwesomeIcons.check,
                          size: 15,
                        ),
                    ],
                  )),
            ],
          ),
          if (widget.validAddressCallback(address)) ValueInput()
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _addressController.dispose();
    _valueController.dispose();
    _timeLockController.dispose();
    _loadingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildAddressField();
  }
}
