import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/inputs/input_xprv.dart';
import 'package:my_wit_wallet/widgets/labeled_form_entry.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';
import 'package:my_wit_wallet/widgets/inputs/input_password.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/widgets/select.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/validations/xprv_input.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';
import 'dart:io' show Platform;

final _passController = StyledTextController();
final _textController = StyledTextController();
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
  XprvInput xprv = XprvInput.pure();
  PasswordInput _password = PasswordInput.pure();
  bool isScanQrFocused = false;
  String _selectedOrigin = ImportOrigin.fromMyWitWallet.name;
  CreateWalletType _xprvType = CreateWalletType.encryptedXprv;
  ApiCreateWallet createWalletApi = Locator.instance<ApiCreateWallet>();
  List<FocusNode> _formFocusElements = [_passFocusNode, _textFocusNode];
  ValidationUtils validationUtils = ValidationUtils();

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _textController.clear();
    _scanQrFocusNode.addListener(_handleFocus);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.clearActions(false));
  }

  @override
  void dispose() {
    _scanQrFocusNode.removeListener(_handleFocus);
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
      _xprvType = type;
    });
  }

  void setPassword(String password) {
    setState(() {
      _password = PasswordInput.dirty(
          allowValidation: validationUtils.isFormUnFocus(_formFocusElements),
          value: password);
    });
  }

  void setXprv(String value) {
    xprv = XprvInput.dirty(
        xprvType: _xprvType,
        allowValidation: validationUtils.isFormUnFocus(_formFocusElements),
        value: value);
  }

  void clearForm() {
    _textController.text = '';
    _passController.text = '';
    setState(() {
      xprv = XprvInput.dirty(
          allowValidation: false, value: '', xprvType: _xprvType);
      _password = PasswordInput.dirty(allowValidation: false, value: '');
    });
  }

  void clearXprvError() {
    setState(() {
      xprv = XprvInput.dirty(
          allowValidation: false, value: xprv.value, xprvType: _xprvType);
    });
  }

  void clearPasswordError() {
    setState(() {
      _password =
          PasswordInput.dirty(allowValidation: false, value: _password.value);
    });
  }

  Widget _buildXprvInput() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return InputXprv(
      setXprvCallback: setXprv,
      route: CreateWalletScreen.route,
      decoration: InputDecoration(
        hintStyle: extendedTheme.monoLargeText!.copyWith(
            color: theme.textTheme.titleMedium!.color!.withOpacity(0.5)),
        hintText: localization.xprvInputHint,
        suffixIcon: !Platform.isWindows && !Platform.isLinux
            ? Semantics(
                label: localization.scanQrCodeLabel,
                child: SuffixIcon(
                  focusNode: _scanQrFocusNode,
                  isFocus: isScanQrFocused,
                  icon: FontAwesomeIcons.qrcode,
                  onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QrScanner(
                                currentRoute: CreateWalletScreen.route,
                                onChanged: (String value) async {
                                  _textController.text = value;
                                  xprv = XprvInput.dirty(
                                      xprvType: _xprvType,
                                      allowValidation: false,
                                      value: value);
                                  if (_xprvType == CreateWalletType.xprv) {
                                    validate(force: true);
                                  } else {
                                    _passFocusNode.requestFocus();
                                  }
                                })))
                  },
                ))
            : null,
        errorText: xprv.error,
      ),
      keyboardType: TextInputType.text,
      focusNode: _textFocusNode,
      maxLines: 3,
      styledTextController: _textController,
      onFieldSubmitted: (value) async {
        if (_xprvType == CreateWalletType.encryptedXprv) {
          _passFocusNode.requestFocus();
        } else {
          // hide keyboard
          FocusManager.instance.primaryFocus?.unfocus();
          nextAction();
        }
      },
      onChanged: (String value) async {
        setXprv(_textController.value.text);
        clearPasswordError();
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
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    bool force = true;
    if (await validate(force: force)) {
      createWalletApi.setSeed(
          await createWalletApi.decryptedXprv(
                  xprv.value, _xprvType, _password) ??
              '',
          'xprv');
      createWalletApi
          .setWalletType(xprvTypeToWalletType[_xprvType] ?? WalletType.hd);
      BlocProvider.of<CreateWalletBloc>(context)
          .add(NextCardEvent(type, data: {}));
    }
  }

  NavAction prev() {
    return NavAction(
      label: localization.backLabel,
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: localization.continueLabel,
      action: nextAction,
    );
  }

  bool formValidation() {
    if (_xprvType == CreateWalletType.encryptedXprv) {
      final validInputs = <FormzInput>[
        _password,
        xprv,
      ];
      return Formz.validate(validInputs);
    } else {
      return xprv.isValid;
    }
  }

  Future<bool> validate({force = false}) async {
    if (force) {
      xprv = XprvInput.dirty(
          xprvType: _xprvType,
          allowValidation: true,
          decriptedXprv: await createWalletApi.decryptedXprv(
              xprv.value, _xprvType, _password),
          value: xprv.value);
      setState(() {
        if (_xprvType == CreateWalletType.encryptedXprv) {
          _password = PasswordInput.dirty(
              allowValidation: true, value: _password.value);
        }
      });
    }
    return formValidation();
  }

  Widget _buildPasswordField() {
    return InputPassword(
      hint: localization.passwordLabel,
      focusNode: _passFocusNode,
      styledTextController: _passController,
      obscureText: true,
      errorText: _password.error ?? xprv.error,
      showPassFocusNode: _showPasswordFocusNode,
      onFieldSubmitted: (String? value) {
        // hide keyboard
        FocusManager.instance.primaryFocus?.unfocus();
        nextAction();
      },
      onChanged: (String? value) async {
        if (this.mounted && value != null) {
          setPassword(value);
          clearXprvError();
        }
      },
    );
  }

  String truncateAddress(String addr) {
    var start = addr.substring(0, 11);
    var end = addr.substring(addr.length - 6);
    return '$start...$end';
  }

  ImportOrigin labelToWalletOrigin(String origin) {
    return ImportOrigin.values.firstWhere((e) {
      return e.name == origin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _textFocusNode.addListener(() => formValidation());
    _passFocusNode.addListener(() => formValidation());
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localization.importXprvHeader,
            style: theme.textTheme.titleLarge, //Textstyle
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            localization.importXprv01,
            style: theme.textTheme.bodyLarge, //Textstyle
          ),
          SizedBox(height: 8),
          Text(
            localization.importXprv02,
            style: theme.textTheme.bodyLarge, //Textstyle
          ),
          SizedBox(
            height: 16,
          ),
          LabeledFormEntry(
            label: localization.xprvOrigin,
            formEntry: Select(
                selectedItem: _selectedOrigin,
                listItems: importOriginToXprvType.keys
                    .map((label) => SelectItem(
                        label.name, importOriginToLabel(context)[label] ?? ''))
                    .toList(),
                onChanged: (String? label) => {
                      clearForm(),
                      if (label != null)
                        {
                          setState(() {
                            _selectedOrigin = label;
                          }),
                          _setXprvType(importOriginToXprvType[
                              labelToWalletOrigin(label)]!),
                        },
                    }),
          ),
          SizedBox(
            height: 16,
          ),
          _buildXprvInput(),
          SizedBox(
            height: 16,
          ),
          _xprvType == CreateWalletType.encryptedXprv
              ? _buildPasswordField()
              : SizedBox(
                  height: 0,
                ),
          SizedBox(
            height: _xprvType == CreateWalletType.encryptedXprv ? 16 : 0,
          ),
        ]);
  }
}
