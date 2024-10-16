import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/current_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/is_desktop_size.dart';
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/balance.dart';
import 'package:my_wit_wallet/widgets/balance_details.dart';
import 'package:my_wit_wallet/widgets/bottom_navigation.dart';
import 'package:my_wit_wallet/widgets/send_receive.dart';
import 'package:my_wit_wallet/widgets/stake_unstake.dart';
import 'package:my_wit_wallet/widgets/top_navigation.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/screens/login/view/init_screen.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/wallet_list.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

// MaterialPageRoute without transition
class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder, maintainState, settings})
      : super(
            builder: builder, maintainState: maintainState, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class DashboardLayout extends StatefulWidget {
  final ScrollController? scrollController;
  final Widget dashboardChild;
  final List<Widget> actions;

  DashboardLayout(
      {required this.dashboardChild,
      required this.actions,
      this.scrollController});

  @override
  DashboardLayoutState createState() => DashboardLayoutState();
}

class DashboardLayoutState extends State<DashboardLayout>
    with TickerProviderStateMixin {
  Wallet? walletStorage;
  late Timer explorerTimer;
  bool isAddressCopied = false;
  bool isCopyAddressFocus = false;
  FocusNode _copyToClipboardFocusNode = FocusNode();
  PanelUtils panel = PanelUtils();
  Widget get _panelContent => panel.getContent();

  @override
  void initState() {
    if (this.mounted) _copyToClipboardFocusNode.addListener(_handleFocus);
    super.initState();
  }

  @override
  void dispose() {
    _copyToClipboardFocusNode.removeListener(_handleFocus);
    super.dispose();
  }

  _handleFocus() {
    setState(() {
      isCopyAddressFocus = _copyToClipboardFocusNode.hasFocus;
    });
  }

  Widget _buildDashboardHeader(final Wallet wallet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Balance(
            onShowBalanceDetails: () => {
                  setState(() {
                    panel.toggle(BalanceDetails(
                      balance: wallet.balanceNanoWit(),
                      stakedBalance: wallet.stakedNanoWit(),
                    ));
                  })
                }),
        if (isDesktopSize) ...[SizedBox(height: 24), _buildBottomNavigation()]
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigation(
        currentScreen: currentRoute(context),
        onSendReceiveAction: () => {
              setState(() {
                panel.toggle(SendReceiveButtons());
              })
            },
        onStakeUnstakeAction: () => {
              setState(() {
                panel.toggle(StakeUnstakeButtons());
              })
            });
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) {
        if (previous.status != LoginStatus.LoggedOut &&
            current.status == LoginStatus.LoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  maintainState: false,
                  builder: (context) => InitScreen(),
                  settings: RouteSettings(name: InitScreen.route)),
              (Route<dynamic> route) => route.isFirst);
        }
        return true;
      },
      listener: (BuildContext context, LoginState state) {},
      child: BlocBuilder<LoginBloc, LoginState>(
          builder: (BuildContext context, LoginState loginState) {
        Widget _body;
        switch (loginState.status) {
          case LoginStatus.LoggedOut:
            _body = Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SpinKitWave(
                  color: theme.primaryColor,
                ),
              ],
            );
            break;
          case LoginStatus.LoginSuccess:
            _body = Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: widget.dashboardChild,
                ),
              ],
            );
            break;
          default:
            _body = Column(
              children: <Widget>[],
            );
        }
        return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (BuildContext context, DashboardState state) {
          Wallet currentWallet =
              Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
          return Layout(
            scrollController: widget.scrollController,
            topNavigation: TopNavigation(
                    onShowWalletList: () =>
                        {setState(() => panel.toggle(WalletList()))},
                    currentScreen: currentRoute(context),
                    currentWallet: currentWallet)
                .getNavigationActions(context),
            dashboardActions: _buildDashboardHeader(currentWallet),
            bottomNavigation: isDesktopSize ? null : _buildBottomNavigation(),
            widgetList: [
              _body,
            ],
            actions: [],
            slidingPanel: _panelContent,
          );
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: _authBuilder(),
    );
  }
}
