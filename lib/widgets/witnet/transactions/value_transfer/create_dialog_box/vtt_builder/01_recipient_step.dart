import 'package:formz/formz.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/showTxConnectionError.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/validations/address_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/validations/vtt_amount_input.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/util/storage/database/balance_info.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/input_amount.dart';
import 'package:my_wit_wallet/util/extensions/text_input_formatter.dart';
import 'dart:io' show Platform;
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';

class RecipientStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  final ValueTransferOutput? ongoingOutput;
  final VoidCallback goNext;

  RecipientStep({
    required Key? key,
    required this.ongoingOutput,
    required this.currentWallet,
    required this.nextAction,
    required this.goNext,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RecipientStepState();
}

class RecipientStepState extends State<RecipientStep>
    with SingleTickerProviderStateMixin {
  late BalanceInfo balanceInfo = widget.currentWallet.balanceNanoWit();
  late AnimationController _loadingController;
  final _formKey = GlobalKey<FormState>();
  AddressInput _address = AddressInput.pure();
  VttAmountInput _amount = VttAmountInput.pure();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();
  bool _connectionError = false;
  FocusNode _scanQrFocusNode = FocusNode();
  bool isScanQrFocused = false;
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements() => [_addressFocusNode, _amountFocusNode];

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scanQrFocusNode.addListener(_handleFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          widget.nextAction(next),
          _setSavedTxData(),
        });
  }

  @override
  void dispose() {
    _scanQrFocusNode.removeListener(_handleFocus);
    _loadingController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  _handleFocus() {
    setState(() {
      isScanQrFocused = _scanQrFocusNode.hasFocus;
    });
  }

  num _amountToNumber() {
    try {
      return num.parse((_amount.value) != '' ? _amount.value : '0');
    } catch (e) {
      return 0;
    }
  }

  bool formValidation() {
    final validInputs = <FormzInput>[
      _amount,
      _address,
    ];
    return Formz.validate(validInputs);
  }

  bool validateForm({force = false}) {
    if (force) {
      setAddress(_address.value, validate: true);
      setAmount(_amount.value, validate: true);
    }
    return formValidation() && !_connectionError;
  }

  void setAddress(String value, {bool? validate}) {
    setState(() {
      _address = AddressInput.dirty(
          value: value,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements()));
    });
  }

  void setAmount(String value, {bool? validate}) {
    setState(() {
      _amount = VttAmountInput.dirty(
          availableNanoWit: balanceInfo.availableNanoWit,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements()),
          value: value);
    });
  }

  void _setSavedTxData() {
    String? savedAddress = widget.ongoingOutput?.pkh.address;
    String? savedAmount =
        widget.ongoingOutput?.value.toInt().standardizeWitUnits().toString();

    if (savedAddress != null) {
      _addressController.text = savedAddress;
      setAddress(savedAddress, validate: false);
    }

    if (savedAmount != null) {
      _amountController.text = savedAmount;
      setAmount(savedAmount, validate: false);
    }

    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
  }

  void nextAction() {
    final theme = Theme.of(context);
    final vttBloc = BlocProvider.of<VTTCreateBloc>(context);
    if (_connectionError) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
          theme, _localization.connectionIssue, theme.colorScheme.error));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    if (validateForm(force: true)) {
      vttBloc.add(AddValueTransferOutputEvent(
          currentWallet: widget.currentWallet,
          output: ValueTransferOutput.fromJson({
            'pkh': _address.value,
            'value': int.parse(_amountToNumber()
                .standardizeWitUnits(
                    inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit)
                .toString()),
            'time_lock': 0
          }),
          merge: true));
    }
  }

  NavAction next() {
    return NavAction(
      label: _localization.continueLabel,
      action: nextAction,
    );
  }

  _buildForm(BuildContext context, ThemeData theme) {
    _addressFocusNode.addListener(() => validateForm());
    _amountFocusNode.addListener(() => validateForm());
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localization.address,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              TextFormField(
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: _localization.recipientAddress,
                  suffixIcon: !Platform.isWindows && !Platform.isLinux
                      ? IconButton(
                          focusNode: _scanQrFocusNode,
                          splashRadius: 1,
                          icon: Icon(FontAwesomeIcons.qrcode),
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => QrScanner(
                                            currentRoute: CreateVttScreen.route,
                                            onChanged: (String value) => {
                                                  Navigator.popUntil(
                                                      context,
                                                      ModalRoute.withName(
                                                          CreateVttScreen
                                                              .route)),
                                                  _addressController.text =
                                                      value,
                                                  setAddress(value)
                                                })))
                              },
                          color: isScanQrFocused
                              ? theme.textSelectionTheme.cursorColor
                              : theme.inputDecorationTheme.enabledBorder
                                  ?.borderSide.color)
                      : null,
                  errorText: _address.error,
                ),
                controller: _addressController,
                focusNode: _addressFocusNode,
                keyboardType: TextInputType.text,
                inputFormatters: [WitAddressFormatter()],
                onChanged: (String value) {
                  setAddress(value);
                },
                onFieldSubmitted: (String value) {
                  _amountFocusNode.requestFocus();
                },
                onTap: () {
                  _addressFocusNode.requestFocus();
                },
              ),
              SizedBox(height: 16),
              Text(
                _localization.amount,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputAmount(
                hint: _localization.amount,
                errorText: _amount.error,
                textEditingController: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  setAmount(value);
                },
                onTap: () {
                  _amountFocusNode.requestFocus();
                },
                onFieldSubmitted: (String value) {
                  // hide keyboard
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.goNext();
                },
              ),
              SizedBox(height: 16),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<VTTCreateBloc, VTTCreateState>(
      listenWhen: (previousState, currentState) {
        if (showTxConnectionReEstablish(
            previousState.vttCreateStatus, currentState.vttCreateStatus)) {
          setState(() {
            _connectionError = false;
          });
        }
        return true;
      },
      listener: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.exception) {
          setState(() {
            _connectionError = true;
          });
        }
      },
      child: _buildForm(context, theme),
    );
  }
}
