import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';
import 'package:my_wit_wallet/widgets/generate_compatible_xprv.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/verify_password.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

typedef void VoidCallback();

class ExportXprv extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback closeSetting;

  ExportXprv({
    Key? key,
    required this.scrollController,
    required this.closeSetting,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => ExportXprvState();
}

class ExportXprvState extends State<ExportXprv> {
  String? xprv;
  String? newXprv;
  bool showXprv = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _exportWalletContent(BuildContext context) {
    globals.biometricsAuthInProgress = false;
    final theme = Theme.of(context);
    Wallet currentWallet =
        Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
    bool isSingleAddressWallet = currentWallet.walletType == WalletType.single;
    String? singleAddressXprv = currentWallet.xprv;
    if (isSingleAddressWallet) {
      newXprv = singleAddressXprv;
    }
    Widget verifyPassword = VerifyPassword(
        onXprvGenerated: (generatedXprv) => {
              widget.scrollController.jumpTo(0.0),
              setState(() => xprv = generatedXprv)
            });
    Widget encryptXprv = GenerateCompatibleXprv(
        xprv: xprv,
        onXprvGenerated: (generatedXprv) => {
              widget.scrollController.jumpTo(0.0),
              setState(() => newXprv = generatedXprv)
            });
    Widget xprvOutput = Column(children: [
      DashedRect(
          color: Colors.grey,
          strokeWidth: 1.0,
          gap: 3.0,
          showEye: true,
          blur: !showXprv,
          text: newXprv ?? '',
          updateBlur: () => {
                setState(() {
                  showXprv = !showXprv;
                })
              }),
      SizedBox(height: 32),
      PaddedButton(
        text: localization.copyXprvLabel,
        type: ButtonType.primary,
        isLoading: isLoading,
        padding: EdgeInsets.only(bottom: 8),
        onPressed: () async {
          Clipboard.setData(ClipboardData(text: newXprv ?? ''));
          await Clipboard.setData(ClipboardData(text: newXprv ?? ''));
          if (await Clipboard.hasStrings()) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
                buildCopiedSnackbar(theme, localization.copyXprvConfirmed));
          }
        },
      ),
    ]);
    if (newXprv != null) {
      return xprvOutput;
    } else if (xprv == null) {
      return verifyPassword;
    } else {
      return encryptXprv;
    }
  }

  void _clearGeneratedXprv() {
    setState(() {
      newXprv = null;
      showXprv = false;
      xprv = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (previous, current) {
        return ClosableView(closeSetting: widget.closeSetting, children: [
          SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              localization.walletConfigHeader,
              style: theme.textTheme.titleLarge,
            ),
          ),
          SizedBox(height: 16),
          Text(localization.walletConfig01, style: theme.textTheme.bodyLarge),
          SizedBox(height: 8),
          Text(localization.walletConfig02, style: theme.textTheme.bodyLarge),
          SizedBox(height: 8),
          Text(localization.walletConfig03, style: theme.textTheme.bodyLarge),
          SizedBox(height: 16),
          _exportWalletContent(context),
        ]);
      },
      buildWhen: (previous, current) {
        if (previous.currentWalletId != current.currentWalletId) {
          _clearGeneratedXprv();
          return true;
        } else {
          return false;
        }
      },
    );
  }
}
