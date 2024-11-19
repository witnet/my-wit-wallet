import 'package:formz/formz.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/showTxConnectionError.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/util/storage/scanned_content.dart';
import 'package:my_wit_wallet/widgets/buttons/icon_btn.dart';
import 'package:my_wit_wallet/widgets/inputs/input_address.dart';
import 'package:my_wit_wallet/widgets/inputs/input_authorization.dart';
import 'package:my_wit_wallet/widgets/inputs/input_slider.dart';
import 'package:my_wit_wallet/widgets/labeled_form_entry.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart';
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
import 'package:my_wit_wallet/widgets/inputs/input_amount.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';
import 'package:my_wit_wallet/util/extensions/text_input_formatter.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:witnet/utils.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';

class RecipientStep extends StatefulWidget {
  final Function nextAction;
  final WalletStorage walletStorage;
  final VoidCallback goNext;
  final TransactionType transactionType;
  final String routeName;

  RecipientStep({
    required Key? key,
    required this.walletStorage,
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
  late BalanceInfo balanceInfo =
      widget.walletStorage.currentWallet.balanceNanoWit();
  late StakedBalanceInfo stakeInfo =
      widget.walletStorage.currentWallet.stakedNanoWit();
  late Account currentAccount = widget.walletStorage.currentAccount;
  late AnimationController _loadingController;
  final _formKey = GlobalKey<FormState>();
  AddressInput _address = AddressInput.pure();
  VttAmountInput _amount = VttAmountInput.pure();
  VttAmountInput _stakeAmount = VttAmountInput.pure();
  AuthorizationInput _authorization = AuthorizationInput.pure();
  final _amountController = StyledTextController();
  final _amountFocusNode = FocusNode();
  final _stakeAmountController = StyledTextController();
  final _stakeAmountFocusNode = FocusNode();
  final _addressController = StyledTextController();
  final _addressFocusNode = FocusNode();
  final _authorizationController = StyledTextController();
  final _authorizationFocusNode = FocusNode();
  bool _connectionError = false;
  String? errorMessage;

  FocusNode _copyAddressFocusNode = FocusNode();
  bool isCopyAddressFocused = false;
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements() => isVttTransaction
      ? [_addressFocusNode, _amountFocusNode]
      : [_addressFocusNode, _amountFocusNode, _authorizationFocusNode];
  ValueTransferOutput? ongoingOutput;
  TransactionBloc get vttBloc => BlocProvider.of<TransactionBloc>(context);
  String get maxAmountWit => nanoWitToWit(isUnstakeTransaction
          ? stakeInfo.stakedNanoWit
          : balanceInfo.availableNanoWit)
      .toString();
  bool get showTimelockInput => isVttTransaction;
  bool get showAuthorization => isStakeTarnsaction;
  bool get isStakeTarnsaction =>
      widget.transactionType == TransactionType.Stake;
  bool get isVttTransaction => widget.transactionType == TransactionType.Vtt;
  bool get isUnstakeTransaction =>
      widget.transactionType == TransactionType.Unstake;
  bool get showStakeAmountInput => isStakeTarnsaction || isUnstakeTransaction;

  ScannedContent scannedContent = ScannedContent();
  bool showAdvancedSettings = false;
  bool timelockSet = false;
  int _currIndex = 0;
  DateTime currentTime = DateTime.now();
  DateTime? calendarValue;
  @override
  void initState() {
    super.initState();
    _setSavedTxData();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _copyAddressFocusNode.addListener(_handleAddressFocus);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.nextAction(next),
    );
    //Set default timelock for unstake
    if (isUnstakeTransaction) {
      DateTime date = DateTime.now();
      int weeksToAdd = 2;
      setMinimunTimelock(date.add(Duration(days: (7 * weeksToAdd).toInt())));
    }
  }

  @override
  void dispose() {
    _copyAddressFocusNode.removeListener(_handleAddressFocus);
    _loadingController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    _authorizationController.dispose();
    _authorizationFocusNode.dispose();
    super.dispose();
  }

  _handleAddressFocus() {
    setState(() {
      isCopyAddressFocused = _copyAddressFocusNode.hasFocus;
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
    return Formz.validate(showAuthorization ? stakeValidInputs : validInputs);
  }

  bool validateForm({force = false}) {
    if (force) {
      setAddress(_address.value, validate: true);
      setAmount(_amount.value, validate: true);
      if (showAuthorization) {
        setAuthorization(_authorization.value, validate: true);
      }
    }
    return formValidation() && !_connectionError;
  }

  void setAddress(String value, {bool? validate}) {
    setState(() {
      _address = AddressInput.dirty(
          value: value,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus([_addressFocusNode]));
    });
  }

  void setAmount(String value, {bool? validate}) {
    setState(() {
      _amount = VttAmountInput.dirty(
          availableNanoWit: isUnstakeTransaction
              ? stakeInfo.stakedNanoWit
              : balanceInfo.availableNanoWit,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements()),
          value: value);
    });
  }

  void setMinimunTimelock(DateTime date) {
    setState(() {
      timelockSet = true;
      showAdvancedSettings = true;
      calendarValue = date;
    });
  }

  void setAuthorization(String value, {bool? validate}) {
    setState(() {
      _authorization = AuthorizationInput.dirty(
          withdrawerAddress: _address.value,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements()),
          value: value);
    });
  }

  void _setSavedTxData() {
    if (vttBloc.state.transaction.hasOutput(widget.transactionType)) {
      String? savedAddress =
          vttBloc.state.transaction.get(widget.transactionType) != null
              ? vttBloc.state.transaction.getOrigin(widget.transactionType)
              : null;
      String? savedAmount =
          vttBloc.state.transaction.get(widget.transactionType) != null
              ? vttBloc.state.transaction.getAmount(widget.transactionType)
              : null;

      if (savedAddress != null) {
        _addressController.text = savedAddress;
        setAddress(savedAddress, validate: false);
      }

      if (savedAmount != null) {
        _amountController.text = savedAmount;
        setAmount(savedAmount, validate: false);
      }

      if (isStakeTarnsaction) {
        String? savedAuthorization =
            vttBloc.state.transaction.get(widget.transactionType) != null
                ? vttBloc.authorizationString
                : null;
        _authorizationController.text = savedAuthorization ?? '';
        setAuthorization(savedAuthorization ?? '');
      }

      vttBloc.add(ResetTransactionEvent());
    }
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
      if (widget.transactionType == TransactionType.Stake) {
        vttBloc.add(AddStakeOutputEvent(
          currentWallet: widget.walletStorage.currentWallet,
          withdrawer: _address.value,
          authorization: _authorization.value,
          value: int.parse(_amountToNumber()
              .standardizeWitUnits(
                  inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit)
              .toString()),
          merge: true,
        ));
      } else {
        vttBloc.add(AddValueTransferOutputEvent(
            currentWallet: widget.walletStorage.currentWallet,
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
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconBtn(
                  label: localization.addTimelockLabel,
                  padding: EdgeInsets.all(0),
                  text: localization.addTimelockLabel,
                  onPressed: () {
                    setState(() {
                      showAdvancedSettings = !showAdvancedSettings;
                    });
                  },
                  icon: Icon(
                      color: theme.iconTheme.color,
                      showAdvancedSettings
                          ? FontAwesomeIcons.minus
                          : FontAwesomeIcons.plus,
                      size: 15),
                  iconBtnType: IconBtnType.horizontalText,
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
      LabeledFormEntry(
        label: localization.amount,
        formEntry: InputAmount(
          hint: localization.amount,
          errorText: _amount.error,
          styledTextController: _amountController,
          focusNode: _amountFocusNode,
          inputFormatters: [WitValueFormatter()],
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
          onTapOutside: (PointerDownEvent? p) {
            _amountFocusNode.unfocus();
          },
          amount: _amount,
          route: widget.routeName,
        ),
      ),
    ];
  }

  List<Widget> _buildStakeInputAmount(ThemeData theme) {
    int balance = isUnstakeTransaction
        ? stakeInfo.stakedNanoWit
        : balanceInfo.availableNanoWit;
    return [
      SizedBox(height: 16),
      LabeledFormEntry(
          label: localization.amount,
          formEntry: InputSlider(
            hint: localization.amount,
            minAmount: 0.0,
            maxAmount: balance.standardizeWitUnits(truncate: -1).toDouble(),
            errorText: _stakeAmount.error,
            styledTextController: _stakeAmountController,
            focusNode: _stakeAmountFocusNode,
            keyboardType: TextInputType.number,
            onChanged: (String value) {
              _stakeAmountController.text = value;
              setAmount(value);
            },
            onSuffixTap: () => {
              setAmount(maxAmountWit),
              _stakeAmountController.text = maxAmountWit,
            },
            onTap: () {
              _stakeAmountFocusNode.requestFocus();
            },
            onFieldSubmitted: (String value) {
              // hide keyboard
              FocusManager.instance.primaryFocus?.unfocus();
              widget.goNext();
            },
            onTapOutside: (PointerDownEvent event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ))
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
            Text(localization.authorization, style: theme.textTheme.labelLarge),
            SizedBox(width: 8),
            Tooltip(
                height: 60,
                message: localization.autorizationTooltip,
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(FontAwesomeIcons.circleQuestion,
                        size: 12, color: extendedTheme.inputIconColor)))
          ]),
      SizedBox(height: 8),
      InputAuthorization(
        route: widget.routeName,
        keyboardType: TextInputType.text,
        focusNode: _authorizationFocusNode,
        styledTextController: _authorizationController,
        errorText: _authorization.error,
        onFieldSubmitted: (value) async {
          _amountFocusNode.requestFocus();
        },
        onChanged: (String value) async {
          setAuthorization(_authorizationController.value.text);
        },
        onTap: () {
          _authorizationFocusNode.requestFocus();
        },
        onTapOutside: (event) {
          _authorizationFocusNode.unfocus();
        },
      )
    ];
  }

  List<Widget> _buildWithdrawalAddressInput(ThemeData theme) {
    return [
      LabeledFormEntry(
          label: localization.withdrawalAddress,
          formEntry: InputAddress(
            route: widget.routeName,
            errorText: _address.error,
            styledTextController: _addressController,
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
            onTapOutside: (event) {
              _addressFocusNode.unfocus();
            },
          ))
    ];
  }

  List<Widget> _buildReceiverAddressInput(ThemeData theme) {
    return [
      LabeledFormEntry(
        label: localization.address,
        formEntry: InputAddress(
          route: widget.routeName,
          errorText: _address.error,
          styledTextController: _addressController,
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
          onTapOutside: (event) {
            _addressFocusNode.unfocus();
          },
        ),
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
        showTimelockInput
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

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (previousState, currentState) {
        if (showTxConnectionReEstablish(
            previousState.transactionStatus, currentState.transactionStatus)) {
          setState(() {
            _connectionError = false;
            errorMessage = null;
          });
        }
        return true;
      },
      listener: (context, state) {
        if (state.transactionStatus == TransactionStatus.exception ||
            state.transactionStatus == TransactionStatus.explorerException) {
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
