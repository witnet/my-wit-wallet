import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:witnet/crypto.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

typedef void VoidCallback(NavAction? value);

class ConfirmMnemonicCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  ConfirmMnemonicCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);

  ConfirmMnemonicCardState createState() => ConfirmMnemonicCardState();
}

class ConfirmMnemonicCardState extends State<ConfirmMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  final TextEditingController textController = TextEditingController();
  int numLines = 0;
  AppLocalizations get _localization => AppLocalizations.of(context)!;

  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: _localization.backLabel,
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: _localization.continueLabel,
      action: nextAction,
    );
  }

  bool validMnemonic(String mnemonic) {
    assert(Locator.instance.get<ApiCreateWallet>().seedSource == 'mnemonic');
    String _mn = Locator.instance.get<ApiCreateWallet>().seedData!;
    if (mnemonic != _mn) return false;
    return validateMnemonic(mnemonic);
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _localization.confirmMnemonicHeader,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          _localization.confirmMnemonic01,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          style: extendedTheme.monoLargeText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.go,
          maxLines: 3,
          controller: textController,
          onSubmitted: (value) => {
            if (validMnemonic(textController.value.text)) {nextAction()}
          },
          onChanged: (String e) {
            if (validMnemonic(textController.value.text)) {
              widget.nextAction(next);
            } else {
              widget.nextAction(null);
            }
            setState(() {
              mnemonic = textController.value.text;
              numLines = '\n'.allMatches(e).length + 1;
            });
          },
        ),
      ],
    );
  }
}
