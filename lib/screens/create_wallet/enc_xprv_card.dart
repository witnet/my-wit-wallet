import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/widgets/witnet/password_input.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';

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
  bool useStrongPassword = false;
  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  FocusNode passwordInputFocusNode = FocusNode();
  late TextEditingController passwordInputTextController;

  final TextEditingController textController = TextEditingController();
  int numLines = 0;
  bool _xprvVerified = false;
  bool xprvVerified() => _xprvVerified;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    passwordInputTextController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    passwordInputTextController.dispose();
  }

  Widget _buildConfirmField() {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                controller: textController,
                onChanged: (String e) {
                  setState(() {
                    xprv = textController.value.text;
                    numLines = '\n'.allMatches(e).length + 1;
                  });
                },
                decoration: new InputDecoration(
                  labelText: 'Encrypted XPRV',
                )),
            SizedBox(
              height: 10,
            ),

            //Text
          ],
        ),
      ),
    );
  }

  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    Locator.instance<ApiCreateWallet>().setSeed(xprv, 'encryptedXprv');
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

  bool validBech(String xprvString) {
    try {
      Bech32 bech = bech32.decode(xprvString);
      assert(bech.hrp.isNotEmpty);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool validXprv(String xprvString) {
    try {
      Xprv _xprv = Xprv.fromXprv(xprvString);
      assert(_xprv.address.address.isNotEmpty);
    } catch (e) {
      return false;
    }
    return true;
  }

  Widget _buildPasswordField() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        PasswordInput(
          'Password',
          focusNode: passwordInputFocusNode,
          textEditingController: passwordInputTextController,
          validator: (String? value) {
            if (useStrongPassword) {
              var ensureTwoUpperCase = RegExp(r'^(?=.*[A-Z]){3,}');
              var ensureOneSpecial = RegExp(r'^(?=.*[!@#$&*])');
              var ensureTwoDigits = RegExp(r'^(?=.*[0-9].*[0-9])');
              var ensureThreeLowerCase = RegExp(r'^(?=.*[a-z].*[a-z].*[a-z])');
              if (value != null) {
                if (value.isEmpty) return null;
                if (value.length < 8) return 'Too Short. length 8 required.';
                if (!ensureTwoUpperCase.hasMatch(value))
                  return 'Need two uppercase letters.';
                if (!ensureOneSpecial.hasMatch(value))
                  return 'Need 1 special case !@#\$&*';
                if (!ensureTwoDigits.hasMatch(value))
                  return 'Need 2 digits. 0-9';
                if (!ensureThreeLowerCase.hasMatch(value))
                  return 'Need 3 lowercase letters.';

                return null;
              }
            }
            return null;
          },
          onChanged: (String? value) {
            setState(() {
              _password = value!;
            });
            return value;
          },
          onEditingComplete: () {
            passwordInputFocusNode.unfocus();
          },
          onSubmitted: (String? value) { return value!; },
        ),
      ],
    ));
  }

  String truncateAddress(String addr) {
    var start = addr.substring(0, 11);
    var end = addr.substring(addr.length - 6);
    return '$start...$end';
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: prev,
            child: Text('Go back!'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: xprvVerified() ? next : null,
            child: Text('Confirm'),
          ),
        ),
      ],
    );
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

  Widget _verifyXprvButton() {
    return BlocBuilder<CreateWalletBloc, CreateWalletState>(
        builder: (context, state) {
      if (state.status == CreateWalletStatus.EnterEncryptedXprv) {
        return ElevatedButton(
          onPressed: _password.isEmpty
              ? null
              : () {
                  WalletType type = BlocProvider.of<CreateWalletBloc>(context)
                      .state
                      .walletType;
                  BlocProvider.of<CreateWalletBloc>(context).add(
                      VerifyEncryptedXprvEvent(type,
                          xprv: xprv, password: _password));
                },
          child: Text('Verify'),
        );
      } else if (state.status == CreateWalletStatus.Loading) {
        return Container();
      } else if (state.status == CreateWalletStatus.ValidXprv) {
        try {
          setState(() {
            _xprvVerified = true;
          });
        } catch (e) {}
        return Container(
          padding: EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ],
          ),
        );
      } else if (state.status == CreateWalletStatus.LoadingException) {
        return Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildErrorList([state.message]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [],
              )
            ],
          ),
        );
      } else {
        return Container();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildConfirmField(),
          _buildPasswordField(),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _verifyXprvButton(),
            ],
          ),
        ]);
  }
}
