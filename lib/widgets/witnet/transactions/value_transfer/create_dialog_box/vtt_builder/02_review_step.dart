import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/create_vtt/create_vtt_bloc.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/03_sign_send_dialog.dart';

import '../../../../../auto_size_text.dart';
import '../../../../../round_button.dart';
import '../../../fee_type_selector_chip.dart';
import '../../fee_container.dart';
import '../../input_container.dart';
import '../../value_transfer_output_container.dart';

class ReviewStep extends StatefulWidget {
  ReviewStep({
    required this.externalAccounts,
    required this.internalAccounts,
  });

  final Map<String, Account> externalAccounts;
  final Map<String, Account> internalAccounts;

  @override
  State<StatefulWidget> createState() => ReviewStepState();
}

class ReviewStepState extends State<ReviewStep>
    with SingleTickerProviderStateMixin {
  late UtxoPool utxoPool;
  Map<String, List<Utxo>> allUtxos = {};
  late AnimationController _loadingController;
  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    widget.externalAccounts.forEach((key, account) {
      allUtxos[key] = account.utxos;
    });

    widget.internalAccounts.forEach((key, account) {
      allUtxos[key] = account.utxos;
    });
    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _showSignAndSendDialog(VTTransactionBody vtTransactionBody) async {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final List<String> localAddresses = allUtxos.keys.toList();
    print(localAddresses);

    Map<String, int> signers = {};

    double cardWidth;
    if (deviceSize.width > 400) {
      cardWidth = (400 * 0.7);
    } else
      cardWidth = deviceSize.width * 0.7;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SignSendDialog(vtTransactionBody: vtTransactionBody,);
      },
    );
  }

  Widget contentBox(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final List<String> localAddresses = allUtxos.keys.toList();

    double cardWidth;
    if (deviceSize.width > 400) {
      cardWidth = (400 * 0.7);
    } else
      cardWidth = deviceSize.width * 0.7;
    return Container(
      width: deviceSize.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [FeeTypeSelectorChip()],
          ),
          inputCards(),
          outputCards(),
          changeCard(),
          feeCard(),
          SizedBox(
            height: 5,
          ),
          BlocBuilder<BlocCreateVTT, CreateVTTState>(
            builder: (context, state) {
              if (state is BuildingVTTState) {
                VTTransactionBody vttBody = VTTransactionBody(inputs: state.inputs, outputs: state.outputs);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed:()=> _showSignAndSendDialog(vttBody), child: Text('Send')),
                  ],
                );
              }
              return Container(
                child: Column(),
              );
            },
          ),
        ],
      ),

      //AdvancedVttSettingsPanel(localAddresses: localAddresses,),
    );
  }

  Widget signAndSendTransaction(BuildContext context) {
    // dialog to prompt for password

    final deviceSize = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: EdgeInsets.all(0),
      elevation: 0,
      child: Container(
          decoration: BoxDecoration(),
          height: deviceSize.height * 0.7,
          child: contentBox(context)),
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  Widget buildInputCards(BuildContext context, List<Input> inputs) {
    List<InputUtxo> _inputs = [];

    print('input cards');
    print(inputs);
    List<Widget> _cards = [];
    inputs.forEach((input) {
      widget.externalAccounts.forEach((key, value) {
        value.utxos.forEach((element) {
          if (input.toString() == element.toInput().toString()) {
            _inputs.add(InputUtxo(
                address: value.address,
                utxo: element,
                value: element.value,
                path: value.path));
          }
        });
      });
      widget.internalAccounts.forEach((key, value) {
        value.utxos.forEach((element) {
          if (input.toString() == element.toInput().toString()) {
            _inputs.add(InputUtxo(
                address: value.address,
                utxo: element,
                value: element.value,
                path: value.path));
          }
        });
      });
    });

    _inputs.forEach((inputUtxo) {
      _cards.add(InputContainer(
        inputUtxo: inputUtxo,
      ));
    });

    return Container(
      child: Column(
        children: List<Widget>.from(_cards),
      ),
    );
  }

  Widget inputCards() {
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
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3),
                    child: AutoSizeText(
                      'Inputs:',
                      maxLines: 1,
                      minFontSize: 9,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  buildInputCards(context, state.inputs),
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
  Widget buildChangeCard(
      BuildContext context, List<ValueTransferOutput> outputs) {
    List<Widget> _cards = [];
    if (outputs.isNotEmpty)
      _cards.add(ValueTransferOutputContainer(vto: outputs.last));

    return Container(
      child: Column(
        children: List<Widget>.from(_cards),
      ),
    );
  }

  Widget changeCard() {
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
              Row(
                children: [
                  buildChangeCard(context, state.outputs),
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
  Widget buildFeeCard(
    BuildContext context,
    List<Input> inputs,
    List<ValueTransferOutput> outputs,
  ) {
    int inputValue = 0;

    List<InputUtxo> _inputs = [];

    inputs.forEach((input) {
      widget.externalAccounts.forEach((key, value) {
        value.utxos.forEach((element) {
          if (input.toString() == element.toInput().toString()) {
            _inputs.add(InputUtxo(
                address: value.address,
                utxo: element,
                value: element.value,
                path: value.path));
          }
        });
      });
      widget.internalAccounts.forEach((key, value) {
        value.utxos.forEach((element) {
          if (input.toString() == element.toInput().toString()) {
            _inputs.add(InputUtxo(
                address: value.address,
                utxo: element,
                value: element.value,
                path: value.path));
          }
        });
      });
    });

    _inputs.forEach((element) {
      inputValue += element.value;
    });
    int outputValue = 0;
    outputs.forEach((element) {
      outputValue += element.value;
    });
    int feeValue = inputValue - outputValue;

    return FeeContainer(feeValue: feeValue);
  }

  Widget feeCard() {
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
              Row(
                children: [
                  buildFeeCard(context, state.inputs, state.outputs),
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
  @override
  Widget build(BuildContext context) {
    return contentBox(context);
  }
  //////////////////////////////////////////////////////////////////////////////

}
