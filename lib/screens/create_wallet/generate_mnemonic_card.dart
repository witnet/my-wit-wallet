import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/dashed_rect.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';

typedef void VoidCallback(Action? value);

class Action {
  String label;
  void action;

  Action({
    required this.label,
    required this.action,
  });
}

class GenerateMnemonicCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  GenerateMnemonicCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  GenerateMnemonicCardState createState() => GenerateMnemonicCardState();
}

class GenerateMnemonicCardState extends State<GenerateMnemonicCard>
    with TickerProviderStateMixin {
  String mnemonic = '';
  String _language = 'English';
  int _radioWordCount = 12;

  Future<String> _genMnemonic() async {
    return await Locator.instance
        .get<ApiCrypto>()
        .generateMnemonic(_radioWordCount, _language);
  }

  Widget _buildInfoTextScrollBox(Size deviceSize) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Remove for production
        ElevatedButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: mnemonic));
          },
          child: Text('Copy'),
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          'These $_radioWordCount random words are your Witnet seed phrase. They will allow you to recover your tokens if you uninstall this application or forget your password:',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Please write down these $_radioWordCount words on a piece of paper and store them somewhere private and secure. You must write the complete words in the exact order they are presented to you.',
          style: theme.textTheme.headline3,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Keeping your seed phrase secret is paramount. If someone gains access to these $_radioWordCount words, they will be able to take and spend your tokens.',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Do not store these words on a computer or an electronic device. It is your sole responsibility to store the paper with your seed phrase in a safe place.',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'If you exit this setup or fail to write down or keep your seed phrase safe, we cannot help you access your wallet.',
          style: theme.textTheme.bodyText1,
        ),
      ],
    );
  }

  Widget _buildMnemonicBox(theme) {
    return FutureBuilder(
        future: _genMnemonic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              mnemonic = snapshot.data as String;
              return DashedRect(
                color: Colors.grey,
                strokeWidth: 1.0,
                gap: 3.0,
                text: mnemonic,
              );
            }
          }
          return Center(
            child: SpinKitCircle(
              color: theme.primaryColor,
            ),
          );
        });
  }

  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    Locator.instance.get<ApiCreateWallet>().setSeed(mnemonic, 'mnemonic');
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  Action prev() {
    return Action(
      label: 'Back',
      action: prevAction,
    );
  }

  Action next() {
    return Action(
      label: 'Continue',
      action: nextAction,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    return Column(children: [
      _buildMnemonicBox(theme),
      SizedBox(
        height: 16,
      ),
      _buildInfoTextScrollBox(deviceSize),
    ]);
  }
}
