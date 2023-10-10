import 'package:formz/formz.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/widgets/validations/confirmed_password.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();
final _passConfirmFocusNode = FocusNode();
final _showPassFocusNode = FocusNode();
final _showPassConfirmedFocusNode = FocusNode();
final _passConfirmController = TextEditingController();

typedef void VoidCallback(NavAction? value);
typedef void BoolCallback(bool value);

class EncryptWalletCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  final Function clearActions;
  EncryptWalletCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
    required BoolCallback this.clearActions,
  }) : super(key: key);
  EncryptWalletCardState createState() => EncryptWalletCardState();
}

class EncryptWalletCardState extends State<EncryptWalletCard>
    with TickerProviderStateMixin {
  List<FocusNode> _formFocusElements = [_passFocusNode, _passConfirmFocusNode];
  ValidationUtils validationUtils = ValidationUtils();

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() async {
    if (validateForm(force: true)) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.nextAction(null));
      // set masterKey
      Locator.instance<ApiCreateWallet>().setPassword(_password.value);
      await Locator.instance<ApiDatabase>()
          .setPassword(newPassword: _password.value);
      CreateWalletType type =
          BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
      BlocProvider.of<CreateWalletBloc>(context)
          .add(NextCardEvent(type, data: {}));
    }
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

  PasswordInput _password = PasswordInput.pure();
  ConfirmedPassword _confirmPassword = ConfirmedPassword.pure();
  String? errorText;

  bool formValidation() {
    final validInputs = <FormzInput>[
      _password,
      _confirmPassword,
    ];
    return Formz.validate(validInputs);
  }

  bool validateForm({force = false}) {
    if (force) {
      setPassword(_password.value, validate: true);
      setConfirmPassword(_confirmPassword.value, validate: true);
    }
    return formValidation();
  }

  void setPassword(String password, {bool? validate}) {
    setState(() {
      _password = PasswordInput.dirty(
          value: password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements));
    });
  }

  void setConfirmPassword(String password, {bool? validate}) {
    setState(() {
      _confirmPassword = ConfirmedPassword.dirty(
          value: password,
          original: _password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements));
    });
  }

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _passConfirmController.clear();
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

  List<Widget> buildLocalizedTextBlock(BuildContext context) {
    final theme = Theme.of(context);
    String? seedSource = Locator.instance.get<ApiCreateWallet>().seedSource;
    Map<int, String> _encryptWalletTextLocalization(BuildContext context) => {
          0: _localization.encryptWalletHeader,
          1: _localization.encryptWallet01,
          2: _localization.encryptWallet02,
          3: seedSource == "xprv"
              ? _localization.encryptWallet04
              : _localization.encryptWallet03(Locator.instance
                  .get<ApiCreateWallet>()
                  .seedData!
                  .split(' ')
                  .length),
        };
    List<Widget> _widgets = [];
    List<String> _localizedText =
        _encryptWalletTextLocalization(context).values.toList();

    // for each item, add a text widget and a spacer SizedBox
    // if it is the first item, set the text style for a header
    _encryptWalletTextLocalization(context).forEach((key, value) {
      _widgets.add(Text(
        _localizedText[key],
        style:
            key == 0 ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge,
      ));
      _widgets.add(SizedBox(height: 8));
    });
    _widgets.add(SizedBox(height: 8));
    return _widgets;
  }

  @override
  Widget build(BuildContext context) {
    _passConfirmFocusNode.addListener(() => validateForm());
    _passFocusNode.addListener(() => validateForm());
    final theme = Theme.of(context);
    String? seedSource = Locator.instance.get<ApiCreateWallet>().seedSource;
    int? seedLength =
        Locator.instance.get<ApiCreateWallet>().seedData!.split(' ').length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ...buildLocalizedTextBlock(context),
        Text(
          _localization.encryptWalletHeader,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Text(
          _localization.encryptWallet01,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 8),
        Text(
          _localization.encryptWallet02,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 8),
        Text(
          seedSource! == "xprv"
              ? _localization.encryptWallet04
              : _localization.encryptWallet03(seedLength),
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localization.passwordLabel,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: _localization.passwordLabel,
                focusNode: _passFocusNode,
                showPassFocusNode: _showPassFocusNode,
                textEditingController: _passController,
                errorText: _password.error,
                obscureText: true,
                onFieldSubmitted: (String? value) {
                  _passConfirmFocusNode.requestFocus();
                },
                onChanged: (String? value) {
                  if (this.mounted) {
                    setPassword(value ?? '');
                  }
                },
              ),
              SizedBox(height: 16),
              Text(
                _localization.confirmPassword,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: _localization.confirmPassword,
                obscureText: true,
                focusNode: _passConfirmFocusNode,
                showPassFocusNode: _showPassConfirmedFocusNode,
                textEditingController: _passConfirmController,
                errorText: _confirmPassword.error,
                onFieldSubmitted: (String? value) {
                  // hide keyboard
                  FocusManager.instance.primaryFocus?.unfocus();
                  nextAction();
                },
                onChanged: (String? value) {
                  if (this.mounted) {
                    setConfirmPassword(value ?? '');
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
