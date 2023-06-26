import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'dart:math' as math;
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/widgets//wallet_list.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/screens/login/view/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';

import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

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

  @override
  void initState() {
    if (this.mounted) _copyToClipboardFocusNode.addListener(_handleFocus);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _handleFocus() {
    setState(() {
      isCopyAddressFocus = _copyToClipboardFocusNode.hasFocus;
    });
  }

  Future<void> _goToSettings() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.pushNamed(context, PreferencePage.route);
  }

  Future<void> _showCreateVTTDialog() async {
    Navigator.pushNamed(context, CreateVttScreen.route);
  }

  Future<void> _showReceiveDialog() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.pushNamed(context, ReceiveTransactionScreen.route);
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
        padding: EdgeInsets.zero,
        text: 'Send',
        onPressed: currentRoute != CreateVttScreen.route
            ? _showCreateVTTDialog
            : () {},
        icon: Icon(
          FontAwesomeIcons.locationArrow,
          size: 18,
        ),
        type: 'vertical-icon',
      ),
      PaddedButton(
        color: getButtonColorByRoute(DashboardScreen.route),
        padding: EdgeInsets.zero,
        text: 'History',
        onPressed: currentRoute != DashboardScreen.route
            ? () => {
                  print('2'),
                  BlocProvider.of<VTTCreateBloc>(context)
                      .add(ResetTransactionEvent()),
                  Navigator.pushNamed(context, DashboardScreen.route),
                  print('currentRoute $currentRoute'),
                }
            : () {},
        icon: Icon(
          FontAwesomeIcons.wallet,
          size: 18,
        ),
        type: 'vertical-icon',
      ),
      PaddedButton(
        color: getButtonColorByRoute(ReceiveTransactionScreen.route),
        padding: EdgeInsets.zero,
        text: 'Receive',
        onPressed: currentRoute != ReceiveTransactionScreen.route
            ? _showReceiveDialog
            : () {},
        icon: Transform.rotate(
            angle: 90 * math.pi / 90,
            child: Icon(
              FontAwesomeIcons.locationArrow,
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
          Semantics(
              label: 'balance',
              child: Text(
                '${currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits()} ${WIT_UNIT[WitUnit.Wit]}',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              )),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Semantics(
                    label: 'Current address',
                    child: Text(
                      currentAccount.address.cropMiddle(18),
                      overflow: TextOverflow.ellipsis,
                      style: extendedTheme.monoRegularText!.copyWith(
                          color: theme.textTheme.headlineMedium!.color),
                    ))),
            Flexible(
                child: Semantics(
              label: 'Copy address to clipboard',
              child: PaddedButton(
                  padding: EdgeInsets.zero,
                  label: 'Show wallet list button',
                  text: 'Show wallet list',
                  type: 'icon-button',
                  iconSize: 12,
                  onPressed: () async {
                    if (!isAddressCopied) {
                      await Clipboard.setData(
                          ClipboardData(text: currentAccount.address));
                      if (await Clipboard.hasStrings()) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            buildCopiedSnackbar(theme, 'Address copied!'));
                        setState(() {
                          isAddressCopied = true;
                        });
                        Timer(Duration(milliseconds: 500), () {
                          setState(() {
                            isAddressCopied = false;
                          });
                        });
                      }
                    }
                  },
                  icon: Icon(
                    isAddressCopied
                        ? FontAwesomeIcons.check
                        : FontAwesomeIcons.copy,
                    size: 12,
                  )),
            )),
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
        SizedBox(height: 16),
        _buildDashboardActions(),
      ],
    );
  }

  List<Widget> _navigationActions() {
    String currentRoute = ModalRoute.of(context)!.settings.name!;
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          label: 'Settings',
          text: 'Settings',
          iconSize: 30,
          icon: Icon(FontAwesomeIcons.gear,
              size: 30, color: getButtonColorByRoute(PreferencePage.route)),
          onPressed: currentRoute != PreferencePage.route
              ? () => _goToSettings()
              : () {},
          type: 'icon-button')
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
          scrollController: widget.scrollController,
          navigationActions: _navigationActions(),
          dashboardActions: _buildDashboardHeader(),
          widgetList: [
            _body,
            if (widget.actions.length > 0)
              SizedBox(
                height: 80,
              ),
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
