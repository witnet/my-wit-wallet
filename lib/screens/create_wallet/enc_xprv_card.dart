import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/widgets/select.dart';
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
  String _selectedOrigin = ImportOrigin.fromMyWitWallet.name;
  CreateWalletType _xprvType = CreateWalletType.encryptedXprv;

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _textController.clear();
    _passFocusNode.addListener(() => validate());
    _scanQrFocusNode.addListener(_handleFocus);
    _textFocusNode.requestFocus();
    _xprvType =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
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

  void _setXprvType(CreateWalletType type) {
    BlocProvider.of<CreateWalletBloc>(context).add(ResetEvent(type));
    setState(() {
      _errorXprvText = null;
      _xprvType = type;
    });
  }

  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  Widget _buildXprvInput() {
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
                                currentRoute: CreateWalletScreen.route,
                                onChanged: (String value) => {
                                      Navigator.popUntil(
                                          context,
                                          ModalRoute.withName(
                                              CreateWalletScreen.route)),
                                      _textController.text = value,
                                      xprv = value,
                                      validate(force: true),
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
          _errorXprvText = null;
          xprv = _textController.value.text;
          validate();
        });
      },
      onTap: () {
        _textFocusNode.requestFocus();
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
      Locator.instance<ApiCreateWallet>()
          .setWalletType(xprvTypeToWalletType[_xprvType] ?? WalletType.hd);
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
      //is is excrypted xprv
      // Decript localXprv
      int xprvLength = xprvString.length;
      if (xprvLength == 293 && _xprvType == CreateWalletType.encryptedXprv) {
        xprvDecripted =
            await apiCrypto.decryptXprv(xprv: xprvString, password: password);
      } else if (xprvLength == 117 && _xprvType == CreateWalletType.xprv) {
        xprvDecripted = await apiCrypto.verifiedXprv(xprv: xprvString);
      }
      if (xprvDecripted != null) {
        setState(
            () => {decryptedLocalXprv = xprvDecripted, isXprvValid = true});
      } else {
        setState(() => isXprvValid = false);
      }
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
        if (_password.isEmpty && _xprvType == CreateWalletType.encryptedXprv) {
          setState(() {
            errorText = 'Please input a password';
          });
        } else if (force && !isXprvValid) {
          setState(() {
            errorText = 'Invalid Xprv or password';
            _errorXprvText = 'Invalid Xprv';
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

  ImportOrigin labelToWalletOrigin(String origin) {
    return ImportOrigin.values.firstWhere((e) {
      return e.name == origin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Text(
        'Import wallet from an Xprv key',
        style: theme.textTheme.titleLarge, //Textstyle
      ),
      SizedBox(
        height: 16,
      ),
      Text(
        'Xprv is a key exchange format that encodes and protects your wallet with a password. Xprv keys look like a long sequence of apparently random letters and numbers, preceded by "xprv".',
        style: theme.textTheme.bodyLarge, //Textstyle
      ),
      SizedBox(height: 8),
      Text(
        'To import your wallet from an Xprv key encrypted with a password, you need to type the key itself and its password below:',
        style: theme.textTheme.bodyLarge, //Textstyle
      ),
      SizedBox(
        height: 16,
      ),
      Text(
        'Xprv origin',
        style: theme.textTheme.titleSmall,
      ),
      SizedBox(height: 8),
      Select(
          selectedItem: _selectedOrigin,
          listItems: importOriginToXprvType.keys
              .map((label) =>
                  SelectItem(label.name, importOriginToLabel[label] ?? ''))
              .toList(),
          onChanged: (String? label) => {
                if (label != null)
                  {
                    setState(() {
                      _selectedOrigin = label;
                    }),
                    _setXprvType(
                        importOriginToXprvType[labelToWalletOrigin(label)]!),
                  },
              }),
      SizedBox(
        height: 16,
      ),
      _buildXprvInput(),
      SizedBox(
        height: 16,
      ),
      type == CreateWalletType.encryptedXprv
          ? _buildPasswordField()
          : SizedBox(
              height: 0,
            ),
      SizedBox(
        height: type == CreateWalletType.encryptedXprv ? 16 : 0,
      ),
    ]);
  }
}
