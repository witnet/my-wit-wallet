import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';

final _passController = TextEditingController();
final _textController = TextEditingController();
final _textFocusNode = FocusNode();
final _passFocusNode = FocusNode();

typedef void VoidCallback(NavAction? value);
typedef void BoolCallback(bool value);

class EnterEncryptedXprvCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  final Function clearActions;
  EnterEncryptedXprvCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
    required BoolCallback this.clearActions,
  }) : super(key: key);

  EnterXprvCardState createState() => EnterXprvCardState();
}

class EnterXprvCardState extends State<EnterEncryptedXprvCard>
    with TickerProviderStateMixin {
  String xprv = '';
  String _password = '';
  String? decryptedLocalXprv;
  bool isValidPassword = false;
  bool isXprvValid = false;
  bool useStrongPassword = false;
  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  int numLines = 0;
  bool _xprvVerified = false;
  bool xprvVerified() => _xprvVerified;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _textController.clear();
    _passFocusNode.addListener(() => validate());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.clearActions(false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildConfirmField() {
    final theme = Theme.of(context);
    return TextField(
      keyboardType: TextInputType.multiline,
      focusNode: _textFocusNode,
      style: theme.textTheme.displayMedium,
      maxLines: 4,
      controller: _textController,
      onChanged: (String e) {
        setState(() {
          xprv = _textController.value.text;
          numLines = '\n'.allMatches(e).length + 1;
        });
      },
    );
  }

  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() async {
    await validateXprv(xprv, _password);
    if (validate(force: true)) {
      Locator.instance<ApiCreateWallet>().setSeed(decryptedLocalXprv!, 'xprv');
      WalletType type =
          BlocProvider.of<CreateWalletBloc>(context).state.walletType;
      BlocProvider.of<CreateWalletBloc>(context)
          .add(NextCardEvent(type, data: {}));
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

  Future validateXprv(String xprvString, String password) async {
    ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
    String? xprvDecripted;
    try {
      String hashPassword = await apiCrypto.hashPassword(password: password);
      // Create localXprv
      String sheikahCompatibleXprvDecripted =
          await apiCrypto.decryptXprv(xprv: xprvString, password: hashPassword);
      String localXprv = await apiCrypto.encryptXprv(
          xprv: sheikahCompatibleXprvDecripted, password: password);
      // Decript localXprv
      xprvDecripted =
          await apiCrypto.decryptXprv(xprv: localXprv, password: hashPassword);
      setState(() => {decryptedLocalXprv = xprvDecripted, isXprvValid = true});
    } catch (e) {
      setState(() => isXprvValid = false);
    }
  }

  bool validate({force = false}) {
    if (this.mounted) {
      if (force || (!_passFocusNode.hasFocus && !_textFocusNode.hasFocus)) {
        setState(() {
          errorText = null;
        });
        if (_password.isEmpty) {
          setState(() {
            errorText = 'Please input a password';
          });
        } else if (!isXprvValid) {
          setState(() {
            errorText = 'Invalid xprv or password';
          });
        }
      }
    }
    return errorText != null ? false : true;
  }

  Widget _buildPasswordField() {
    return InputLogin(
      hint: 'Password',
      focusNode: _passFocusNode,
      textEditingController: _passController,
      obscureText: true,
      errorText: errorText,
      onChanged: (String? value) {
        if (this.mounted) {
          setState(() {
            _password = value!;
          });
        }
      },
    );
  }

  String truncateAddress(String addr) {
    var start = addr.substring(0, 11);
    var end = addr.substring(addr.length - 6);
    return '$start...$end';
  }

  Widget buildErrorList(List<dynamic> errors) {
    List<Widget> _children = [];
    errors.forEach((element) {
      _children.add(Text(
        element.toString(),
        style: TextStyle(color: Colors.red),
      ));
    });
    return Column(children: _children);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recover with xprv',
            style: theme.textTheme.displaySmall, //Textstyle
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'Please paste your xprv used for recovery and type the password created for exporting the file.',
            style: theme.textTheme.bodyLarge, //Textstyle
          ),
          SizedBox(
            height: 16,
          ),
          _buildConfirmField(),
          SizedBox(
            height: 16,
          ),
          _buildPasswordField(),
          SizedBox(
            height: 16,
          ),
        ]);
  }
}
