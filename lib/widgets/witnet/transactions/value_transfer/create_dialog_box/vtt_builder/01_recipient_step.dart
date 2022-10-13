import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/util/storage/database/balance_info.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/time_lock_calendar/datetime_picker.dart';

import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/fee_type_selector_chip.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/value_transfer_output_container.dart';
import '../../../../../../util/storage/database/wallet_storage.dart';
import '../recipient_address_input.dart';

class RecipientStep extends StatefulWidget {
  final VoidCallback? onStepCancel;
  final VoidCallback? onStepContinue;
  final Function addValueTransferOutput;
  late final RecipientAddressInput recipientAddressInput;

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
  late BalanceInfo balanceInfo;
  late TextEditingController _addressController;
  final TextEditingController _valueController = TextEditingController();

  late TextEditingController _timeLockController;
  late AnimationController _loadingController;
  late WalletStorage _walletStorage;
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
    _walletStorage = apiDashboard.walletStorage!;
    balanceInfo = _walletStorage.balanceNanoWit();
    BlocProvider.of<VTTCreateBloc>(context)
        .add(AddSourceWalletsEvent(walletStorage: _walletStorage));
    super.initState();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  String? get _errorText {
    final text = _valueController.value.text;
    if (text == '') {
      return null;
    } else {
      if (valueWit > balanceInfo.availableNanoWit) {
        return 'Insufficient Funds';
      }
      return null;
    }
  }

  Widget buildValueInput(BuildContext context) {
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
                          outputValueNanoWit += element.value.toInt();
                        }
                      });
                      setState(() {
                        if (value == '') {
                          valueWit = 0;
                          balanceInfo.availableNanoWit = balanceInfo.availableNanoWit  - outputValueNanoWit;
                        } else {
                          valueWit = double.parse(value);
                          balanceInfo.availableNanoWit = balanceInfo.availableNanoWit - outputValueNanoWit;
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
      _walletStorage.wallets.forEach((key, wallet) {
        wallet.internalAccounts.forEach((key, account) {
          if (account.address == address) isChangeAccount = true;
        });
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
    print(balanceInfo);
    if (!validAddress(address) || valueWit == 0) return false;
    if (nanoWitToWit(balanceInfo.availableNanoWit) < 0) return false;
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
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          // _buildTimeLockInput(),
          Row(
            children: [
              AutoSizeText(
                'Fee Type',
                maxLines: 1,
                minFontSize: 9,
              ),
              Tooltip(
                  height: 100,
                  message:
                      'By default, \'Weighted fee\' is selected.\n\nThe amount of the fee will be calculated, taking into account the weight of the transaction.\n\nTo set an absolute fee, you need to toggle \'Absolute fee\' in the advance options below.',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FontAwesomeIcons.circleQuestion,
                      size: 15,
                    ),
                    iconSize: 10,
                    padding: EdgeInsets.all(3),
                  )),
            ],
          ),

          FeeTypeSelectorChip(),
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
        ],
      ),
    );
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
                FontAwesomeIcons.calendarDays,
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
                  FontAwesomeIcons.circleQuestion,
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
                    '${nanoWitToWit(balanceInfo.availableNanoWit)} wit',
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
