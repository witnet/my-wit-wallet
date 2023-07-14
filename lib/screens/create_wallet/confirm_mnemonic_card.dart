import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/crypto.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

typedef void VoidCallback(NavAction? value);
typedef void BoolCallback(bool value);

class ConfirmMnemonicCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  final Function clearActions;
  ConfirmMnemonicCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
    required BoolCallback this.clearActions,
  }) : super(key: key);

  ConfirmMnemonicCardState createState() => ConfirmMnemonicCardState();
}

class ConfirmMnemonicCardState extends State<ConfirmMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  String? _secretRecoveryPhraseErrorText;
  final TextEditingController textController = TextEditingController();
  int numLines = 0;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.clearActions(false));
    super.initState();
  }

  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    if (validMnemonic(mnemonic)) {
      WalletType type =
          BlocProvider.of<CreateWalletBloc>(context).state.walletType;
      BlocProvider.of<CreateWalletBloc>(context)
          .add(NextCardEvent(type, data: {}));
    } else {
      setState(() {
        _secretRecoveryPhraseErrorText = 'Invalid secret recovery phrase';
      });
    }
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

  bool validMnemonic(String mnemonic) {
    assert(Locator.instance.get<ApiCreateWallet>().seedSource == 'mnemonic');
    String _mn = Locator.instance.get<ApiCreateWallet>().seedData!;
    if (mnemonic != _mn) return false;
    return validateMnemonic(mnemonic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Secret Recovery Phrase Confirmation',
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          'Type in your secret recovery phrase below exactly as shown before. This will ensure that you have written down your secret recovery phrase correctly.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          style: extendedTheme.monoLargeText,
          decoration: InputDecoration(
            errorText: _secretRecoveryPhraseErrorText,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.go,
          maxLines: 3,
          controller: textController,
          onSubmitted: (value) => {
            if (validMnemonic(textController.value.text)) {nextAction()}
          },
          onChanged: (String e) {
            if (validMnemonic(textController.value.text)) {
              setState(() {
                _secretRecoveryPhraseErrorText = null;
              });
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
