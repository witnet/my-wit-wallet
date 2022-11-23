import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/01_recipient_step.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/02_review_step.dart';

class CreateVttScreen extends StatefulWidget {
  static final route = '/create-vtt';
  @override
  CreateVttScreenState createState() => CreateVttScreenState();
}

class CreateVttScreenState extends State<CreateVttScreen>
    with TickerProviderStateMixin {
  Wallet? walletStorage;
  bool showDetails = false;
  dynamic nextAction;
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
    setState(() {
      nextAction = action;
    });
  }

  void onStepCancel() {
    // clear vttDetails and redirect to tx list
  }

  List<Widget> _actions() {
    return [
      PaddedButton(
          padding: EdgeInsets.only(bottom: 8),
          text: nextAction != null ? nextAction().label : 'Continue',
          type: 'primary',
          enabled: nextAction != null,
          onPressed: () => {
                if (nextAction != null)
                  {nextAction().action(), showDetails = true},
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
        return true;
      },
      builder: (context, state) {
        if (!showDetails) {
          return RecipientStep(
            nextAction: _setNextAction,
            currentWallet: state.currentWallet,
          );
        } else {
          return ReviewStep();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
        builder: (context, state) {
      print('vtt state:: $state');
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
