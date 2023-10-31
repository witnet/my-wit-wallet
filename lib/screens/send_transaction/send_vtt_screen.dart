import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/get_localize_string.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/step_bar.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/01_recipient_step.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/02_select_miner_fee.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/03_review_step.dart';

class CreateVttScreen extends StatefulWidget {
  static final route = '/create-vtt';
  @override
  CreateVttScreenState createState() => CreateVttScreenState();
}

enum VTTsteps {
  Transaction,
  MinerFee,
  Review,
}

class CreateVttScreenState extends State<CreateVttScreen>
    with TickerProviderStateMixin {
  GlobalKey<RecipientStepState> transactionFormState =
      GlobalKey<RecipientStepState>();
  GlobalKey<SelectMinerFeeStepState> minerFeeState =
      GlobalKey<SelectMinerFeeStepState>();
  late AnimationController _loadingController;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  Wallet? currentWallet;
  dynamic nextAction;
  dynamic nextStep;
  ScrollController scrollController = ScrollController(keepScrollOffset: false);

  String selectedItem = localizedVTTsteps[VTTsteps.Transaction]!;

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
    int currentStep = localizedVTTsteps.values.toList().indexOf(selectedItem);
    if (currentStep + 1 < VTTsteps.values.length) {
      scrollController.jumpTo(0.0);
      setState(() {
        selectedItem = localizedVTTsteps.values.elementAt(currentStep + 1);
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
    VTTsteps currentStep = localizedVTTsteps.entries
        .firstWhere((element) => element.value == selectedItem)
        .key;
    bool isTransactionFormValid = currentStep == VTTsteps.Transaction &&
        (transactionFormState.currentState != null &&
            transactionFormState.currentState!.validateForm(force: true));
    bool isMinerFeeFormValid = currentStep == VTTsteps.MinerFee &&
        (minerFeeState.currentState != null &&
            minerFeeState.currentState!.validateForm(force: true));
    return (isTransactionFormValid |
        isMinerFeeFormValid |
        (currentStep == VTTsteps.Review));
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

  SelectMinerFeeStep _selectMinerFeeStep() {
    return SelectMinerFeeStep(
      key: minerFeeState,
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
      originRoute: CreateVttScreen.route,
      nextAction: _setNextAction,
      currentWallet: currentWallet!,
    );
  }

  Widget stepToBuild() {
    VTTsteps currentStep = localizedVTTsteps.entries
        .firstWhere((element) => element.value == selectedItem)
        .key;
    if (currentStep == VTTsteps.Transaction) {
      return _recipientStep();
    } else if (currentStep == VTTsteps.MinerFee) {
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
            listItems: localizedVTTsteps.values.toList(),
            selectedItem: selectedItem,
            actionable: false,
            onChanged: (item) => {
                  setState(() {
                    selectedItem = localizedVTTsteps.entries
                        .firstWhere((element) => element.value == item)
                        .value;
                  }),
                }),
        SizedBox(height: 24),
        stepToBuild(),
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
                  return CreateVttScreen();
                },
                maintainState: false,
                settings: RouteSettings(name: CreateVttScreen.route)));
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
        actions: _actions(),
      );
    });
  }

  BlocListener _vttCreateBlocListener() {
    return BlocListener<VTTCreateBloc, VTTCreateState>(
      listener: (BuildContext context, VTTCreateState state) {},
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
