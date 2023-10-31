import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/get_localize_string.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/02_select_miner_fee.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/03_review_step.dart';

typedef void VoidCallback();

class SpeedUpVtt extends StatefulWidget {
  final VoidCallback closeSetting;
  final GeneralTransaction speedUpTx;

  SpeedUpVtt({
    Key? key,
    required this.closeSetting,
    required this.speedUpTx,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => SpeedUpVttState();
}

class SpeedUpVttState extends State<SpeedUpVtt> {
  Map<String, dynamic>? signedMessage;
  ApiDatabase db = Locator.instance.get<ApiDatabase>();
  GlobalKey<SelectMinerFeeStepState> minerFeeState =
      GlobalKey<SelectMinerFeeStepState>();
  dynamic nextAction;
  bool selectMinerFeeStep = true;
  get isMinerFeeValid =>
      minerFeeState.currentState != null &&
      minerFeeState.currentState!.validateForm(force: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _setNextAction(action) {
    if (mounted) {
      setState(() {
        nextAction = action;
      });
    }
  }

  void showReviewStep() {
    setState(() => selectMinerFeeStep = false);
  }

  void goNext() {
    if (nextAction != null) {
      nextAction().action();
      if (isMinerFeeValid) showReviewStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (previous, current) {
        return ClosableView(closeSetting: widget.closeSetting, children: [
          Text(
            localization.speedUpTxTitle,
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 24),
          selectMinerFeeStep
              ? SelectMinerFeeStep(
                  key: minerFeeState,
                  minFee: widget.speedUpTx.fee,
                  nextAction: _setNextAction,
                  goNext: goNext,
                  currentWallet: db.walletStorage.currentWallet,
                )
              : ReviewStep(
                  originRoute: DashboardScreen.route,
                  nextAction: _setNextAction,
                  speedUpTx: widget.speedUpTx,
                  currentWallet: db.walletStorage.currentWallet,
                ),
          SizedBox(height: 16),
          PaddedButton(
              padding: EdgeInsets.zero,
              text: localization.continueLabel,
              type: ButtonType.primary,
              enabled: true,
              onPressed: goNext)
        ]);
      },
    );
  }
}
