import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/create_vtt_bloc.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';

import '../../../../../auto_size_text.dart';
import '../../value_transfer_output_container.dart';
import '../advanced_settings_panel.dart';
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
  int balanceNanoWit = 0;
  late TextEditingController _addressController;
  late TextEditingController _valueController;
  late TextEditingController _timeLockController;
  late AnimationController _loadingController;
  late DbWallet _dbWallet;
  @override
  void initState() {
    _addressController = TextEditingController();
    _valueController = TextEditingController();
    _valueController.addListener(() {

    });
    _timeLockController = TextEditingController();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dbWallet = BlocProvider.of<BlocCreateVTT>(context).dbWallet;
    balanceNanoWit = _dbWallet.balanceNanoWit();
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
        assert (_address.address.isNotEmpty);
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
    for (int i = 0; i < outputs.length; i++) {
      String address = outputs[i].pkh.address;
      bool isChangeAccount = false;
      _dbWallet.internalAccounts.forEach((index, account) {
        if(account.address == address) isChangeAccount = true;
      });
      /// only add a card if it is not a change account
      if(!isChangeAccount) _cards.add(ValueTransferOutputContainer(vto: outputs[i]));

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
      return false;
    }
    return true;
  }


  int _estimatedFeeNanoWit(){


    return 0;
  }

  bool _validAmount(){
    if(witValue<_dbWallet.balanceNanoWit()){

    }

    return false;
  }
  bool _addVTO(BuildContext context, ){

    BlocProvider.of<BlocCreateVTT>(context).add(
        AddValueTransferOutputEvent(output: ValueTransferOutput.fromJson({
          'pkh': recipientAddress,
          'value': witToNanoWit(witValue),
          'time_lock': timeLock
        })
        ));
    //widget.onStepContinue!.call();
    setState(() {
      _addressController.text = '';
      recipientAddress = '';
      witValue = 0;
      _valueController.text = '';

    });

    return false;
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
                    } else{
                      witValue = double.parse(value);
                    }
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

  Widget buildTimeLockInput() {
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

  Widget buildForm(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(height: 5,),
            ],
          ),
          Row(
            children: [
             // AutoSizeText('Available Balance: ${nanoWitToWit(_dbWallet.balanceNanoWit())} Wit'),
            ],
          ),
          
          
          Row(
            children: [
              SizedBox(height: 5,),
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
          //if (validAddress(recipientAddress)) _buildTimeLockInput(),
          SizedBox(
            height: 5,
          ),
          outputCards(),
          AdvancedVttSettingsPanel(),
          Row(
            children: [
              if (validVTO(recipientAddress))
                TextButton(
                  onPressed: () {
                    _addVTO(context);
                    BlocProvider.of<BlocCreateVTT>(context).add(ValidateTransactionEvent());
                  },
                  child: const Text('Additional Recipient'),
                ),
              if (validVTO(recipientAddress))
                TextButton(
                  onPressed: () {
                    _addVTO(context);
                    BlocProvider.of<BlocCreateVTT>(context).add(ValidateTransactionEvent());
                    widget.onStepContinue!.call();
                  },
                  child: const Text('Continue'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocCreateVTT, CreateVTTState>(
      builder: (context, state) {
        if(state is InitialState) {
          return buildForm(context);
        }
        if (state is BuildingVTTState) {
          return buildForm(context);
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
             //if (validAddress(recipientAddress)) _buildTimeLockInput(),
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
