import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/balance_info.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet_wallet/widgets/animated_numeric_text.dart';

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
  late WalletStorage walletStorage;
  late AnimationController _headerController;
  late BalanceInfo balanceInfo;

  @override
  void initState() {
    // TODO: implement initState
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    walletStorage = Locator.instance<ApiDatabase>().walletStorage;
    setBalance();
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
    this.balanceInfo = walletStorage.balanceNanoWit();
  }

  Widget timeLockDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Locked:', style: theme.textTheme.bodySmall!),
        AnimatedNumericText(
          initialValue: nanoWitToWit(lockedBalanceNanoWit),
          targetValue: nanoWitToWit(balanceInfo.lockedNanoWit),
          curve: Interval(0, .5, curve: Curves.easeOut),
          controller: _headerController,
          style: theme.textTheme.bodySmall!,
        ),
        SizedBox(width: 5),
        Text('wit', style: theme.textTheme.bodySmall!),
      ],
    );
  }

  Widget dashboardBlocWidget() {
    final theme = Theme.of(context);

    return Container(
      child: Column(
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
                style: theme.textTheme.bodyLarge!,
              ),
              SizedBox(width: 5),
              Text(
                'wit',
                style: theme.textTheme.bodyLarge!,
              ),
            ],
          ),
          (balanceInfo.lockedNanoWit > 0)
              ? timeLockDisplay(context)
              : Text('Wallet Balance', style: theme.textTheme.bodyLarge)
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
            walletStorage = state.walletStorage!;
            setBalance();
            _headerController.reset();
            _headerController.forward();
          });
        }
      },
    );
  }
}
