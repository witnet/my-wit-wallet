import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/widgets/wallet_list.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/screens/login/view/init_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';

import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

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

  AppLocalizations get _localization => AppLocalizations.of(context)!;

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

  Future<void> _goToSettings() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.push(
        context,
        CustomPageRoute(
            builder: (BuildContext context) {
              return PreferencePage();
            },
            maintainState: false,
            settings: RouteSettings(name: PreferencePage.route)));
  }

  Future<void> _showCreateVTTDialog() async {
    Navigator.push(
        context,
        CustomPageRoute(
            builder: (BuildContext context) {
              return CreateVttScreen();
            },
            maintainState: false,
            settings: RouteSettings(name: CreateVttScreen.route)));
  }

  Future<void> _showReceiveDialog() async {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.push(
        context,
        CustomPageRoute(
            builder: (BuildContext context) {
              return ReceiveTransactionScreen();
            },
            maintainState: false,
            settings: RouteSettings(name: ReceiveTransactionScreen.route)));
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
    final theme = Theme.of(context);
    final double iconHeight = 40;
    String currentRoute = ModalRoute.of(context)!.settings.name!;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PaddedButton(
        color: getButtonColorByRoute(CreateVttScreen.route),
        padding: EdgeInsets.zero,
        text: _localization.send,
        onPressed: currentRoute != CreateVttScreen.route
            ? _showCreateVTTDialog
            : () {},
        icon: Container(
            height: 40,
            child: Icon(
              FontAwesomeIcons.locationArrow,
              size: 18,
            )),
        type: ButtonType.verticalIcon,
      ),
      PaddedButton(
        color: getButtonColorByRoute(DashboardScreen.route),
        padding: EdgeInsets.zero,
        text: _localization.history,
        onPressed: currentRoute != DashboardScreen.route
            ? () => {
                  BlocProvider.of<VTTCreateBloc>(context)
                      .add(ResetTransactionEvent()),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.push(
                      context,
                      CustomPageRoute(
                          builder: (BuildContext context) {
                            return DashboardScreen();
                          },
                          maintainState: false,
                          settings:
                              RouteSettings(name: DashboardScreen.route))),
                }
            : () {},
        icon: witnetEyeIcon(theme, height: iconHeight),
        type: ButtonType.verticalIcon,
      ),
      PaddedButton(
        color: getButtonColorByRoute(ReceiveTransactionScreen.route),
        padding: EdgeInsets.zero,
        text: _localization.receive,
        onPressed: currentRoute != ReceiveTransactionScreen.route
            ? _showReceiveDialog
            : () {},
        icon: Container(
            height: 40,
            child: Transform.rotate(
                angle: 90 * math.pi / 90,
                child: Icon(
                  FontAwesomeIcons.locationArrow,
                  size: 18,
                ))),
        type: ButtonType.verticalIcon,
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
          SizedBox(height: 8),
          Semantics(
              label: _localization.balance,
              child: Text(
                '${currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              )),
          SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Semantics(
                    label: _localization.currentAddress,
                    child: Text(
                      currentAccount.address.cropMiddle(18),
                      overflow: TextOverflow.ellipsis,
                      style: extendedTheme.monoRegularText!.copyWith(
                          color: theme.textTheme.headlineMedium!.color),
                    ))),
            Flexible(
              child: PaddedButton(
                  padding: EdgeInsets.zero,
                  label: _localization.copyAddressToClipboard,
                  text: _localization.copyAddressToClipboard,
                  type: ButtonType.iconButton,
                  iconSize: 12,
                  onPressed: () async {
                    if (!isAddressCopied) {
                      await Clipboard.setData(
                          ClipboardData(text: currentAccount.address));
                      if (await Clipboard.hasStrings()) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            buildCopiedSnackbar(
                                theme, _localization.addressCopied));
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
            ),
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
        SizedBox(height: 8),
        _buildDashboardActions(),
      ],
    );
  }

  List<Widget> _navigationActions() {
    String currentRoute = ModalRoute.of(context)!.settings.name!;
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          label: _localization.settings,
          text: _localization.settings,
          iconSize: 28,
          icon: Icon(FontAwesomeIcons.gear,
              size: 28, color: getButtonColorByRoute(PreferencePage.route)),
          onPressed: currentRoute != PreferencePage.route
              ? () => _goToSettings()
              : () {},
          type: ButtonType.iconButton)
    ];
  }

  Widget _authBuilder() {
    final theme = Theme.of(context);
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) {
        if (previous.status != LoginStatus.LoggedOut &&
            current.status == LoginStatus.LoggedOut) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  maintainState: false,
                  builder: (context) => InitScreen(),
                  settings: RouteSettings(name: InitScreen.route)));
        }
        return true;
      },
      listener: (BuildContext context, LoginState state) {},
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
