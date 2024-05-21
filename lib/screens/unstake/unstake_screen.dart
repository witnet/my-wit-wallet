import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/step_bar.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/01_recipient_step.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/03_review_step.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_modal.dart';

class UnstakeScreen extends StatefulWidget {
  static final route = '/unstake';
  @override
  UnstakeScreenState createState() => UnstakeScreenState();
}

enum UnstakeSteps {
  Transaction,
  Review,
}

class UnstakeScreenState extends State<UnstakeScreen>
    with TickerProviderStateMixin {
  GlobalKey<RecipientStepState> transactionFormState =
      GlobalKey<RecipientStepState>();
  late AnimationController _loadingController;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  Wallet? currentWallet;
  dynamic nextAction;
  dynamic nextStep;
  bool _insufficientUtxos = false;
  ScrollController scrollController = ScrollController(keepScrollOffset: false);

  String selectedItem = localizedUnstakeSteps[UnstakeSteps.Transaction]!;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    _getCurrentWallet();
    _getPriorityEstimations();
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
    int currentStep =
        localizedUnstakeSteps.values.toList().indexOf(selectedItem);
    if (currentStep + 1 < UnstakeSteps.values.length) {
      scrollController.jumpTo(0.0);
      setState(() {
        selectedItem = localizedUnstakeSteps.values.elementAt(currentStep + 1);
      });
    }
  }

  void _getCurrentWallet() {
    setState(() {
      currentWallet = database.walletStorage.currentWallet;
      BlocProvider.of<VTTCreateBloc>(context)
          .add(AddSourceWalletsEvent(currentWallet: currentWallet!));
    });
  }

  void _getPriorityEstimations() {
    BlocProvider.of<VTTCreateBloc>(context).add(SetPriorityEstimationsEvent());
  }

  bool _isNextStepAllow() {
    UnstakeSteps currentStep = localizedUnstakeSteps.entries
        .firstWhere((element) => element.value == selectedItem)
        .key;
    bool isTransactionFormValid = currentStep == UnstakeSteps.Transaction &&
        (transactionFormState.currentState != null &&
            transactionFormState.currentState!.validateForm(force: true));
    return (isTransactionFormValid | (currentStep == UnstakeSteps.Review));
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
      nextAction: _setNextAction,
      goNext: () {
        nextAction().action();
        if (_isNextStepAllow()) goToNextStep();
      },
      currentWallet: currentWallet!,
    );
  }

  ReviewStep _reviewStep() {
    return ReviewStep(
      originRoute: UnstakeScreen.route,
      nextAction: _setNextAction,
      currentWallet: currentWallet!,
    );
  }

  Widget stepToBuild() {
    UnstakeSteps currentStep = localizedUnstakeSteps.entries
        .firstWhere((element) => element.value == selectedItem)
        .key;
    if (_insufficientUtxos) {
      return _recipientStep();
    }
    if (currentStep == UnstakeSteps.Transaction) {
      return _recipientStep();
    } else {
      return _reviewStep();
    }
  }

  Widget _buildSendVttForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepBar(
            listItems: localizedUnstakeSteps.values.toList(),
            selectedItem: selectedItem,
            actionable: false,
            onChanged: (item) => {
                  setState(() {
                    selectedItem = localizedUnstakeSteps.entries
                        .firstWhere((element) => element.value == item)
                        .value;
                  }),
                }),
        SizedBox(height: 24),
        stepToBuild(),
        SizedBox(height: Platform.isAndroid ? 24 : 0),
        ..._actions(),
      ],
    );
  }

  BlocListener _dashboardBlocListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
        Navigator.pushReplacement(
            context,
            CustomPageRoute(
                builder: (BuildContext context) {
                  return UnstakeScreen();
                },
                maintainState: false,
                settings: RouteSettings(name: UnstakeScreen.route)));
      },
      child: _dashboardBlocBuilder(),
    );
  }

  BlocBuilder _dashboardBlocBuilder() {
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      return DashboardLayout(
        scrollController: scrollController,
        dashboardChild: _vttCreateBlocListener(),
        actions: [],
      );
    });
  }

  BlocListener _vttCreateBlocListener() {
    final theme = Theme.of(context);
    return BlocListener<VTTCreateBloc, VTTCreateState>(
      listener: (BuildContext context, VTTCreateState state) {
        if (state.vttCreateStatus == VTTCreateStatus.insufficientFunds) {
          ScaffoldMessenger.of(context).clearSnackBars();
          buildGeneralExceptionModal(
            theme: theme,
            context: context,
            error: localization.insufficientFunds,
            message: localization.insufficientUtxosAvailable,
            originRouteName: UnstakeScreen.route,
            originRoute: UnstakeScreen(),
          );
          setState(() {
            _insufficientUtxos = true;
          });
        }
      },
      child: _vttCreateBlocBuilder(),
    );
  }

  BlocBuilder _vttCreateBlocBuilder() {
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
        builder: (BuildContext context, VTTCreateState state) {
      return _buildSendVttForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
        builder: (context, state) {
      return _dashboardBlocListener();
    });
  }
}
