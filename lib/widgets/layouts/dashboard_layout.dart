import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/clear_and_redirect.dart';
import 'package:my_wit_wallet/util/current_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/get_sized_height.dart';
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
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
  late Timer explorerTimer;
  bool isAddressCopied = false;
  bool isCopyAddressFocus = false;
  FocusNode _copyToClipboardFocusNode = FocusNode();
  WalletStorage get walletStorage =>
      Locator.instance.get<ApiDatabase>().walletStorage;
  Wallet get currentWallet => walletStorage.currentWallet;
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

  Widget _buildDashboardListener(Widget content) {
    return BlocListener<DashboardBloc, DashboardState>(
        listenWhen: (previousState, currentState) {
          if ((previousState.currentWalletId != DEFAULT_WALLET_ID) &&
              (previousState.currentWalletId != currentState.currentWalletId)) {
            clearAndRedirectToDashboard(context);
          }
          return true;
        },
        listener: (BuildContext context, DashboardState state) {},
        child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (BuildContext context, DashboardState state) {
          return content;
        }));
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
        double walletListSize =
            getWalletListSize(context, walletStorage.wallets.length);
        double maxSize = MediaQuery.of(context).size.height * 0.8;
        return Layout(
          scrollController: widget.scrollController,
          topNavigation: TopNavigation(
                  onShowWalletList: () async => {
                        // Sets panel height that shows the wallet list
                        panel.setHeight(walletListSize > maxSize
                            ? maxSize
                            : walletListSize),
                        setState(() => panel.setContent(WalletList())),
                        await panel.toggle(),
                      },
                  currentScreen: currentRoute(context),
                  currentWallet: currentWallet)
              .getNavigationActions(context),
          isDashboard: true,
          bottomNavigation: _buildBottomNavigation(),
          widgetList: [_buildDashboardListener(_body), SizedBox(height: 16)],
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
