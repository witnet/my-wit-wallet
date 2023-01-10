import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:witnet_wallet/widgets/step_bar.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/01_recipient_step.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/02_review_step.dart';

class CreateVttScreen extends StatefulWidget {
  static final route = '/create-vtt';
  @override
  CreateVttScreenState createState() => CreateVttScreenState();
}

enum VTTsteps {
  Transaction,
  Review,
}

class CreateVttScreenState extends State<CreateVttScreen>
    with TickerProviderStateMixin {
  Wallet? walletStorage;
  dynamic nextAction;
  dynamic nextStep;
  List<VTTsteps> stepListItems = VTTsteps.values.toList();
  VTTsteps stepSelectedItem = VTTsteps.Transaction;
  int currentStepIndex = 0;
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

  _clearNextActions() {
    nextAction = null;
  }

  _setNextAction(action) {
    if (mounted) {
      setState(() {
        nextAction = action;
      });
    }
  }

  void goToNextStep() {
    if ((currentStepIndex + 1) < stepListItems.length) {
      currentStepIndex += 1;
      stepSelectedItem = stepListItems[currentStepIndex];
    }
  }

  List<Widget> _actions() {
    return [
      PaddedButton(
          padding: EdgeInsets.only(bottom: 8),
          text: nextAction != null ? nextAction().label : 'Continue',
          type: 'primary',
          enabled: nextAction != null,
          onPressed: () => {
                if (nextAction != null) {nextAction().action(), goToNextStep()},
                _clearNextActions()
              }),
    ];
  }

  Widget _buildSendVttForm() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) {
        if (current.status != DashboardStatus.Ready) {
          Navigator.pushReplacementNamed(context, LoginScreen.route);
          return false;
        } else if (current.currentWallet.id != previous.currentWallet.id) {
          Navigator.pushReplacementNamed(context, DashboardScreen.route);
          return false;
        }
        BlocProvider.of<VTTCreateBloc>(context)
            .add(AddSourceWalletsEvent(currentWallet: current.currentWallet));
        return true;
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepBar(
                actionable: false,
                selectedItem: stepSelectedItem,
                listItems: stepListItems,
                onChanged: (item) => {}),
            SizedBox(height: 16),
            stepSelectedItem == VTTsteps.Transaction
                ? RecipientStep(
                    nextAction: _setNextAction,
                    currentWallet: state.currentWallet,
                  )
                : ReviewStep(
                    nextAction: _setNextAction,
                    currentWallet: state.currentWallet,
                  ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
        builder: (context, state) {
      return WillPopScope(
        onWillPop: () async => false,
        child: DashboardLayout(
          dashboardChild: _buildSendVttForm(),
          actions: _actions(),
        ),
      );
    });
  }
}
