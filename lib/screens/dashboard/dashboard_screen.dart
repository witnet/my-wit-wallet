import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/auth/auth_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/screens/preferences/preferences_screen.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/widgets/animated_numeric_text.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/fade_in.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/widgets/svg_widget.dart';
import 'package:witnet_wallet/widgets/vtt_list.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/transaction_history.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/create_vtt_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/receive_dialog.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/wallet_settings/wallet_settings_dialog.dart';
import '../../constants.dart';
import '../login/login_screen.dart';
import '../screen_transitions/fade_transition.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'dashboard_bloc.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Map<String, Account> externalAccounts = {};
  Map<String, Account> internalAccounts = {};
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  late AnimationController _loadingController;
  late AnimationController _headerController;
  late Animation<double> _headerScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerScaleAnimation =
        Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
      parent: _loadingController,
      curve: headerAniInterval,
    ));

    //BlocProvider.of<BlocDashboard>(context).add(DashboardInitEvent(externalAccounts: {}, internalAccounts: {}));
  }

  Future<bool> _goToSettings(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => PreferencePage(),
        ))
        .then((_) => true);
  }

  AppBar _buildAppBar(ThemeData theme) {
    final menuBtn = IconButton(
      color: theme.accentColor,
      icon: const Icon(FontAwesomeIcons.bars),
      onPressed: () => _goToSettings(context),
    );

    final logoutButton = IconButton(
      icon: const Icon(FontAwesomeIcons.userLock),
      color: theme.accentColor,
      onPressed: () {
        BlocProvider.of<BlocDashboard>(context).add(DashboardResetEvent());
        BlocProvider.of<BlocAuth>(context).add(LogoutEvent());
      },
    );

    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Hero(
              tag: Constants.logoTag,
              child: SVGWidget(
                size: 30,
                title: '',
                img: 'favicon',
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );

    return AppBar(
      leading: FadeIn(
        controller: _loadingController,
        offset: .3,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.startToEnd,
        duration: Duration(milliseconds: 300),
        child: menuBtn,
      ),
      actions: <Widget>[
        FadeIn(
          controller: _loadingController,
          offset: .3,
          curve: headerAniInterval,
          fadeDirection: FadeDirection.endToStart,
          duration: Duration(milliseconds: 300),
          child: logoutButton,
        ),
      ],
      title: title,
      backgroundColor: theme.primaryColor.withOpacity(.1),
      elevation: 0,
      textTheme: theme.accentTextTheme,
      iconTheme: theme.accentIconTheme,
    );
  }

  Widget _buildHeader(
    ThemeData theme,
  ) {
    int balance = 0;
    externalAccounts.forEach((key, value) {
      print(value.jsonMap());
      balance += value.balance;
    });
    internalAccounts.forEach((key, value) {
      balance += value.balance;
    });

    print(balance);
    final primaryColor = theme.primaryColor;
    final accentColor = theme.accentColor;
    final bgMat = createMaterialColor(accentColor);
    final linearGradient = LinearGradient(colors: [
      bgMat.shade700,
      bgMat.shade600,
      bgMat.shade500,
      bgMat.shade400,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 418.0, 78.0));

    return ScaleTransition(
      scale: _headerScaleAnimation,
      child: FadeIn(
        controller: _headerController,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.bottomToTop,
        offset: .5,
        duration: Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedNumericText(
                  initialValue: 0,
                  targetValue: nanoWitToWit(balance),
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
        ),
      ),
    );
  }

  Future<void> _showWalletSettingsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WalletSettingsDialog(
          internalAccounts: internalAccounts,
          externalAccounts: externalAccounts,
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
          internalAccounts: internalAccounts,
          externalAccounts: externalAccounts,
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
          internalAccounts: internalAccounts,
          externalAccounts: externalAccounts,
        );
      },
    );
  }

  Widget _buildDashboardGrid(ThemeData themeData, DashboardState state) {
    final size = MediaQuery.of(context).size;
    switch (state.runtimeType) {
      case DashboardReadyState:
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(themeData),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundButton(
                    size: 40,
                    icon: Icon(FontAwesomeIcons.arrowUp),
                    onPressed: _showCreateVTTDialog,
                    label: 'Send',
                    loadingController: _loadingController,
                  ),
                  RoundButton(
                    size: 40,
                    icon: Icon(FontAwesomeIcons.arrowDown),
                    onPressed: _showReceiveDialog,
                    label: 'Receive',
                    loadingController: _loadingController,
                  ),
                  RoundButton(
                    size: 40,
                    icon: Icon(FontAwesomeIcons.userCog),
                    onPressed: _showWalletSettingsDialog,
                    label: 'Settings',
                    loadingController: _loadingController,
                  ),
                  buildSyncButton(),
                ],
              ),
            ),
            // TransactionHistory(themeData: themeData, externalAccounts: externalAccounts, internalAccounts: internalAccounts,),
          ],
        );
      default:
        return Container(
          child: SizedBox(
            height: 5,
          ),
        );
    }
  }

  Widget buildSyncButton() {
    return BlocBuilder<BlocExplorer, ExplorerState>(builder: (context, state) {
      final theme = Theme.of(context);
      if (state is ReadyState) {
        return Column(
          children: <Widget>[
            RoundButton(
              size: 40,
              icon: Icon(FontAwesomeIcons.sync),
              onPressed: () {
                BlocProvider.of<BlocExplorer>(context).add(SyncWalletEvent());
              },
              label: 'Sync',
              loadingController: _loadingController,
            ),
          ],
        );
      } else if (state is DataLoadingState) {
        return SpinKitCircle(
          color: theme.primaryColor,
        );
      } else if (state is DataLoadedState) {
        return Column(
          children: [
            Text('default'),
          ],
        );
      } else {
        return Column(
          children: [
            Text('default'),
          ],
        );
      }
    });
  }

  _dashboardBuilder() {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return BlocBuilder<BlocDashboard, DashboardState>(
        builder: (BuildContext context, DashboardState dashboardState) {
      switch (dashboardState.runtimeType) {
        case DashboardLoadingState:
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[]);
        case DashboardSynchronizedState:
        case DashboardSynchronizingState:
        case DashboardReadyState:
          return _buildDashboardGrid(theme, dashboardState);
        default:
          return SizedBox(
            child: SpinKitWave(
              color: theme.primaryColor,
            ),
          );
      }
    });
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    final bgMat = createMaterialColor(theme.cardColor);
    return BlocBuilder<BlocAuth, AuthState>(
        buildWhen: (previousState, authState) {
      if (authState is LoggedOutState) {
        Navigator.pushReplacement(context, FadeRoute(page: LoginScreen()));
      }
      return true;
    }, builder: (BuildContext context, AuthState authState) {
      switch (authState.runtimeType) {
        case LoadingLogoutState:
          return Scaffold(
            appBar: _buildAppBar(theme),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: theme.primaryColor.withOpacity(.1),
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        child: SpinKitWave(
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        case LoggedInState:
          authState as LoggedInState;

          externalAccounts = authState.externalAccounts;
          internalAccounts = authState.internalAccounts;

          return Scaffold(
            appBar: _buildAppBar(theme),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: theme.primaryColor.withOpacity(.1),
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: _dashboardBuilder(),
                        //_buildDashboardGrid(theme, authState),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        default:
          return Scaffold(
            appBar: _buildAppBar(theme),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: theme.primaryColor.withOpacity(.1),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
      }
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
