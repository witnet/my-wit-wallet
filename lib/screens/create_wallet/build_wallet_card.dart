import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/auth/auth_bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/dashboard_screen.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/widgets/animated_numeric_text.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/fade_in.dart';
import 'package:witnet_wallet/widgets/svg_widget.dart';
import '../../constants.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

class BuildWalletCard extends StatefulWidget {
  BuildWalletCard({Key? key}) : super(key: key);
  BuildWalletCardState createState() => BuildWalletCardState();
}

class BuildWalletCardState extends State<BuildWalletCard>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _balanceController;
  late AnimationController _transactionCountController;
  late AnimationController _addressCountController;
  int balance = 0;
  int currentAddressCount = 0;
  int currentTransactionCount = 0;
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  void onBack() {
    WalletType type = BlocProvider.of<BlocCreateWallet>(context).state.type;
    BlocProvider.of<BlocCreateWallet>(context).add(PreviousCardEvent(type));
  }

  void onNext() {
    WalletType type = BlocProvider.of<BlocCreateWallet>(context).state.type;
    BlocProvider.of<BlocCreateWallet>(context).add(NextCardEvent(type));
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
    ApiCreateWallet acw = Locator.instance<ApiCreateWallet>();
    // acw.printDebug();

    //BlocProvider.of<BlocCrypto>(context).add(CryptoInitializeWalletEvent(
    //    walletDescription: acw.walletDescription!,
    //    walletName: acw.walletName,
    //    keyData: acw.seedData,
    //    seedSource: acw.seedSource,
    //    password: acw.password!));
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
    _balanceController.dispose();
  }

  AppBar _buildAppBar(ThemeData theme) {
    final menuBtn = IconButton(
      color: theme.accentColor,
      icon: const Icon(FontAwesomeIcons.bars),
      onPressed: null,
    );

    final logoutButton = IconButton(
      icon: const Icon(FontAwesomeIcons.userLock),
      color: theme.accentColor,
      onPressed: null,
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
      backgroundColor: theme.cardColor,
      elevation: 0,
      textTheme: theme.accentTextTheme,
      iconTheme: theme.accentIconTheme,
    );
  }

  Widget initStatus(
      {required ThemeData theme,
      required int addressCount,
      required int startingBalance,
      required int balanceNanoWit,
      required int transactionCount,
      required String message}) {
    final accentColor = theme.accentColor;
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
            child: AutoSizeText('Transactions: ${transactionCount}',
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
            child: AutoSizeText('Current Address: ${message}',
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
    return BlocBuilder<BlocCrypto, CryptoState>(
      buildWhen: (previousState, state) {
        print(previousState);
        print(state);
        if (previousState is CryptoLoadedWalletState) {
          BlocProvider.of<BlocCreateWallet>(context)
              .add(ResetEvent(WalletType.newWallet));
        }
        if (state is CryptoLoadedWalletState) {
          BlocProvider.of<BlocAuth>(context)
              .add(LoginEvent(password: state.password));
          //
          //BlocProvider.of<BlocImportMnemonic>(context).add(NextCardEvent());
          Locator.instance<ApiCreateWallet>().clearFormData();
        } else if (state is CryptoInitializingWalletState) {
          _balanceController.reset();
          _balanceController.forward();
          if (previousState is CryptoInitializingWalletState) {
            setState(() {
              balance = previousState.balanceNanoWit;
              currentAddressCount = previousState.addressCount;
              currentTransactionCount = previousState.transactionCount;
            });
          }
        }
        return true;
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        print(state.runtimeType);
        if (state is CryptoInitializingWalletState) {
          return Column(
            children: [
              initStatus(
                  theme: theme,
                  addressCount: state.addressCount,
                  startingBalance: balance,
                  balanceNanoWit: state.balanceNanoWit,
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
          BlocProvider.of<BlocCrypto>(context).add(CryptoInitializeWalletEvent(
              walletDescription: acw.walletDescription!,
              walletName: acw.walletName,
              keyData: acw.seedData!,
              seedSource: acw.seedSource!,
              password: acw.password!));
          acw.printDebug();
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
    final accentColor = theme.accentColor;
    final bgMat = createMaterialColor(accentColor);
    final linearGradient = LinearGradient(colors: [
      bgMat.shade700,
      bgMat.shade600,
      bgMat.shade500,
      bgMat.shade400,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 100.0, 78.0));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      AnimatedNumericText(
        initialValue: 0,
        targetValue: nanoWitToWit(0),
        curve: Interval(0, .5, curve: Curves.easeOut),
        controller: _loadingController,
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
    ]);
  }

  Widget _formLogin() {
    return BlocBuilder<BlocAuth, AuthState>(buildWhen: (previousState, state) {
      if (state is LoggedInState) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
        BlocProvider.of<BlocDashboard>(context).add(DashboardLoadEvent(
            externalAccounts: state.externalAccounts,
            internalAccounts: state.internalAccounts));
      }
      return true;
    }, builder: (context, state) {
      return Container();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final cardWidth = min(deviceSize.width * 0.95, 360.0);
    const cardPadding = 10.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
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
              _formLogin(),
              SizedBox(height: 10),
            ],
          ),
        )
      ],
    );
  }
}
