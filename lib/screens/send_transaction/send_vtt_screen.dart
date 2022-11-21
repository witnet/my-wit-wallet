import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_stepper.dart';

class CreateVttScreen extends StatefulWidget {
  static final route = '/create-vtt';
  @override
  CreateVttScreenState createState() => CreateVttScreenState();
}

class CreateVttScreenState extends State<CreateVttScreen>
    with TickerProviderStateMixin {
  Wallet? walletStorage;
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

  Widget _buildSendVttForm() {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(color: theme.cardColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: AutoSizeText(
                        'Value Transfer Transaction ',
                        maxLines: 1,
                        minFontSize: 14,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: RoundButton(
                      onPressed: () {
                        BlocProvider.of<VTTCreateBloc>(context)
                            .add(ResetTransactionEvent());
                        Navigator.of(context).pop();
                      },
                      icon: Text(
                        'X',
                        style: TextStyle(fontSize: 33),
                      ),
                      loadingController: _loadingController,
                      label: '',
                      size: 25,
                    ),
                  ),
                ],
              ),
              _buildVttForm(theme, Size(600, 600), state.currentWallet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVttForm(ThemeData theme, Size deviceSize, Wallet currentWallet) {
    return Container(
      decoration: BoxDecoration(),
      height: deviceSize.height * 0.8,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              VttStepper(
                walletStorage: currentWallet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DashboardLayout(dashboardChild: _buildSendVttForm()),
    );
  }
}
