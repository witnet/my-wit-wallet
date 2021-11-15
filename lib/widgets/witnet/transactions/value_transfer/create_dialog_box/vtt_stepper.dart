import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/create_vtt/create_vtt_bloc.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/recipient_address_input.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/01_recipient_step.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/02_review_step.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/fee_container.dart';

import '../../../../round_button.dart';
import '../../fee_type_selector_chip.dart';
import '../../utxo_selection_strategy_chip.dart';
import '../input_container.dart';
import '../value_transfer_output_container.dart';

class VttStepper extends StatefulWidget {
  VttStepper({
    required this.externalAccounts,
    required this.internalAccounts,
  });
  final Map<String, Account> externalAccounts;
  final Map<String, Account> internalAccounts;
  @override
  State<StatefulWidget> createState() => VttStepperState();
}

class VttStepperState extends State<VttStepper> {
  int _index = 0;

  List<ValueTransferOutput> outputs = [];
  List<Input> inputs = [];
  final addressInputkey = new GlobalKey<RecipientAddressInputState>();
  @override
  void initState() {
    super.initState();

    BlocProvider.of<BlocCreateVTT>(context).add(AddAccountsEvent(
        externalAccounts: widget.externalAccounts,
        internalAccounts: widget.internalAccounts));
  }

  void addValueTransferOutput(
      {required String pkh, required double witValue, required int timeLock}) {
    setState(() {
      outputs.add(ValueTransferOutput.fromJson({
        'pkh': pkh,
        'value': witToNanoWit(witValue),
        'timelock': timeLock,
      }));
    });
  }

  void addInput(String outputPointer) {
    setState(() {
      inputs.add(Input.fromJson({'output_pointer': outputPointer}));
    });
  }

  void onStepCancel() {
    if (_index > 0) {
      setState(() {
        _index -= 1;
      });
    } else {
      BlocProvider.of<BlocCreateVTT>(context).add(ResetTransactionEvent());
      Navigator.of(context).pop();
    }
  }

  void onStepContinue() {
    if (_index <= 0) {
      setState(() {
        _index += 1;
      });
    }
  }

  void onStepTapped(int index) {}
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

  Widget controlsBuilder(BuildContext context,
      {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: ClampingScrollPhysics(),
      type: StepperType.vertical,
      currentStep: _index,
      onStepCancel: onStepCancel,
      onStepContinue: onStepContinue,
      onStepTapped: onStepTapped,
      controlsBuilder: controlsBuilder,
      steps: <Step>[
        Step(
          title: Text('Recipient'),
          content: RecipientStep(
              onStepCancel: onStepCancel,
              onStepContinue: onStepContinue,
              addValueTransferOutput: addValueTransferOutput),
        ),
        Step(
          title: Text('Review'),
          content: Container(
            alignment: Alignment.topCenter,
            child: ReviewStep(
              externalAccounts: widget.externalAccounts,
              internalAccounts: widget.internalAccounts,
            ),
            //TransactionSettingsStep(),
          ),
        ),
        Step(
          title: Text('Sign and Send'),
          content: Container(
            child: FeeTypeSelectorChip(),
          ),
        ),
      ],
    );
  }
}

class TransactionSettingsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          AutoSizeText(
            'Fee Type',
            maxLines: 1,
            minFontSize: 9,
          ),
          Row(
            children: [FeeTypeSelectorChip()],
          ),
          SizedBox(
            height: 10,
          ),
          AutoSizeText(
            'Utxo Selection Strategy',
            maxLines: 1,
            minFontSize: 9,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: deviceSize.width / 4,
                child: AutoSizeText(
                  'Utxo Selection Strategy Utxo Selection Strategy',
                  maxLines: 5,
                  minFontSize: 9,
                ),
              ),
            ],
          ),
          UtxoSelectionStrategyChip(),
        ],
      ),
    );
  }
}

class AdvancedVttSettingsPanel extends StatefulWidget {
  @override
  State<AdvancedVttSettingsPanel> createState() =>
      AdvancedVttSettingsPanelState();
}

class AdvancedVttSettingsPanelState extends State<AdvancedVttSettingsPanel> {
  bool _isOpenMain = false;

  Widget _body(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            children: [
              AutoSizeText(
                'Fee Type',
                maxLines: 1,
                minFontSize: 9,
              ),
              Tooltip(
                  height: 100,
                  textStyle: TextStyle(fontSize: 12, color: Colors.white),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  preferBelow: false,
                  message:
                      'By default, \'Weighted fee\' is selected.\n\nThe amount of the fee will be calculated, taking into account the weight of the transaction.\n\nTo set an absolute fee, you need to toggle \'Absolute fee\' in the advance options below.',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FontAwesomeIcons.questionCircle,
                      size: 15,
                    ),
                    iconSize: 10,
                    padding: EdgeInsets.all(3),
                  )),
            ],
          ),
          Row(
            children: [],
          ),
          FeeTypeSelectorChip(),
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
            ],
          ),
          //UtxoSelectionStrategyChip(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ExpansionPanel mainPanel = ExpansionPanel(
        headerBuilder: (context, isOpen) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Text('Advanced Settings')],
                )
              ],
            ),
          );
        },
        body: _body(context),
        isExpanded: _isOpenMain,
        canTapOnHeader: true);
    return ExpansionPanelList(
      children: [mainPanel],
      expansionCallback: (int index, bool isOpen) {
        setState(() {
          _isOpenMain = !isOpen;
        });
      },
      elevation: 0,
    );
  }
}
