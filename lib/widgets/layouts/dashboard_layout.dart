import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'dart:math' as math;
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:witnet_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/widgets//wallet_list.dart';
import 'package:witnet_wallet/widgets/layouts/layout.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';
import 'package:witnet_wallet/util/extensions/string_extensions.dart';

import 'package:witnet_wallet/shared/locator.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _goToSettings() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.pushReplacementNamed(context, PreferencePage.route);
  }

  Future<void> _showCreateVTTDialog() async {
    Navigator.pushReplacementNamed(context, CreateVttScreen.route);
  }

  Future<void> _showReceiveDialog() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
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
        : extendedTheme.headerTextColor;
  }

  Widget _buildDashboardActions() {
    String currentRoute = ModalRoute.of(context)!.settings.name!;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PaddedButton(
        color: getButtonColorByRoute(CreateVttScreen.route),
        padding: EdgeInsets.all(0),
        text: 'Send',
        onPressed: currentRoute != CreateVttScreen.route
            ? _showCreateVTTDialog
            : () {},
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
        onPressed: currentRoute != DashboardScreen.route ? () => {
            BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent()),
            Navigator.pushReplacementNamed(context, DashboardScreen.route),
          } : () {},
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
        onPressed: currentRoute != ReceiveTransactionScreen.route
            ? _showReceiveDialog
            : () {},
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
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      Wallet currentWallet =
          Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
      Account currentAccount =
          Locator.instance.get<ApiDatabase>().walletStorage.currentAccount;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            '${currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits()} ${WitUnit.Wit.name}',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Text(
              currentAccount.address.cropMiddle(18),
              overflow: TextOverflow.ellipsis,
              style: extendedTheme.monoRegularText!
                  .copyWith(color: theme.textTheme.headlineMedium!.color),
            )),
            Flexible(
                child: IconButton(
                    color: theme.textTheme.headlineSmall?.color,
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                    iconSize: 12,
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: currentAccount.address));
                    },
                    icon: Icon(FontAwesomeIcons.copy))),
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
    String currentRoute = ModalRoute.of(context)!.settings.name!;
    return [
      MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Icon(FontAwesomeIcons.gear,
                size: 30, color: getButtonColorByRoute(PreferencePage.route)),
            onTap: currentRoute != PreferencePage.route
                ? () => _goToSettings()
                : () {},
          )),
    ];
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state.status == LoginStatus.LoggedOut) {
          Navigator.pushReplacementNamed(context, LoginScreen.route);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
          builder: (BuildContext context, LoginState loginState) {
        Widget _body;
        Widget? _walletList;
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
            _walletList = WalletList();
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
          navigationActions: _navigationActions(),
          dashboardActions: _buildDashboardHeader(),
          widgetList: [
            _body,
          ],
          actions: widget.actions,
          slidingPanel: _walletList,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: _authBuilder(),
    );
  }
}
