import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:witnet_wallet/screens/login/bloc/login_bloc.dart';
import 'package:witnet_wallet/screens/login/models/models.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/widgets/animated_numeric_text.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/fade_in.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

typedef void VoidCallback(NavAction? value);


class BuildWalletCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  BuildWalletCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  BuildWalletCardState createState() => BuildWalletCardState();
}

class BuildWalletCardState extends State<BuildWalletCard>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _balanceController;
  int balance = 0;
  int currentAddressCount = 0;
  int currentTransactionCount = 0;
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: 'Back',
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
      action: nextAction,
    );
  }

  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _balanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _nameController = TextEditingController();
    _descController = TextEditingController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    acw.printDebug();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _balanceController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  AppBar _buildAppBar(ThemeData theme) {
    final menuBtn = IconButton(
      color: theme.primaryColor,
      icon: const Icon(FontAwesomeIcons.bars),
      onPressed: null,
    );

    final logoutButton = IconButton(
      icon: const Icon(FontAwesomeIcons.userLock),
      color: theme.primaryColor,
      onPressed: null,
    );

    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

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
      backgroundColor: theme.cardColor,
      elevation: 0,
      iconTheme: theme.iconTheme,
    );
  }

  Widget initStatus(
      {required ThemeData theme,
      required int addressCount,
      required int startingBalance,
      required int balanceNanoWit,
      required int transactionCount,
      required String message}) {
    final accentColor = theme.primaryColor;
    final bgMat = createMaterialColor(accentColor);
    final linearGradient = LinearGradient(colors: [
      bgMat.shade700,
      bgMat.shade600,
      bgMat.shade500,
      bgMat.shade400,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 78.0));
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        AnimatedNumericText(
          initialValue: nanoWitToWit(balance),
          targetValue: nanoWitToWit(balanceNanoWit),
          curve: Interval(0, .5, curve: Curves.easeOut),
          controller: _balanceController,
          style: theme.textTheme.bodyText1!,
        ),
        SizedBox(width: 5),
        Text(
          'wit',
          style: theme.textTheme.bodyText1!,
        ),
      ]),
      SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  AutoSizeText('Total addresses:  ',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 9,
                      style: theme.textTheme.bodyText1!.copyWith(
                        foreground: Paint()..shader = linearGradient,
                      )),
                  AnimatedIntegerText(
                    initialValue: currentAddressCount,
                    targetValue: addressCount,
                    curve: Interval(0, .5, curve: Curves.easeOut),
                    controller: _balanceController,
                    style: theme.textTheme.bodyText1!.copyWith(
                      foreground: Paint()..shader = linearGradient,
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 1,
            child: AutoSizeText('Transactions: $transactionCount',
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 9,
                style: theme.textTheme.bodyText1!.copyWith(
                  foreground: Paint()..shader = linearGradient,
                )),
          )
        ],
      ),
      SizedBox(
        height: 20,
      ),
      Row(
        children: [
          Expanded(
            flex: 1,
            child: AutoSizeText('Current Address: $message',
                maxLines: 2,
                minFontSize: 14,
                style: theme.textTheme.bodyText1!.copyWith(
                  foreground: Paint()..shader = linearGradient,
                )),
          ),
        ],
      ),
      SizedBox(
        height: 40,
      ),
    ]);
  }

  Widget buildWallet() {
    return BlocBuilder<CryptoBloc, CryptoState>(
      buildWhen: (previousState, state) {
        if (previousState is CryptoLoadedWalletState) {
          BlocProvider.of<CreateWalletBloc>(context)
              .add(ResetEvent(WalletType.newWallet));
        }
        if (state is CryptoLoadedWalletState) {
          Locator.instance<ApiCreateWallet>().clearFormData();

          BlocProvider.of<LoginBloc>(context).add(LoginSubmittedEvent(
              walletName: WalletName.dirty(state.wallet.name),
              password: state.password));
        } else if (state is CryptoInitializingWalletState) {
          _balanceController.reset();
          _balanceController.forward();
          if (state.props[0].runtimeType == Wallet) {

          }
          if (previousState is CryptoInitializingWalletState) {
            setState(() {
              balance = previousState.availableNanoWit;
              currentAddressCount = previousState.addressCount;
              currentTransactionCount = previousState.transactionCount;
            });
          }
        }
        return true;
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        if (state is CryptoInitializingWalletState) {
          return Column(
            children: [
              initStatus(
                  theme: theme,
                  addressCount: state.addressCount,
                  startingBalance: balance,
                  balanceNanoWit: state.availableNanoWit,
                  transactionCount: state.transactionCount,
                  message: state.message),
              SizedBox(
                child: SpinKitWave(
                  color: theme.primaryColor,
                ),
              ),
            ],
          );

          //initStatus(theme, 0, state.addressCount, state.balanceNanoWit, state.transactionCount, state.message);
        }
        if (state is CryptoLoadedWalletState) {
          return Column(children: [
            SizedBox(
              child: SpinKitWave(
                color: theme.primaryColor,
              ),
            ),
            AutoSizeText(
              '',
              maxLines: 1,
              minFontSize: 9,
            ),
          ]);
        } else if (state is CryptoReadyState) {
          ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
          BlocProvider.of<CryptoBloc>(context).add(CryptoInitializeWalletEvent(
              walletDescription: acw.walletDescription!,
              walletName: acw.walletName,
              keyData: acw.seedData!,
              seedSource: acw.seedSource!,
              password: acw.password!));

          return Column(
            children: [
              SizedBox(
                child: SpinKitWave(
                  color: theme.primaryColor,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              SpinKitCircle(
                color: theme.primaryColor,
              ),
            ],
          );
        }
      },
    );
  }

  Widget buildBalance(ThemeData theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      AnimatedNumericText(
        initialValue: 0,
        targetValue: nanoWitToWit(0),
        curve: Interval(0, .5, curve: Curves.easeOut),
        controller: _loadingController,
        style: theme.textTheme.bodyText1!,
      ),
      SizedBox(width: 5),
      Text(
        'wit',
        style: theme.textTheme.bodyText1!,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final cardWidth = min(deviceSize.width * 0.95, 360.0);
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildAppBar(theme),
        Container(
          width: cardWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //buildBalance(theme),
              SizedBox(height: deviceSize.height / 4),
              buildWallet(),
              SizedBox(height: 10),
            ],
          ),
        )
      ],
    );
  }
}
