import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/recipient_address_input.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/01_recipient_step.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/02_review_step.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

class VttStepper extends StatefulWidget {
  final WalletStorage walletStorage;

  VttStepper({required this.walletStorage});
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
  }

  void addValueTransferOutput(
      {required String pkh, required double witValue, required int timeLock}) {
    setState(() {
      BlocProvider.of<VTTCreateBloc>(context).add(
        AddValueTransferOutputEvent(
          output: ValueTransferOutput.fromJson({
            'pkh': pkh,
            'value': witToNanoWit(witValue),
            'time_lock': timeLock,
          }), merge: true,
        ),
      );
    });
  }

  void onStepCancel() {
    if (_index > 0) {
      setState(() {
        _index -= 1;
      });
    } else {
      BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
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

        assert(_address.address.isNotEmpty);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Widget controlsBuilder(
      BuildContext context, ControlsDetails controlsDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[],
    );
  }
  /*

    Widget controlsBuilder(BuildContext context,
      {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[],
    );
  }
   */

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
            child: ReviewStep(),
            //TransactionSettingsStep(),
          ),
        ),
      ],
    );
  }
}
