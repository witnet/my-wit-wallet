import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io' show Platform;

final _passController = TextEditingController();
final _textController = TextEditingController();
final _textFocusNode = FocusNode();
final _passFocusNode = FocusNode();
final _showPasswordFocusNode = FocusNode();
final _scanQrFocusNode = FocusNode();

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
  int numLines = 0;
  bool _xprvVerified = false;
  bool xprvVerified() => _xprvVerified;
  String? errorText;
  String? _errorXprvText;
  bool isScanQrFocused = false;

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _textController.clear();
    _passFocusNode.addListener(() => validate());
    _scanQrFocusNode.addListener(_handleFocus);
    _textFocusNode.requestFocus();
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

  _handleFocus() {
    setState(() {
      isScanQrFocused = _scanQrFocusNode.hasFocus;
    });
  }

  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  String? _validateXprv(String? input) {
    String? errorText;

    const xprvLen = 293;

    if (input == null || input.length != xprvLen) {
      errorText = "Invalid xprv";
    }

    return errorText;
  }

  Widget _buildConfirmField() {
    final theme = Theme.of(context);
    return TextField(
      decoration: InputDecoration(
        hintText: 'Your Xprv key (starts with xprv...)',
        suffixIcon: !Platform.isWindows && !Platform.isLinux
            ? Semantics(
                label: 'Scan QR code',
                child: IconButton(
                  splashRadius: 1,
                  focusNode: _scanQrFocusNode,
                  color: isScanQrFocused
                      ? theme.textSelectionTheme.cursorColor
                      : theme
                          .inputDecorationTheme.enabledBorder?.borderSide.color,
                  icon: Icon(FontAwesomeIcons.qrcode),
                  onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QrScanner(
                                onChanged: (String value) => {
                                      Navigator.popUntil(
                                          context,
                                          ModalRoute.withName(
                                              CreateWalletScreen.route)),
                                      _textController.text = value,
                                      xprv = value,
                                      setState(() {
                                        _errorXprvText = _validateXprv(xprv);
                                      })
                                    })))
                  },
                ))
            : null,
        errorText: _errorXprvText,
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.go,
      focusNode: _textFocusNode,
      style: theme.textTheme.displayMedium,
      maxLines: 3,
      controller: _textController,
      onSubmitted: (value) => {_passFocusNode.requestFocus()},
      onChanged: (String e) {
        setState(() {
          xprv = _textController.value.text;
          numLines = '\n'.allMatches(e).length + 1;
          if (_validateXprv(xprv) == null) {
            _errorXprvText = _validateXprv(xprv);
          }
        });
      },
      onTap: () {
        _textFocusNode.requestFocus();
      },
      onTapOutside: (PointerDownEvent event) {
        if (_textFocusNode.hasFocus) {
          setState(() {
            _errorXprvText = _validateXprv(xprv);
          });
        }
      },
    );
  }

  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() async {
    await validateXprv(xprv, _password);
    if (validate(force: true)) {
      Locator.instance<ApiCreateWallet>().setSeed(decryptedLocalXprv!, 'xprv');
      CreateWalletType type =
          BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
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
      // Decript localXprv
      xprvDecripted =
          await apiCrypto.decryptXprv(xprv: xprvString, password: password);
      setState(() => {decryptedLocalXprv = xprvDecripted, isXprvValid = true});
    } catch (e) {
      setState(() => isXprvValid = false);
    }
  }

  bool validate({force = false}) {
    if (this.mounted) {
      setState(() {
        errorText = null;
      });
      if (force || (!_passFocusNode.hasFocus && !_textFocusNode.hasFocus)) {
        if (_password.isEmpty) {
          setState(() {
            errorText = 'Please input a password';
          });
        } else if (force && !isXprvValid) {
          setState(() {
            errorText = 'Invalid Xprv or password';
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
      showPassFocusNode: _showPasswordFocusNode,
      onFieldSubmitted: (String? value) {
        // hide keyboard
        FocusManager.instance.primaryFocus?.unfocus();
        nextAction();
      },
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
            'Import wallet from Xprv key and password',
            style: theme.textTheme.titleLarge, //Textstyle
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'Xprv is a key exchange format that encodes and protects your wallet with a password. Xprv keys look like an long sequence of apparently random letters and numbers, preceded by "xprv".',
            style: theme.textTheme.bodyLarge, //Textstyle
          ),
          Text(
            'To import your wallet from an Xprv key, you need to type the key itself and its password below:',
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
