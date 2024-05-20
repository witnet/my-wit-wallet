import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/util/current_route.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/widgets/identicon.dart';
import 'package:my_wit_wallet/widgets/send_receive.dart';
import 'package:my_wit_wallet/widgets/wallet_list.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/screens/login/view/init_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';

import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/wallet_type_label.dart';

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
  Panel panel = Panel();
  Widget get _panelContent => panel.getContent();
  Wallet get currentWallet =>
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;

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

  String? currentScreen() => currentRoute(context);

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

  Color? getButtonColorByRoute(route) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return currentScreen == route
        ? extendedTheme.bottomDashboardActiveButton
        : extendedTheme.inputIconColor;
  }

  bool isActiveRoute(route) {
    return currentScreen == route;
  }

  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
    final double mainIconHeight = 40;
    final double iconHeight = 20;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PaddedButton(
        color: getButtonColorByRoute(DashboardScreen.route),
        padding: EdgeInsets.zero,
        text: localization.history,
        onPressed: currentScreen != DashboardScreen.route
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
        icon: witnetEyeIcon(theme, height: mainIconHeight),
        type: ButtonType.iconButton,
      ),
      SizedBox(width: 16),
      PaddedButton(
        color: getButtonColorByRoute(CreateVttScreen.route),
        padding: EdgeInsets.zero,
        text: localization.history,
        onPressed: () => {
          setState(() {
            panel.toggle(SendReceiveButtons());
          })
        },
        icon: isActiveRoute(CreateVttScreen.route)
            ? svgThemeImage(theme,
                name: 'send-receive-active', height: iconHeight)
            : svgThemeImage(theme, name: 'send-receive', height: iconHeight),
        type: ButtonType.iconButton,
      ),
      SizedBox(width: 16),
      PaddedButton(
        color: getButtonColorByRoute(CreateVttScreen.route),
        padding: EdgeInsets.zero,
        text: localization.history,
        onPressed: currentScreen != CreateVttScreen.route
            ? () => {
                  BlocProvider.of<VTTCreateBloc>(context)
                      .add(ResetTransactionEvent()),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.push(
                      context,
                      CustomPageRoute(
                          builder: (BuildContext context) {
                            return CreateVttScreen();
                          },
                          maintainState: false,
                          settings:
                              RouteSettings(name: CreateVttScreen.route))),
                }
            : () {},
        // TODO: add current stake route
        icon: isActiveRoute(CreateVttScreen.route)
            ? svgThemeImage(theme, name: 'stake-active', height: iconHeight)
            : svgThemeImage(theme, name: 'stake', height: iconHeight),
        type: ButtonType.iconButton,
      ),
    ]);
  }

  Widget _buildBalanceDisplay() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      Account currentAccount =
          Locator.instance.get<ApiDatabase>().walletStorage.currentAccount;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
              label: localization.balance,
              child: Text(
                '${currentWallet.balanceNanoWit().availableNanoWit.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              )),
          SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Semantics(
                    label: localization.currentAddress,
                    child: Text(
                      currentAccount.address.cropMiddle(18),
                      overflow: TextOverflow.ellipsis,
                      style: extendedTheme.monoRegularText!.copyWith(
                          color: theme.textTheme.headlineMedium!.color),
                    ))),
            Flexible(
              child: PaddedButton(
                  padding: EdgeInsets.zero,
                  label: localization.copyAddressToClipboard,
                  text: localization.copyAddressToClipboard,
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
                                theme, localization.addressCopied));
                        setState(() {
                          isAddressCopied = true;
                        });
                        if (this.mounted) {
                          Timer(Duration(milliseconds: 500), () {
                            setState(() {
                              isAddressCopied = false;
                            });
                          });
                        }
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
      ],
    );
  }

  List<Widget> _topNavigationActions() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    String walletId = currentWallet.id;
    return [
      PaddedButton(
          padding: EdgeInsets.zero,
          label: '${localization.showWalletList} button',
          text: localization.showWalletList,
          type: ButtonType.iconButton,
          iconSize: 30,
          icon: Container(
            color: WitnetPallet.white,
            width: 28,
            height: 28,
            child: Identicon(seed: walletId, size: 8),
          ),
          onPressed: () => {
                setState(() {
                  panel.toggle(WalletList());
                })
              }),
      Expanded(
          child: Padding(
              padding: EdgeInsets.only(left: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: extendedTheme.tooltipBgColor,
                      ),
                      height: 50,
                      richMessage: TextSpan(
                        text: currentWallet.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                      child: Text(currentWallet.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: extendedTheme.headerTextColor,
                              fontSize: 16))),
                  SizedBox(
                      height: currentWallet.walletType == WalletType.single
                          ? 8
                          : 0),
                  WalletTypeLabel(label: currentWallet.walletType),
                ],
              ))),
      PaddedButton(
          padding: EdgeInsets.zero,
          label: localization.settings,
          text: localization.settings,
          iconSize: 28,
          icon: Icon(FontAwesomeIcons.gear,
              size: 28, color: getButtonColorByRoute(PreferencePage.route)),
          onPressed: currentScreen != PreferencePage.route
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
        print('¿¿¿¿¿¿¿¿¿ Panel content type ${_panelContent.runtimeType}');
        return Layout(
          scrollController: widget.scrollController,
          topNavigation: _topNavigationActions(),
          dashboardActions: _buildDashboardHeader(),
          bottomNavigation: _buildBottomNavigation(),
          widgetList: [
            _body,
            if (widget.actions.length > 0)
              SizedBox(
                height: 80,
              ),
          ],
          actions: [],
          slidingPanel: _panelContent,
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
