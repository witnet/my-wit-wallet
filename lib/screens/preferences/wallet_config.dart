import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';
import 'package:my_wit_wallet/widgets/generate_compatible_xprv.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/verify_password.dart';

class WalletConfig extends StatefulWidget {
  final ScrollController scrollController;

  WalletConfig({
    Key? key,
    required this.scrollController,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => WalletConfigState();
}

enum ConfigSteps {
  General,
  Wallet,
}

class WalletConfigState extends State<WalletConfig> {
  String? xprv;
  String? newXprv;
  bool showXprv = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _exportWalletContent(BuildContext context) {
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
      SizedBox(height: 16),
      PaddedButton(
        text: 'Copy Xprv',
        type: ButtonType.primary,
        isLoading: isLoading,
        padding: EdgeInsets.only(bottom: 8),
        onPressed: () async {
          Clipboard.setData(ClipboardData(text: newXprv ?? ''));
          await Clipboard.setData(ClipboardData(text: newXprv ?? ''));
          if (await Clipboard.hasStrings()) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context)
                .showSnackBar(buildCopiedSnackbar(theme, 'Xprv copied!'));
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
        return Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Export the Xprv key of my wallet',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              Text(
                  'Your Xprv key allows you to export and back up your wallet at any point after creating it.',
                  style: theme.textTheme.bodyLarge),
              SizedBox(height: 8),
              Text(
                  'Privacy-wise, your Xprv key is equivalent to a secret recovery phrase. Do not share it with anyone, and never store it in a file in your device or anywhere else electronically.',
                  style: theme.textTheme.bodyLarge),
              SizedBox(height: 8),
              Text(
                  'Your Xprv key will be protected with the password below. When importing the Xprv on this or another app, you will be asked to type in that same password.',
                  style: theme.textTheme.bodyLarge),
              SizedBox(height: 16),
              _exportWalletContent(context),
            ]));
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
