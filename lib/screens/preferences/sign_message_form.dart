import 'dart:async';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/screens/preferences/general_config.dart';
import 'package:my_wit_wallet/screens/preferences/preferences_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/get_window_width.dart';
import 'package:my_wit_wallet/util/preferences.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/select.dart';
import 'package:my_wit_wallet/widgets/validations/message_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/unlock_keychain_modal.dart';

typedef void VoidCallback(Map<String, dynamic> signedMessage);

class SignMessageForm extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback signedMessage;

  SignMessageForm({
    Key? key,
    required this.scrollController,
    required this.signedMessage,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => SignMessageFormState();
}

class SignMessageFormState extends State<SignMessageForm> {
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  final _messageController = TextEditingController();
  final _messageFocusNode = FocusNode();
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements() => [_messageFocusNode];
  MessageInput _message = MessageInput.pure();
  Map<String, dynamic>? signedMessage;
  Wallet? _currentWallet;
  String? _address;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _address = database.walletStorage.currentAccount.address;
    _currentWallet = database.walletStorage.currentWallet;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  bool formValidation() {
    final validInputs = <FormzInput>[
      _message,
    ];
    return Formz.validate(validInputs);
  }

  void setMessage(String value, {bool? validate}) {
    setState(() {
      _message = MessageInput.dirty(
          value: value,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements()));
    });
  }

  bool validateForm({force = false}) {
    if (force) {
      setMessage(_message.value, validate: true);
    }
    return formValidation();
  }

  Future<void> _signMessage(String message, String address) async {
    try {
      Map<String, dynamic> signedResult =
          await Locator.instance.get<ApiCrypto>().signMessage(message, address);
      widget.signedMessage(signedResult);
    } catch (err) {
      showSnackBar(err.toString());
      print('${localization.errorSigning} $err');
    }
  }

  void showSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    buildGeneralExceptionModal(
      theme: theme,
      context: context,
      error: localization.signMessageError,
      message: localization.signMessageError,
      errorMessage: message,
      iconName: 'general-warning',
      originRouteName: PreferencePage.route,
      originRoute: PreferencePage(),
    );
  }

  Future<bool> checkBiometricsAuth() async {
    return (await ApiPreferences.getAuthPreferences()) ==
        AuthPreferences.Biometrics.name;
  }

  Future<void> _validateAndSign(String? message, String? address) async {
    setState(() => isLoading = true);
    if (validateForm(force: true)) {
      await _signMessage(message!, address!);
    }
    setState(() => isLoading = false);
  }

  void _signAfterKeychainValidation(String? message, String? address) {
    final theme = Theme.of(context);
    unlockKeychainModal(
        onAction: () async {
          await _validateAndSign(message!, address!);
        },
        title: localization.enterYourPassword,
        imageName: 'import-wallet',
        theme: theme,
        context: context,
        routeToRedirect: PreferencePage.route);
  }

  Future<void> _unlockKeychainAndSign(String? message, String? address) async {
    bool isBiometricsAuthSet = await checkBiometricsAuth();
    if (isBiometricsAuthSet) {
      _signAfterKeychainValidation(message!, address!);
    } else {
      await _validateAndSign(message!, address!);
    }
  }

  Widget _buildMessageInput() {
    final theme = Theme.of(context);
    return TextField(
      decoration: InputDecoration(
        hintStyle: theme.textTheme.bodyLarge!.copyWith(
            color: theme.textTheme.bodyLarge!.color!.withOpacity(0.5)),
        hintText: localization.yourMessage,
        errorText: _message.error,
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.go,
      focusNode: _messageFocusNode,
      style: theme.textTheme.bodyLarge,
      maxLines: 3,
      controller: _messageController,
      onSubmitted: (value) async {
        // hide keyboard
        FocusManager.instance.primaryFocus?.unfocus();
        _unlockKeychainAndSign(_message.value, _address);
      },
      onChanged: (String value) async {
        setMessage(_messageController.value.text);
      },
      onTap: () {
        _messageFocusNode.requestFocus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _messageFocusNode.addListener(() => validateForm());
    List<SelectItem> externalAddresses = _currentWallet!
        .orderedExternalAccounts()
        .values
        .map((Account account) => SelectItem(account.address, account.address))
        .toList();
    List<SelectItem> masterAccountList = [
      SelectItem(_currentWallet!.masterAccount?.address ?? '',
          _currentWallet!.masterAccount?.address ?? '')
    ];
    bool isHdWallet = externalAddresses.length > 0;
    return Form(
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(children: [
          Select(
              selectedItem: _address ?? externalAddresses[0].label,
              cropLabel: true,
              cropMiddleLength: windowWidth > 550 ? null : 28,
              listItems: isHdWallet ? externalAddresses : masterAccountList,
              onChanged: (String? label) =>
                  {if (label != null) setState(() => _address = label)}),
          SizedBox(height: 16),
          _buildMessageInput(),
          SizedBox(height: 16),
          PaddedButton(
              padding: EdgeInsets.zero,
              text: localization.signMessage,
              isLoading: isLoading,
              type: ButtonType.primary,
              enabled: true,
              onPressed: () async {
                await _unlockKeychainAndSign(_message.value, _address);
              })
        ]));
  }
}
