import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/balance_info.dart';

import '../animated_numeric_text.dart';
import '../fade_in.dart';

class BalanceDisplay extends StatefulWidget {
  final AnimationController loadingController;

  BalanceDisplay(this.loadingController);

  @override
  BalanceDisplayState createState() => BalanceDisplayState();
}

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class BalanceDisplayState extends State<BalanceDisplay>
    with TickerProviderStateMixin {
  int balanceNanoWit = 0;
  int availableBalanceNanoWit = 0;
  int lockedBalanceNanoWit = 0;
  int currentValueNanoWit = 0;
  late DbWallet dbWallet;
  late AnimationController _headerController;
  late Animation<double> _headerScaleAnimation;
  late BalanceInfo balanceInfo;

  @override
  void initState() {
    // TODO: implement initState
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    dbWallet = Locator.instance<ApiDashboard>().dbWallet!;
    setBalance();
    _headerScaleAnimation =
        Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
      parent: widget.loadingController,
      curve: headerAniInterval,
    ));
    _headerController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void setBalance() {
    List<Utxo> _utxos = [];

    dbWallet.internalAccounts.forEach((int index, Account account) {
      _utxos.addAll(account.utxos);
    });
    dbWallet.externalAccounts.forEach((int index, Account account) {
      _utxos.addAll(account.utxos);
    });
    this.balanceInfo = BalanceInfo.fromUtxoList(_utxos);
  }

  Widget timeLockDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Locked:', style: theme.textTheme.caption!),
        AnimatedNumericText(
          initialValue: nanoWitToWit(lockedBalanceNanoWit),
          targetValue: nanoWitToWit(balanceInfo.lockedNanoWit),
          curve: Interval(0, .5, curve: Curves.easeOut),
          controller: _headerController,
          style: theme.textTheme.caption!,
        ),
        SizedBox(width: 5),
        Text('wit', style: theme.textTheme.caption!),
      ],
    );
  }

  Widget dashboardBlocWidget() {
    final theme = Theme.of(context);
    final accentColor = theme.primaryColor;
    final bgMat = createMaterialColor(accentColor);
    final linearGradient = LinearGradient(colors: [
      bgMat.shade700,
      bgMat.shade600,
      bgMat.shade500,
      bgMat.shade400,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 418.0, 78.0));

    ///
    ///
    return Container(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedNumericText(
                  initialValue: nanoWitToWit(currentValueNanoWit),
                  targetValue: nanoWitToWit(balanceInfo.availableNanoWit),
                  curve: Interval(0, .5, curve: Curves.easeOut),
                  controller: _headerController,
                  style: theme.textTheme.bodyText1!,
                ),
                SizedBox(width: 5),
                Text(
                  'wit',
                  style: theme.textTheme.bodyText1!,
                ),
              ],
            ),
            (balanceInfo.lockedNanoWit > 0)
                
            
                ? timeLockDisplay(context)
                : Text('Wallet Balance', style: theme.textTheme.bodyText1)
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplorerBloc, ExplorerState>(
      builder: (context, state) {
        return dashboardBlocWidget();
      },
      listener: (context, state) {
        if (state.status == ExplorerStatus.ready) {
          setState(() {
            setBalance();
          });
        }
        if (state.status == ExplorerStatus.dataloaded) {
          setState(() {
            dbWallet = state.dbWallet!;
            setBalance();
            _headerController.reset();
            _headerController.forward();
          });
        }
      },
    );
  }
}
