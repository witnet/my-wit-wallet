import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/encrypt/password.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';

final _passController = TextEditingController();
final _textController = TextEditingController();
final _textFocusNode = FocusNode();
final _passFocusNode = FocusNode();

typedef void VoidCallback(NavAction? value);

class EnterEncryptedXprvCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  EnterEncryptedXprvCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);

  EnterXprvCardState createState() => EnterXprvCardState();
}

class EnterXprvCardState extends State<EnterEncryptedXprvCard>
    with TickerProviderStateMixin {
  String xprv = '';
  String _password = '';
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
  bool _hasInputError = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _textController.clear();
    _passFocusNode.addListener(() => validate());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
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
      style: theme.textTheme.headline2,
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

  void nextAction() {
    Locator.instance<ApiCreateWallet>().setSeed(xprv, 'encryptedXprv');
    Locator.instance<ApiCreateWallet>().setPassword(Password.hash(_password));
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

  bool validXprv(String xprvString, String password) {
    try {
      String passwordHash = Password.hash(password);
      Xprv.fromEncryptedXprv(xprvString, passwordHash);
    } catch (e) {
      return false;
    }
    return true;
  }

  void validate() {
    if (!_passFocusNode.hasFocus && !_textFocusNode.hasFocus) {
      if (this.mounted) {
        if (_password.isEmpty) {
          setState(() {
            _hasInputError = true;
            errorText = 'Please input a password';
          });
        } else if (!validXprv(xprv, _password)) {
          setState(() {
            _hasInputError = true;
            errorText = 'Invalid xprv or password';
          });
        } else {
          setState(() {
            _hasInputError = false;
          });
          widget.nextAction(next);
        }
      }
    } else {
      widget.nextAction(null);
    }
  }

  Widget _buildPasswordField() {
    return InputLogin(
      prefixIcon: Icons.lock,
      hint: 'Password',
      focusNode: _passFocusNode,
      textEditingController: _passController,
      obscureText: true,
      errorText: _hasInputError ? errorText : null,
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
            style: theme.textTheme.headline3, //Textstyle
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'Please paste your xprv used for recovery and type the password created for exporting the file.',
            style: theme.textTheme.bodyText1, //Textstyle
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
