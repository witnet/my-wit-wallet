import 'package:formz/formz.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/showTxConnectionError.dart';
import 'package:my_wit_wallet/widgets/input_slider.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/widgets/validations/address_input.dart';
import 'package:my_wit_wallet/widgets/validations/authorization_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/validations/vtt_amount_input.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/timelock_input.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_builder/timelock_picker.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/util/storage/database/balance_info.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/input_amount.dart';
import 'package:my_wit_wallet/util/extensions/text_input_formatter.dart';
import 'dart:io' show Platform;
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';
import 'package:witnet/utils.dart';

class RecipientStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  final VoidCallback goNext;
  final TransactionType transactionType;
  final String routeName;

  RecipientStep({
    required Key? key,
    required this.currentWallet,
    required this.nextAction,
    required this.goNext,
    required this.transactionType,
    required this.routeName,
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
  AuthorizationInput _authorization = AuthorizationInput.pure();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();
  final _authorizationController = TextEditingController();
  final _authorizationFocusNode = FocusNode();
  bool _connectionError = false;
  String? errorMessage;
  FocusNode _scanQrFocusNode = FocusNode();
  bool isScanQrFocused = false;
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements() => isVttTransaction
      ? [_addressFocusNode, _amountFocusNode]
      : [_addressFocusNode, _amountFocusNode, _authorizationFocusNode];
  ValueTransferOutput? ongoingOutput;
  VTTCreateBloc get vttBloc => BlocProvider.of<VTTCreateBloc>(context);
  String get maxAmountWit =>
      nanoWitToWit(balanceInfo.availableNanoWit).toString();
  bool get showAuthorization => widget.transactionType == TransactionType.Stake;
  bool get isVttTransaction => widget.transactionType == TransactionType.Vtt;
  bool get showStakeAmountInput =>
      widget.transactionType == TransactionType.Stake ||
      widget.transactionType == TransactionType.Unstake;

  bool showAdvancedSettings = false;
  bool timelockSet = false;
  int _currIndex = 0;
  DateTime currentTime = DateTime.now();
  DateTime? timelockValue;
  DateTime? calendarValue;
  @override
  void initState() {
    super.initState();
    if (vttBloc.outputs.length > 0) {
      ongoingOutput = vttBloc.outputs.first;
      _setSavedTxData(ongoingOutput);
    }
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scanQrFocusNode.addListener(_handleFocus);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.nextAction(next),
    );
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
    final stakeValidInputs = <FormzInput>[
      ...validInputs,
      _authorization,
    ];
    return Formz.validate(showAuthorization ? validInputs : stakeValidInputs);
  }

  bool validateForm({force = false}) {
    if (force) {
      setAddress(_address.value, validate: true);
      setAmount(_amount.value, validate: true);
      if (showAuthorization) {
        setAutorization(_authorization.value, validate: true);
      }
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

  void setAutorization(String value, {bool? validate}) {
    setState(() {
      _authorization = AuthorizationInput.dirty(
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements()),
          value: value);
    });
  }

  void _setSavedTxData(ValueTransferOutput? ongoingOutput) {
    String? savedAddress = ongoingOutput?.pkh.address;
    String? savedAmount =
        ongoingOutput?.value.toInt().standardizeWitUnits().toString();

    if (savedAddress != null) {
      _addressController.text = savedAddress;
      setAddress(savedAddress, validate: false);
    }

    if (savedAmount != null) {
      _amountController.text = savedAmount;
      setAmount(savedAmount, validate: false);
    }

    vttBloc.add(ResetTransactionEvent());
  }

  void nextAction() {
    final theme = Theme.of(context);
    if (_connectionError) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(buildErrorSnackbar(
          theme: theme,
          text: localization.vttException,
          log: errorMessage,
          color: theme.colorScheme.error));
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
            'time_lock': timelockSet ? dateTimeToTimelock(calendarValue) : 0,
          }),
          merge: true));
    }
  }

  NavAction next() {
    return NavAction(
      label: localization.continueLabel,
      action: nextAction,
    );
  }

  void _setTimeLock() async {
    final DateTime? value = await showTimelockPicker(context: context);
    if (value == null) {
      setState(() {
        calendarValue = null;
        timelockSet = false;
      });
    } else {
      setState(() {
        calendarValue = value;
        timelockSet = true;
        _currIndex = _currIndex == 0 ? 1 : 0;
      });
    }
  }

  void _clearTimeLock() async {
    setState(() {
      calendarValue = null;
      timelockSet = false;
      _currIndex = _currIndex == 0 ? 1 : 0;
    });
  }

  _buildCalendarDialogButton(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAdvancedSettings = !showAdvancedSettings;
                    });
                  },
                  child: Row(
                    children: [
                      Text(localization.addTimelockLabel),
                      SizedBox(width: 10),
                      Icon(
                        showAdvancedSettings
                            ? FontAwesomeIcons.minus
                            : FontAwesomeIcons.plus,
                        color: extendedTheme.headerTextColor,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            showAdvancedSettings
                ? Padding(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: TimelockInput(
                        timelockSet: timelockSet,
                        onSelectedDate: _setTimeLock,
                        onClearTimelock: _clearTimeLock,
                        calendarValue: calendarValue))
                : Container()
          ],
        ));
  }

  List<Widget> _buildVttInputAmount(ThemeData theme) {
    return [
      SizedBox(height: 16),
      Text(
        localization.amount,
        style: theme.textTheme.titleSmall,
      ),
      SizedBox(height: 8),
      InputAmount(
        hint: localization.amount,
        errorText: _amount.error,
        textEditingController: _amountController,
        focusNode: _amountFocusNode,
        keyboardType: TextInputType.number,
        onChanged: (String value) {
          setAmount(value);
        },
        onSuffixTap: () => {
          setAmount(maxAmountWit),
          _amountController.text = maxAmountWit,
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
    ];
  }

  List<Widget> _buildStakeInputAmount(ThemeData theme) {
    return [
      SizedBox(height: 16),
      Text(
        localization.amount,
        style: theme.textTheme.titleSmall,
      ),
      SizedBox(height: 8),
      InputSlider(
        hint: localization.amount,
        minAmount: 0.0,
        maxAmount: balanceInfo.availableNanoWit
            .standardizeWitUnits(truncate: -1)
            .toDouble(),
        errorText: _amount.error,
        textEditingController: _amountController,
        focusNode: _amountFocusNode,
        keyboardType: TextInputType.number,
        onChanged: (String value) {
          _amountController.text = value;
          setAmount(value);
        },
        onSuffixTap: () => {
          setAmount(maxAmountWit),
          _amountController.text = maxAmountWit,
        },
        onTap: () {
          _amountFocusNode.requestFocus();
        },
        onFieldSubmitted: (String value) {
          // hide keyboard
          FocusManager.instance.primaryFocus?.unfocus();
          widget.goNext();
        },
      )
    ];
  }

  List<Widget> _buildAuthorizationInput(ThemeData theme) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return [
      SizedBox(height: 16),
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(localization.authorization, style: theme.textTheme.titleSmall),
            SizedBox(width: 8),
            Tooltip(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surface,
                ),
                textStyle: theme.textTheme.bodyMedium,
                height: 60,
                message: localization.autorizationTooltip,
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(FontAwesomeIcons.circleQuestion,
                        size: 12, color: extendedTheme.inputIconColor)))
          ]),
      SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          hintText: localization.authorizationInputHint,
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
                                  currentRoute: widget.routeName,
                                  onChanged: (String value) => {
                                        Navigator.popUntil(
                                            context,
                                            ModalRoute.withName(
                                                widget.routeName)),
                                        _authorizationController.text = value,
                                        setAddress(value)
                                      })))
                    },
                  ))
              : null,
          errorText: _authorization.error,
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.go,
        focusNode: _authorizationFocusNode,
        style: theme.textTheme.displayMedium,
        maxLines: 3,
        controller: _authorizationController,
        onSubmitted: (value) async {
          _amountFocusNode.requestFocus();
        },
        onChanged: (String value) async {
          setAutorization(_authorizationController.value.text);
        },
        onTap: () {
          _authorizationFocusNode.requestFocus();
        },
      )
    ];
  }

  List<Widget> _buildWithdrawalAddressInput(ThemeData theme) {
    return [
      Text(
        localization.withdrawalAddress,
        style: theme.textTheme.titleSmall,
      ),
      SizedBox(height: 8),
      TextFormField(
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: localization.withdrawalAddress,
          suffixIcon: !Platform.isWindows && !Platform.isLinux
              ? SuffixIcon(
                  onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QrScanner(
                                    currentRoute: widget.routeName,
                                    onChanged: (String value) => {
                                          Navigator.popUntil(
                                              context,
                                              ModalRoute.withName(
                                                  widget.routeName)),
                                          _addressController.text = value,
                                          setAddress(value)
                                        })))
                      },
                  icon: FontAwesomeIcons.qrcode,
                  isFocus: isScanQrFocused,
                  focusNode: _scanQrFocusNode)
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
          showAuthorization
              ? _authorizationFocusNode.requestFocus()
              : _amountFocusNode.requestFocus();
        },
        onTap: () {
          _addressFocusNode.requestFocus();
        },
      ),
    ];
  }

  List<Widget> _buildReceiverAddressInput(ThemeData theme) {
    return [
      Text(
        localization.address,
        style: theme.textTheme.titleSmall,
      ),
      SizedBox(height: 8),
      TextFormField(
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: localization.recipientAddress,
          suffixIcon: !Platform.isWindows && !Platform.isLinux
              ? SuffixIcon(
                  onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QrScanner(
                                    currentRoute: widget.routeName,
                                    onChanged: (String value) => {
                                          Navigator.popUntil(
                                              context,
                                              ModalRoute.withName(
                                                  widget.routeName)),
                                          _addressController.text = value,
                                          setAddress(value)
                                        })))
                      },
                  icon: FontAwesomeIcons.qrcode,
                  isFocus: isScanQrFocused,
                  focusNode: _scanQrFocusNode)
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
    ];
  }

  List<Widget> _buildAmountInput(ThemeData theme) {
    return showStakeAmountInput
        ? _buildStakeInputAmount(theme)
        : _buildVttInputAmount(theme);
  }

  List<Widget> _buildAddressInput(ThemeData theme) {
    return showStakeAmountInput
        ? _buildWithdrawalAddressInput(theme)
        : _buildReceiverAddressInput(theme);
  }

  _buildForm(BuildContext context, ThemeData theme) {
    final theme = Theme.of(context);
    _addressFocusNode.addListener(() => validateForm());
    _amountFocusNode.addListener(() => validateForm());
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(children: [
        Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildAddressInput(theme),
                if (showAuthorization) ..._buildAuthorizationInput(theme),
                ..._buildAmountInput(theme),
              ],
            )),
        isVttTransaction
            ? Column(children: [
                _buildCalendarDialogButton(context),
                SizedBox(height: 16),
              ])
            : Container(),
      ]),
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
            errorMessage = null;
          });
        }
        return true;
      },
      listener: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.exception ||
            state.vttCreateStatus == VTTCreateStatus.explorerException) {
          setState(() {
            _connectionError = true;
            errorMessage = state.message;
          });
        }
      },
      child: _buildForm(context, theme),
    );
  }
}
