import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/03_sign_send_dialog.dart';

import '../../../../../../screens/dashboard/api_dashboard.dart';
import '../../../../../../shared/locator.dart';
import '../../../../../auto_size_text.dart';
import '../../fee_container.dart';
import '../../input_container.dart';
import '../../value_transfer_output_container.dart';

class ReviewStep extends StatefulWidget {
  ReviewStep();

  @override
  State<StatefulWidget> createState() => ReviewStepState();
}

class ReviewStepState extends State<ReviewStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _showSignAndSendDialog(
      VTTransactionBody vtTransactionBody) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SignSendDialog(
          vtTransactionBody: vtTransactionBody,
        );
      },
    );
  }

  Widget contentBox(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Container(
      width: deviceSize.width,

      decoration: BoxDecoration(color: theme.splashColor.withOpacity(.1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          inputCards(),
          outputCards(),
          changeCard(),
          feeCard(),
          SizedBox(
            height: 5,
          ),
          BlocBuilder<VTTCreateBloc, VTTCreateState>(
            builder: (context, state) {
              if (state.vttCreateStatus == VTTCreateStatus.building) {
                VTTransactionBody vttBody = state.vtTransaction.body;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () => _showSignAndSendDialog(vttBody),
                        child: Text('Sign')),
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


  Widget buildInputCards(BuildContext context, List<Input> inputs) {
    List<InputUtxo> _inputs = [];
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    DbWallet dbWallet = apiDashboard.dbWallet!;
    List<Widget> _cards = [];
    inputs.forEach((input) {
      dbWallet.externalAccounts.forEach((index, value) {
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
      dbWallet.internalAccounts.forEach((index, value) {
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
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
        builder: (context, state) {
      final deviceSize = MediaQuery.of(context).size;

      double cardWidth;
      if (deviceSize.width > 400) {
        cardWidth = (400 * 0.7);
      } else
        cardWidth = deviceSize.width * 0.7;
      if (state.vttCreateStatus == VTTCreateStatus.building) {
        return Container(
          width: cardWidth,
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
                  buildInputCards(context, state.vtTransaction.body.inputs),
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
                  buildOutputCards(context, state.vtTransaction.body.outputs),
                ],
              )
            ],
          ),
        );
      }
      return Container(
        child: Column(

        ),
      );
    });
  }

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
          child: Column(
            children: [
              Row(
                children: [
                  buildChangeCard(context, state.vtTransaction.body.outputs),
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

  Widget buildFeeCard(
    BuildContext context) {
    int fee = BlocProvider.of<VTTCreateBloc>(context).feeNanoWit;
    return FeeContainer(feeValue: fee);
  }

  Widget feeCard() {
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
          child: Column(
            children: [
              Row(
                children: [
                  buildFeeCard(context),
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

  @override
  Widget build(BuildContext context) {
    return contentBox(context);
  }

}
