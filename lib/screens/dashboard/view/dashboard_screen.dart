import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'dart:math' as math;
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets//wallet_list.dart';
import 'package:witnet_wallet/widgets/layout.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/widgets/witnet/balance_display.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/create_vtt_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/receive_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/wallet_settings/wallet_settings_dialog.dart';
import '../../login/view/login_screen.dart';
import '../../screen_transitions/fade_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../api_dashboard.dart';
import '../bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Map<String, Account> externalAccounts = {};
  Map<String, Account> internalAccounts = {};

  Wallet? walletStorage;
  late AnimationController _loadingController;
  late AnimationController _balanceController;
  List<String>? walletList;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _balanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    _balanceController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// _goToSettings
  /// [BuildContext] context
  Future<bool> _goToSettings() {
    return Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => PreferencePage(),
        ))
        .then((_) => true);
  }

  Future<void> _showWalletSettingsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WalletSettingsDialog(
          walletStorage: walletStorage!,
        );
      },
    );
  }

  Future<void> _showCreateVTTDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CreateVTTDialogBox(
          walletStorage: walletStorage!,
        );
      },
    );
  }

  Future<void> _showReceiveDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ReceiveDialogBox(
          walletStorage: walletStorage!,
        );
      },
    );
  }

  Widget _buildDashboardActions() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PaddedButton(
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
        padding: EdgeInsets.all(0),
        text: 'Home',
        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        icon: Icon(
          FontAwesomeIcons.house,
          size: 18,
        ),
        type: 'vertical-icon',
      ),
      PaddedButton(
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
            style: theme.textTheme.headline4,
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: IconButton(
                    iconSize: 12,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              '${state.currentWallet.externalAccounts[0]?.address}'));
                    },
                    icon: Icon(FontAwesomeIcons.copy))),
            Flexible(
                child: Text(
              '${state.currentWallet.externalAccounts[0]?.address}',
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

  Widget _buildDashboardGrid(ThemeData themeData, DashboardState state) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) {
        if (previous.currentWallet.id != current.currentWallet.id) {
          setState(() {
            walletStorage = current.currentWallet;
          });
        }
        return true;
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[],
        );
      },
    );
  }

  Widget buildSyncButton() {
    return BlocConsumer<ExplorerBloc, ExplorerState>(builder: (context, state) {
      final theme = Theme.of(context);

      if (state.status == ExplorerStatus.ready) {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.circle),
              onPressed: () {
                BlocProvider.of<ExplorerBloc>(context)
                    .add(SyncWalletEvent(ExplorerStatus.dataloading));
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      } else if (state.status == ExplorerStatus.dataloading) {
        return SpinKitCircle(
          color: theme.primaryColor,
        );
      } else if (state.status == ExplorerStatus.dataloaded) {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.circle),
              onPressed: () {
                BlocProvider.of<ExplorerBloc>(context)
                    .add(SyncWalletEvent(ExplorerStatus.dataloading));
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      } else {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.circle),
              onPressed: () {
                BlocProvider.of<ExplorerBloc>(context)
                    .add(SyncWalletEvent(ExplorerStatus.dataloading));
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      }
    }, listener: (context, state) {
      if (state.status == ExplorerStatus.ready) {
        ApiDashboard apiDashboard = Locator.instance.get<ApiDashboard>();
        setState(() {
          walletStorage = apiDashboard.currentWallet;
        });
      }
    });
  }

  Widget _dashboardBuilder() {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      if (state.status == DashboardStatus.Loading) {
        return _buildDashboardGrid(theme, state);
      } else if (state.status == DashboardStatus.Synchronized) {
        walletStorage = state.currentWallet;
        return _buildDashboardGrid(theme, state);
      } else if (state.status == DashboardStatus.Synchronizing) {
        return SpinKitWave(
          color: theme.primaryColor,
        );
      } else if (state.status == DashboardStatus.Ready) {
        walletStorage = state.currentWallet;
        // if (walletStorage != null) {
        //   BlocProvider.of<VTTCreateBloc>(context).setWallets(walletStorage);
        // }
        return _buildDashboardGrid(theme, state);
      } else {
        return SpinKitWave(
          color: theme.primaryColor,
        );
      }
    });
  }

  List<Widget> _navigationActions() {
    return [
      MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Icon(FontAwesomeIcons.gear, size: 30),
            onTap: () => _goToSettings(),
          )),
    ];
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    // TODO: LoggedOutState
    // TODO: LoadingLogoutState
    // TODO: LoggedInState

    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previousState, loginState) {
      if (loginState.status == LoginStatus.LoggedOut) {
        Navigator.pushReplacement(context, FadeRoute(page: LoginScreen()));
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
                    child: _dashboardBuilder(),
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
        actions: [],
        slidingPanel: _walletList,
        actionsSize: 0,
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
