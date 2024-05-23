import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/step_bar.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/01_recipient_step.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/02_select_miner_fee.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/03_review_step.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_modal.dart';

enum TransactionType { Vtt, Stake, Unstake }

class SendTransactionLayout extends StatefulWidget {
  final TransactionType transactionType;
  final String routeName;
  SendTransactionLayout(
      {required this.routeName, required this.transactionType});

  @override
  SendTransactionLayoutState createState() => SendTransactionLayoutState();
}

enum TxSteps {
  Transaction,
  MinerFee,
  Review,
}

class SendTransactionLayoutState extends State<SendTransactionLayout>
    with TickerProviderStateMixin {
  GlobalKey<RecipientStepState> transactionFormState =
      GlobalKey<RecipientStepState>();
  GlobalKey<SelectMinerFeeStepState> minerFeeState =
      GlobalKey<SelectMinerFeeStepState>();
  late AnimationController _loadingController;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  WalletStorage? walletStorage;
  dynamic nextAction;
  dynamic nextStep;
  bool _insufficientUtxos = false;
  ScrollController scrollController = ScrollController(keepScrollOffset: false);
  String? selectedItem;

  Map<TransactionType, String> selectedItemByTxType = {
    TransactionType.Stake: localizedStakeSteps[TxSteps.Transaction]!,
    TransactionType.Unstake: localizedUnstakeSteps[TxSteps.Transaction]!,
    TransactionType.Vtt: localizedVTTsteps[TxSteps.Transaction]!,
  };
  Map<dynamic, String> getLocalizedStepByTxType(
      {required TransactionType transactionType}) {
    switch (transactionType) {
      case TransactionType.Stake:
        return localizedStakeSteps;
      case TransactionType.Unstake:
        return localizedUnstakeSteps;
      case TransactionType.Vtt:
        return localizedVTTsteps;
    }
  }

  bool isCurrentStepValid(
      {required TransactionType transactionType,
      required TxSteps stepToValidate,
      required dynamic currentStep}) {
    return currentStep == stepToValidate;
  }

  Map<dynamic, String> get localizedSteps =>
      getLocalizedStepByTxType(transactionType: widget.transactionType);

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    selectedItem = selectedItemByTxType[widget.transactionType]!;
    _loadingController.forward();
    _getCurrentWallet();
    _setTransactionType();
    if (widget.transactionType != TransactionType.Unstake) {
      _getPriorityEstimations();
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  _setNextAction(action) {
    if (mounted) {
      setState(() {
        nextAction = action;
      });
    }
  }

  void goToNextStep() {
    int currentStep = localizedSteps.values.toList().indexOf(selectedItem!);
    if (currentStep + 1 < localizedSteps.values.length) {
      scrollController.jumpTo(0.0);
      setState(() {
        selectedItem = localizedSteps.values.elementAt(currentStep + 1);
      });
    }
  }

  void _getCurrentWallet() {
    setState(() {
      walletStorage = database.walletStorage;

      BlocProvider.of<TransactionBloc>(context).add(
          AddSourceWalletsEvent(currentWallet: walletStorage!.currentWallet));
    });
  }

  void _setTransactionType() {
    BlocProvider.of<TransactionBloc>(context)
        .add(SetTransactionTypeEvent(transactionType: widget.transactionType));
  }

  void _getPriorityEstimations() {
    BlocProvider.of<TransactionBloc>(context)
        .add(SetPriorityEstimationsEvent());
  }

  bool _isNextStepAllow() {
    TxSteps currentStep = localizedSteps.entries
        .firstWhere((element) => element.value == selectedItem)
        .key;
    bool isTransactionFormValid = currentStep == TxSteps.Transaction &&
        (transactionFormState.currentState != null &&
            transactionFormState.currentState!.validateForm(force: true));
    bool isMinerFeeFormValid = currentStep == TxSteps.MinerFee &&
        (minerFeeState.currentState != null &&
            minerFeeState.currentState!.validateForm(force: true));
    return (isTransactionFormValid |
        isMinerFeeFormValid |
        (currentStep == TxSteps.Review));
  }

  List<Widget> _actions() {
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          text: nextAction != null
              ? nextAction().label
              : localization.continueLabel,
          type: ButtonType.primary,
          enabled: true,
          onPressed: () => {
                if (nextAction != null)
                  {
                    nextAction().action(),
                    if (_isNextStepAllow()) goToNextStep(),
                  },
              }),
    ];
  }

  RecipientStep _recipientStep() {
    return RecipientStep(
      key: transactionFormState,
      routeName: widget.routeName,
      transactionType: widget.transactionType,
      nextAction: _setNextAction,
      goNext: () {
        nextAction().action();
        if (_isNextStepAllow()) goToNextStep();
      },
      walletStorage: walletStorage!,
    );
  }

  SelectMinerFeeStep _selectMinerFeeStep() {
    return SelectMinerFeeStep(
      key: minerFeeState,
      nextAction: _setNextAction,
      goNext: () {
        nextAction().action();
        if (_isNextStepAllow()) goToNextStep();
      },
      currentWallet: walletStorage!.currentWallet,
    );
  }

  ReviewStep _reviewStep() {
    return ReviewStep(
      originRoute: widget.routeName,
      transactionType: widget.transactionType,
      nextAction: _setNextAction,
      currentWallet: walletStorage!.currentWallet,
    );
  }

  Widget stepToBuild() {
    TxSteps currentStep = localizedSteps.entries
        .firstWhere((element) => element.value == selectedItem)
        .key;
    if (_insufficientUtxos) {
      return _recipientStep();
    }
    if (currentStep == TxSteps.Transaction) {
      return _recipientStep();
    } else if (currentStep == TxSteps.MinerFee) {
      return _selectMinerFeeStep();
    } else {
      return _reviewStep();
    }
  }

  Widget _buildSendVttForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepBar(
            listItems: localizedSteps.values.toList(),
            selectedItem: selectedItem!,
            actionable: false,
            onChanged: (item) => {
                  setState(() {
                    selectedItem = localizedSteps.entries
                        .firstWhere((element) => element.value == item)
                        .value;
                  }),
                }),
        SizedBox(height: 24),
        stepToBuild(),
        SizedBox(height: 24),
        ..._actions(),
      ],
    );
  }

  BlocListener _dashboardBlocListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        BlocProvider.of<TransactionBloc>(context).add(ResetTransactionEvent());
        Navigator.pushReplacement(
            context,
            CustomPageRoute(
                builder: (BuildContext context) {
                  return SendTransactionLayout(
                    routeName: widget.routeName,
                    transactionType: widget.transactionType,
                  );
                },
                maintainState: false,
                settings: RouteSettings(name: widget.routeName)));
      },
      child: _dashboardBlocBuilder(),
    );
  }

  BlocBuilder _dashboardBlocBuilder() {
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      return DashboardLayout(
        scrollController: scrollController,
        dashboardChild: _transactionBlocListener(),
        actions: [],
      );
    });
  }

  BlocListener _transactionBlocListener() {
    final theme = Theme.of(context);
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (BuildContext context, TransactionState state) {
        if (state.transactionStatus == TransactionStatus.insufficientFunds) {
          ScaffoldMessenger.of(context).clearSnackBars();
          buildGeneralExceptionModal(
            theme: theme,
            context: context,
            error: localization.insufficientFunds,
            message: localization.insufficientUtxosAvailable,
            originRouteName: widget.routeName,
            originRoute: SendTransactionLayout(
                transactionType: widget.transactionType,
                routeName: widget.routeName),
          );
          setState(() {
            _insufficientUtxos = true;
          });
        }
      },
      child: _transactionBlocBuilder(),
    );
  }

  BlocBuilder _transactionBlocBuilder() {
    return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (BuildContext context, TransactionState state) {
      return _buildSendVttForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
      return _dashboardBlocListener();
    });
  }
}
