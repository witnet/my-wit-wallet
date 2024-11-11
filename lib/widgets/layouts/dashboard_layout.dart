import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/current_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/bottom_navigation.dart';
import 'package:my_wit_wallet/widgets/send_receive.dart';
import 'package:my_wit_wallet/widgets/stake_unstake.dart';
import 'package:my_wit_wallet/widgets/top_navigation.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/screens/login/view/init_screen.dart';
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
  Wallet get currentWallet =>
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
  PanelUtils get panel => Locator.instance.get<PanelUtils>();
  Widget get panelContent => panel.getContent();

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

  Widget _buildBottomNavigation() {
    double actionsHeight = PANEL_ACTION_HEIGHT * 2;
    return BottomNavigation(
        currentScreen: currentRoute(context),
        onSendReceiveAction: () async => {
              panel.setHeight(actionsHeight),
              setState(() => panel.setContent(SendReceiveButtons())),
              await panel.toggle(),
            },
        onStakeUnstakeAction: () async => {
              panel.setHeight(actionsHeight),
              setState(() => panel.setContent(StakeUnstakeButtons())),
              await panel.toggle(),
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

        return Layout(
          scrollController: widget.scrollController,
          topNavigation: TopNavigation(
                  onShowWalletList: () async => {
                        setState(() => panel.setContent(WalletList())),
                        await panel.toggle(),
                      },
                  currentScreen: currentRoute(context),
                  currentWallet: currentWallet)
              .getNavigationActions(context),
          isDashboard: true,
          bottomNavigation: _buildBottomNavigation(),
          widgetList: [_body, SizedBox(height: 16)],
          actions: [],
          slidingPanel: panelContent,
        );
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
