import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'dart:math' as math;
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:witnet_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/widgets//wallet_list.dart';
import 'package:witnet_wallet/widgets/layouts/layout.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class DashboardLayout extends StatefulWidget {
  final Widget dashboardChild;
  final List<Widget> actions;

  DashboardLayout({required this.dashboardChild, required this.actions});

  @override
  DashboardLayoutState createState() => DashboardLayoutState();
}

class DashboardLayoutState extends State<DashboardLayout>
    with TickerProviderStateMixin {
  Wallet? walletStorage;
  List<String>? walletList;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// _goToSettings
  /// [BuildContext] context
  Future<void> _goToSettings() async {
    Navigator.pushReplacementNamed(context, PreferencePage.route);
  }

  Future<void> _showCreateVTTDialog() async {
    Navigator.pushReplacementNamed(context, CreateVttScreen.route);
  }

  Future<void> _showReceiveDialog() async {
    Navigator.pushReplacementNamed(context, ReceiveTransactionScreen.route);
  }

  String? currentRoute() {
    return ModalRoute.of(context)?.settings.name ?? DashboardScreen.route;
  }

  Color? getButtonColorByRoute(route) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return currentRoute() == route
        ? extendedTheme.headerDashboardActiveButton
        : null;
  }

  Widget _buildDashboardActions() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PaddedButton(
        color: getButtonColorByRoute(CreateVttScreen.route),
        padding: EdgeInsets.all(0),
        text: 'Send',
        onPressed: _showCreateVTTDialog,
        icon: Icon(
          FontAwesomeIcons.paperPlane,
          size: 18,
        ),
        type: 'vertical-icon',
      ),
      PaddedButton(
        color: getButtonColorByRoute(DashboardScreen.route),
        padding: EdgeInsets.all(0),
        text: 'Home',
        onPressed: () =>
            Navigator.pushReplacementNamed(context, DashboardScreen.route),
        icon: Icon(
          FontAwesomeIcons.wallet,
          size: 18,
        ),
        type: 'vertical-icon',
      ),
      PaddedButton(
        color: getButtonColorByRoute(ReceiveTransactionScreen.route),
        padding: EdgeInsets.all(0),
        text: 'Receive',
        onPressed: _showReceiveDialog,
        icon: Transform.rotate(
            angle: 90 * math.pi / 90,
            child: Icon(
              FontAwesomeIcons.paperPlane,
              size: 18,
            )),
        type: 'vertical-icon',
      ),
    ]);
  }

  Widget _buildBalanceDisplay() {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            '${state.currentWallet.balanceNanoWit().availableNanoWit} nanoWit',
            textAlign: TextAlign.center,
            style: theme.textTheme.headline4,
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: IconButton(
                    iconSize: 12,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: '${state.currentAddress.address}'));
                    },
                    icon: Icon(FontAwesomeIcons.copy))),
            Flexible(
                child: Text(
              '${state.currentAddress.address}',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headline5,
            ))
          ]),
        ],
      );
    });
  }

  Widget _buildDashboardHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBalanceDisplay(),
        SizedBox(height: 24),
        _buildDashboardActions(),
      ],
    );
  }

  List<Widget> _navigationActions() {
    return [
      MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Icon(FontAwesomeIcons.gear,
                size: 30, color: getButtonColorByRoute(PreferencePage.route)),
            onTap: () => _goToSettings(),
          )),
    ];
  }

  double _actionsSize() {
    if (widget.actions.isEmpty) {
      return 0;
    } else if (widget.actions.length > 1) {
      return 138;
    } else {
      return 80;
    }
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previousState, loginState) {
      if (loginState.status == LoginStatus.LoggedOut) {
        Navigator.pushReplacementNamed(context, LoginScreen.route);
      }
      return true;
    }, builder: (BuildContext context, LoginState loginState) {
      Widget _body;
      Widget? _walletList;
      switch (loginState.status) {
        case LoginStatus.LoggedOut:
          _body = Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SpinKitWave(
                    color: theme.primaryColor,
                  ),
                ],
              ),
            ],
          );
          break;
        case LoginStatus.LoginSuccess:
          _walletList = WalletList();
          _body = Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: widget.dashboardChild,
                  ),
                ],
              ),
            ],
          );
          break;
        default:
          _body = Stack(
            children: <Widget>[
              Column(
                children: <Widget>[],
              ),
            ],
          );
      }
      return Layout(
        navigationActions: _navigationActions(),
        dashboardActions: _buildDashboardHeader(),
        widgetList: [
          _body,
        ],
        actions: widget.actions,
        slidingPanel: _walletList,
        actionsSize: _actionsSize(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: _authBuilder(),
    );
  }
}
