import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:witnet/schema.dart';

typedef void GeneralTransactionCallback(GeneralTransaction value);

class SpeedUpBtn extends StatefulWidget {
  final GeneralTransactionCallback speedUpTx;
  final GeneralTransaction transaction;

  SpeedUpBtn({Key? key, required this.speedUpTx, required this.transaction})
      : super(key: key);

  @override
  SpeedUpBtnState createState() => SpeedUpBtnState();
}

class SpeedUpBtnState extends State<SpeedUpBtn> {
  final ScrollController _scroller = ScrollController();
  Wallet currentWallet =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
  @override
  void initState() {
    super.initState();
    _getPriorityEstimations();
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  void _getPriorityEstimations() {
    BlocProvider.of<VTTCreateBloc>(context).add(SetPriorityEstimationsEvent());
  }

  void _setVttWalletSource() {
    BlocProvider.of<VTTCreateBloc>(context)
        .add(AddSourceWalletsEvent(currentWallet: currentWallet));
  }

  void addVttOutput() {
    _clearBuildVtt();
    _setVttWalletSource();
    BlocProvider.of<VTTCreateBloc>(context).add(AddValueTransferOutputEvent(
        speedUpTx: widget.transaction,
        filteredUtxos: false,
        currentWallet: currentWallet,
        output: ValueTransferOutput.fromJson({
          'pkh': widget.transaction.vtt!.inputs.first.address,
          'value': widget.transaction.vtt!.outputs.first.value.toInt(),
          'time_lock': 0
        }),
        merge: true));
  }

  void _clearBuildVtt() {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return PaddedButton(
      padding: EdgeInsets.only(top: 8),
      text: localization.speedUp,
      onPressed: () => {
        addVttOutput(),
        widget.speedUpTx(widget.transaction),
      },
      type: ButtonType.small,
    );
  }
}
