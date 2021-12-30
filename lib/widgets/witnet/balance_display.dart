



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';

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
  late DbWallet dbWallet;
  late AnimationController _headerController;
  late Animation<double> _headerScaleAnimation;

  @override
  void initState() {
    // TODO: implement initState
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    dbWallet = Locator.instance<ApiDashboard>().dbWallet!;
    _headerScaleAnimation =
        Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
          parent: widget.loadingController,
          curve: headerAniInterval,
        ));
    super.initState();
  }

  @override
  void dispose(){
    _headerController.dispose();
    super.dispose();
  }
  int balance() {
    int _balanceNanoWit = 0;
    dbWallet.internalAccounts.forEach((address, account) {
      _balanceNanoWit += account.balance;
    });
    dbWallet.externalAccounts.forEach((address, account) {
      _balanceNanoWit += account.balance;
    });
    return _balanceNanoWit;
  }

  Widget explorerWatcher() {
    return Container(child: BlocBuilder<BlocExplorer, ExplorerState>(
      builder: (context, state) {
        Container container = Container();


        if (state is ReadyState) {
          return dashboardBlocWidget(balance());
        } else if (state is DataLoadingState) {
          return dashboardBlocWidget(balance());
        } else if (state is DataLoadedState) {
        } else if (state is ExplorerErrorState) {}
        return container;
      },
    ));
  }

  Widget dashboardBlocWidget(int balanceNanoWit) {
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
    return Container(child: BlocBuilder<BlocDashboard, DashboardState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedNumericText(
                  initialValue: 0,
                  targetValue: nanoWitToWit(balanceNanoWit),
                  curve: Interval(0, .5, curve: Curves.easeOut),
                  controller: _headerController,
                  style: theme.textTheme.headline5!.copyWith(
                    foreground: Paint()..shader = linearGradient,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'wit',
                  style: theme.textTheme.headline5!.copyWith(
                    fontWeight: FontWeight.w300,
                    color: accentColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            Text('Wallet Balance', style: theme.textTheme.caption),
          ],
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[

            ScaleTransition(
              scale: _headerScaleAnimation,
              child: FadeIn(
                  controller: _headerController,
                  curve: headerAniInterval,
                  fadeDirection: FadeDirection.bottomToTop,
                  offset: .5,
                  duration: Duration(milliseconds: 600),
                  child: dashboardBlocWidget(balance())),
            ),
          ],
        )
    );
  }
}