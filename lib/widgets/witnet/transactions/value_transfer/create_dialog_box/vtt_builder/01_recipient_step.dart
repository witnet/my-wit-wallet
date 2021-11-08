import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/create_vtt/create_vtt_bloc.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/value_input.dart';

import '../../../../../auto_size_text.dart';
import '../../value_transfer_output_container.dart';
import '../recipient_address_input.dart';

class RecipientStep extends StatefulWidget {
  final VoidCallback? onStepCancel;
  final VoidCallback? onStepContinue;
  final Function addValueTransferOutput;
  late RecipientAddressInput recipientAddressInput;

  RecipientStep({
    required this.onStepContinue,
    required this.onStepCancel,
    required this.addValueTransferOutput,
  });

  @override
  State<StatefulWidget> createState() => RecipientStepState();
}

class RecipientStepState extends State<RecipientStep>
    with SingleTickerProviderStateMixin {
  String recipientAddress = '';
  double witValue = 0;
  int timeLock = 0;
  late TextEditingController _addressController;
  late TextEditingController _valueController;
  late TextEditingController _timeLockController;
  late AnimationController _loadingController;

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

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  bool validAddress(String address) {
    if (address.length == 42) {
      try {
        Address _address = Address.fromAddress(address);

        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  //////////////////////////////////////////////////////////////////////////////
  Widget buildOutputCards(
      BuildContext context, List<ValueTransferOutput> outputs) {
    List<Widget> _cards = [];
    for (int i = 0; i < outputs.length - 1; i++) {
      _cards.add(ValueTransferOutputContainer(vto: outputs[i]));
    }
    return Container(
      child: Column(
        children: List<Widget>.from(_cards),
      ),
    );
  }

  Widget outputCards() {
    return BlocBuilder<BlocCreateVTT, CreateVTTState>(
        builder: (context, state) {
      final deviceSize = MediaQuery.of(context).size;
      final theme = Theme.of(context);
      double cardWidth;
      if (deviceSize.width > 400) {
        cardWidth = (400 * 0.7);
      } else
        cardWidth = deviceSize.width * 0.7;
      if (state is BuildingVTTState) {
        return Container(
          width: cardWidth,
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(.1)),
          child: Column(
            children: [
              if (state.outputs.isNotEmpty)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      child: AutoSizeText(
                        'Outputs:',
                        maxLines: 1,
                        minFontSize: 9,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              if (state.outputs.isNotEmpty)
                Row(
                  children: [
                    buildOutputCards(context, state.outputs),
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

  //////////////////////////////////////////////////////////////////////////////
  bool validVTO(String address) {
    if (!validAddress(address) || witValue == 0) {
      //setState(() {
      //  _loadingController.reverse();
      //});
      return false;
    }

    //setState(() {
    //  _loadingController.forward();
    //});
    return true;
  }

  Widget _buildRecipientInput() {
    {
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
                              recipientAddress = value;
                            });
                          },
                        ),
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        if (validAddress(recipientAddress))
                          Icon(
                            FontAwesomeIcons.check,
                            size: 15,
                          ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildValueInput() {
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

  Widget _buildTimeLockInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 8,
          child: Container(
            //height: deviceSize.width/3,
            child: TextField(
                controller: _timeLockController,
                textAlign: TextAlign.right,
                decoration: new InputDecoration(
                  labelText: "Time Lock",
                  hintText: '0',
                ),
                onChanged: (value) {
                  setState(() {
                    timeLock = int.parse(value);
                    if (value.isEmpty) timeLock = 0;
                  });
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
          ),
        ),
        SizedBox(
          width: 7,
        ),
        Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                FontAwesomeIcons.calendarAlt,
              ),
              iconSize: 20,
              padding: EdgeInsets.all(3),
            )),
        Expanded(
          flex: 1,
          child: Tooltip(
              height: 75,
              textStyle: TextStyle(fontSize: 12, color: Colors.white),
              margin: EdgeInsets.only(left: 20, right: 20),
              preferBelow: false,
              message:
                  'Time Lock is a unix `TimeStamp`.\nNeed to implement the calendar',
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.questionCircle,
                  size: 15,
                ),
                iconSize: 10,
                padding: EdgeInsets.all(3),
              )),
        )
        //
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocCreateVTT, CreateVTTState>(
      builder: (context, state) {
        final deviceSize = MediaQuery.of(context).size;
        final theme = Theme.of(context);
        double cardWidth;
        if (deviceSize.width > 400) {
          cardWidth = (400 * 0.7);
        } else
          cardWidth = deviceSize.width * 0.7;
        if (state is BuildingVTTState || state is InitialState) {
          return Container(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
                _buildRecipientInput(),
                SizedBox(
                  height: 5,
                ),
                if (validAddress(recipientAddress)) _buildValueInput(),
                SizedBox(
                  height: 5,
                ),
                if (validAddress(recipientAddress)) _buildTimeLockInput(),
                SizedBox(
                  height: 5,
                ),
                outputCards(),
                Row(
                  children: [
                    if (validVTO(recipientAddress))
                      TextButton(
                        onPressed: () {
                          BlocProvider.of<BlocCreateVTT>(context).add(
                              AddValueTransferOutputEvent(
                                  pkh: recipientAddress,
                                  value: witToNanoWit(witValue),
                                  timeLock: timeLock));
                          //widget.onStepContinue!.call();
                          setState(() {
                            _addressController.text = '';
                            recipientAddress = '';
                            witValue = 0;
                            _valueController.text = '';
                          });
                        },
                        child: const Text('Additional Recipient'),
                      ),
                    if (validVTO(recipientAddress))
                      TextButton(
                        onPressed: () {
                          BlocProvider.of<BlocCreateVTT>(context).add(
                              AddValueTransferOutputEvent(
                                  pkh: recipientAddress,
                                  value: witToNanoWit(witValue),
                                  timeLock: timeLock));
                          widget.onStepContinue!.call();
                          setState(() {
                            _addressController.text = '';
                            recipientAddress = '';
                            witValue = 0;
                            _valueController.text = '';
                          });
                        },
                        child: const Text('Continue'),
                      ),
                  ],
                ),
              ],
            ),
          );
        }
        return Container(
          child: Column(
            children: [

              _buildRecipientInput(),
              SizedBox(
                height: 5,
              ),
              if (validAddress(recipientAddress)) _buildValueInput(),
              SizedBox(
                height: 5,
              ),
              if (validAddress(recipientAddress)) _buildTimeLockInput(),
              SizedBox(
                height: 5,
              ),
              outputCards(),
            ],
          ),
        );
      },
    );
  }
}
