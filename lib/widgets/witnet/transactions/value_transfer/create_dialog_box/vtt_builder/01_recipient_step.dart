import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/time_lock_calendar/datetime_picker.dart';

import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/fee_type_selector_chip.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/value_transfer_output_container.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet/data_structures.dart';
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
  double valueWit = 0;
  int timeLock = 0;
  int balanceNanoWit = 0;
  String _feeType = 'Stinky';
  String _stinkyFee = '0';
  String _lowFee = '0';
  String _mediumFee = '0';
  String _highFee = '0';
  String _opulentFee = '0';
  String _selectedFee = '';

  late TextEditingController _addressController;
  final TextEditingController _valueController = TextEditingController();

  late TextEditingController _timeLockController;
  late AnimationController _loadingController;
  late DbWallet _dbWallet;
  late DateTime selectedTimelock;
  bool timelockSet = false;

  bool useTimelock = false;
  @override
  void initState() {
    _addressController = TextEditingController();

    _timeLockController = TextEditingController();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    _dbWallet = apiDashboard.dbWallet!;
    balanceNanoWit = _dbWallet.balanceNanoWit();
    BlocProvider.of<VTTCreateBloc>(context)
        .add(AddSourceWalletEvent(dbWallet: _dbWallet));
    Timer.periodic(Duration(seconds: 5), (timer) async {
      this.priority();
    });

    super.initState();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _setPriorities(
      String stinky, String low, String medium, String high, String opulent) {
    setState(() {
      _stinkyFee = stinky;
      _lowFee = low;
      _mediumFee = medium;
      _highFee = high;
      _opulentFee = opulent;
    });
  }

  void _setFee(String priority, String feeNanoWit) {
    if (feeNanoWit != "") {
      // Only use estimated fee if selected is not custom
      int absoluteFeeNanoWit = int.parse(feeNanoWit);
      BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
          feeType: FeeType.Absolute, feeNanoWit: absoluteFeeNanoWit));
    }

    setState(() {
      _selectedFee = priority;
    });
  }

  String? get _errorText {
    final text = _valueController.value.text;
    if (text == '') {
      return null;
    }

    if (valueWit > balanceNanoWit) {
      return 'Insufficient Funds';
    }
  }

  Widget buildValueInput(BuildContext context) {
    ApiCreateWallet apiCreateWallet = Locator.instance<ApiCreateWallet>();
    
    
    return ValueListenableBuilder(
      // Note: pass _controller to the animation argument
      valueListenable: _valueController,
      builder: (context, TextEditingValue value, __) {
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
                      int outputValueNanoWit = 0;
                      String changeAddress =
                          BlocProvider.of<VTTCreateBloc>(context)
                              .changeAccount
                              .address;
                      BlocProvider.of<VTTCreateBloc>(context)
                          .outputs
                          .forEach((element) {
                        if (element.pkh.address != changeAddress) {
                          outputValueNanoWit += element.value;
                        }
                      });
                      setState(() {
                        if (value == '') {
                          valueWit = 0;
                          balanceNanoWit =
                              _dbWallet.balanceNanoWit() - outputValueNanoWit;
                        } else {
                          valueWit = double.parse(value);

                          balanceNanoWit = _dbWallet.balanceNanoWit() -
                              outputValueNanoWit -
                              witToNanoWit(valueWit);
                        }
                      });
                    },
                    decoration: new InputDecoration(
                        labelText: "Amount", errorText: _errorText),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,9}')),
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
      },
    );
  }

  bool validAddress(String address) {
    if (address.length == 42) {
      try {
        Address _address = Address.fromAddress(address);
        assert(_address.address.isNotEmpty);
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
        if (account.address == address) isChangeAccount = true;
      });

      /// only add a card if it is not a change account
      if (!isChangeAccount)
        _cards.add(ValueTransferOutputContainer(vto: outputs[i]));
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
      final deviceSize = MediaQuery.of(context).size;
      final theme = Theme.of(context);
      double cardWidth;
      if (deviceSize.width > 400) {
        cardWidth = (400 * 0.7);
      } else
        cardWidth = deviceSize.width * 0.7;

      if (state.vttCreateStatus == VTTCreateStatus.building) {
        return Container(
          width: cardWidth,
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(.1)),
          child: Column(
            children: [
              if (state.vtTransaction.body.outputs.isNotEmpty)
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
              if (state.vtTransaction.body.outputs.isNotEmpty)
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

  bool validVTO(String address) {
    
    print(validAddress(address));
    print(valueWit);
    print(balanceNanoWit);
    if (!validAddress(address) || valueWit == 0) return false;
    if (nanoWitToWit(balanceNanoWit) < 0) return false;
    return true;
  }

  bool _addVTO(BuildContext context) {
    BlocProvider.of<VTTCreateBloc>(context).add(AddValueTransferOutputEvent(
        output: ValueTransferOutput.fromJson({
      'pkh': recipientAddress,
      'value': witToNanoWit(valueWit),
      'time_lock': timeLock
    }), merge: true));

    setState(() {
      _addressController.text = '';
      recipientAddress = '';
      valueWit = 0;
      _valueController.text = '';
    });

    return false;
  }

  bool isTimelockSet() {
    bool _set = BlocProvider.of<VTTCreateBloc>(context).timelockSet;
    if (_set) {
      timeLock = BlocProvider.of<VTTCreateBloc>(context)
              .selectedTimelock!
              .millisecondsSinceEpoch ~/
          1000;
    }
    return _set;
  }

  DateTime? getTimelock() {
    return BlocProvider.of<VTTCreateBloc>(context).selectedTimelock;
  }

  Widget _buildRecipientInput() {
    {
      return Container(
        decoration: BoxDecoration(),
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

  Future<void> _showDateTimePicker() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DateTimePicker();
      },
    );
  }

  Widget _feeBody(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
        padding: EdgeInsets.all(5),
        child: Column(children: [
          // _buildTimeLockInput(),
          Row(
            children: [
              Expanded(
                flex: 1,
                // child: _feeTypeButtonGroup(context),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: AutoSizeText(
                    'Choose a fee: ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: theme.primaryColor),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  // child: _feeTypeButtonGroup(context),
                  child: _buildFeeTypeButtonGroup(context))
            ],
          ),

          _selectedFee == "Custom" ? FeeTypeSelectorChip() : Container(),

          /*
          Row(
            children: [
              AutoSizeText(
                'Utxo Selection Strategy',
                maxLines: 1,
                minFontSize: 9,
              ),
              Tooltip(
                  height: 75,
                  textStyle: TextStyle(fontSize: 12, color: Colors.white),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  preferBelow: false,
                  message: 'Strategy to sort our own unspent outputs pool',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FontAwesomeIcons.questionCircle,
                      size: 15,
                    ),
                    iconSize: 10,
                    padding: EdgeInsets.all(3),
                  )),

           */
          //UtxoSelectionStrategyChip(),
        ]));
  }

  Widget _buildFeeTypeButtonGroup(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        children: <Map<String, String>>[
      {"label": "Stinky", "value": _stinkyFee},
      {"label": "Low", "value": _lowFee},
      {"label": "Medium", "value": _mediumFee},
      {"label": "High", "value": _highFee},
      {"label": "Opulent", "value": _opulentFee},
      {"label": "Custom", "value": ""},
    ].map<OutlinedButton>((Map<String, String> _priority) {
      return OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                width: 1.0,
                color: _selectedFee == _priority["label"]
                    ? theme.primaryColor
                    : theme
                        .inputDecorationTheme.enabledBorder!.borderSide.color),
          ),
          onPressed: () {
            _setFee(_priority["label"]!, _priority["value"]!);
          },
          child: Row(children: [
            Expanded(flex: 1, child: Text(_priority["label"]!)),
            Expanded(
                flex: 0,
                child: _priority["value"] != ""
                    ? Text("${_priority["value"]!} nanoWits")
                    : Text("")),
          ]));
    }).toList());
  }

  Future<bool> priority() async {
    try {
      var resp = await Locator.instance.get<ApiExplorer>().priority();

      this._setPriorities(
        resp["vttStinky"]["priority"]["nanoWit"],
        resp["vttLow"]["priority"]["nanoWit"],
        resp["vttMedium"]["priority"]["nanoWit"],
        resp["vttHigh"]["priority"]["nanoWit"],
        resp["vttOpulent"]["priority"]["nanoWit"],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget buildTimeLockInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            flex: 4,
            child: Column(
              children: [
                (isTimelockSet())
                    ? Container(
                        child: Text('${getTimelock().toString()}'),
                      )
                    : Container(
                        child: Text('Timelock: (none)'),
                      )
              ],
            )),
        SizedBox(
          width: 7,
        ),
        Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                _showDateTimePicker();
              },
              icon: Icon(
                FontAwesomeIcons.calendarAlt,
              ),
              iconSize: 20,
              padding: EdgeInsets.all(3),
            )),
        Expanded(
          flex: 1,
          child: Tooltip(
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
      ],
    );
  }

  Widget buildForm(BuildContext context) {
    final theme = Theme.of(context);
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: AutoSizeText(
                    'Available Funds: ',
                    maxLines: 1,
                    minFontSize: 12,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: theme.primaryColor),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: AutoSizeText(
                    '${nanoWitToWit(balanceNanoWit)} wit',
                    maxLines: 1,
                    minFontSize: 12,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          _buildRecipientInput(),
          SizedBox(
            height: 15,
          ),
          if (validAddress(recipientAddress)) buildValueInput(context),
          SizedBox(
            height: 5,
          ),
          if (validAddress(recipientAddress)) buildTimeLockInput(),
          SizedBox(
            height: 5,
          ),
          outputCards(),
          _feeBody(context),
          Row(
            children: [
              if (validVTO(recipientAddress))
                TextButton(
                  onPressed: () {
                    _addVTO(context);
                    BlocProvider.of<VTTCreateBloc>(context)
                        .add(ValidateTransactionEvent());
                  },
                  child: const Text('Additional Recipient'),
                ),
              if (validVTO(recipientAddress))
                TextButton(
                  onPressed: () {
                    _addVTO(context);
                    BlocProvider.of<VTTCreateBloc>(context)
                        .add(ValidateTransactionEvent());
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
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
      builder: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.initial) {
          return buildForm(context);
        }
        if (state.vttCreateStatus == VTTCreateStatus.building) {
          return buildForm(context);
        }
        return Container(
          child: Column(
            children: [
              _buildRecipientInput(),
              SizedBox(
                height: 5,
              ),
              if (validAddress(recipientAddress)) buildValueInput(context),
            ],
          ),
        );
      },
    );
  }
}
