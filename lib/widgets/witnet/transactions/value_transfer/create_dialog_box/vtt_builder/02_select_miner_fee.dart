import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/showTxConnectionError.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/validations/fee_amount_input.dart';
import 'package:witnet/data_structures.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/balance_info.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/clickable_box.dart';
import 'package:my_wit_wallet/widgets/input_amount.dart';
import 'package:my_wit_wallet/widgets/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

class SelectMinerFeeStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  final VoidCallback goNext;
  final int? minFee;

  SelectMinerFeeStep({
    required Key? key,
    required this.currentWallet,
    required this.nextAction,
    required this.goNext,
    this.minFee,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SelectMinerFeeStepState();
}

class SelectMinerFeeStepState extends State<SelectMinerFeeStep>
    with SingleTickerProviderStateMixin {
  late BalanceInfo balanceInfo = widget.currentWallet.balanceNanoWit();
  final _formKey = GlobalKey<FormState>();
  Map<EstimatedFeeOptions, String?> _minerFeeOptionsNanoWit =
      DEFAULT_MINER_FEE_OPTIONS;
  FeeAmountInput _minerFeeWit = FeeAmountInput.pure();
  String? _errorFeeText;
  int selectedIndex = 0;
  FeeType _feeType = FeeType.Absolute;
  final _minerFeeController = TextEditingController();
  final _minerFeeFocusNode = FocusNode();
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements() => [_minerFeeFocusNode];
  bool _connectionError = false;
  EstimatedFeeOptions _feeOption = EstimatedFeeOptions.Medium;
  String _savedFeeAmount = '1';
  TransactionBloc get vttBloc => BlocProvider.of<TransactionBloc>(context);

  int? get vttAmount =>
      vttBloc.state.transaction.getNanoWitAmount(vttBloc.state.transactionType);
  bool allowSetMinFeeValue(EstimatedFeeOptions label) =>
      widget.minFee != null && label == EstimatedFeeOptions.Custom;

  /// Overrides
  @override
  void initState() {
    super.initState();
    _setSavedFeeData();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
  }

  @override
  void dispose() {
    _minerFeeController.dispose();
    _minerFeeFocusNode.dispose();
    super.dispose();
  }

  int _minerFeeWitToNanoWitNumber() {
    try {
      final number = num.parse(_minerFeeWit.value)
          .standardizeWitUnits(
              outputUnit: WitUnit.nanoWit, inputUnit: WitUnit.Wit)
          .toBigInt()
          .toInt();
      return _minerFeeWit.value != '' ? number : 0;
    } catch (e) {
      return 0;
    }
  }

  String _nanoWitFeeToWit(String fee, {bool addMinFee = false}) {
    int nanoWitFee = addMinFee ? widget.minFee! + 1 : int.parse(fee);

    try {
      return nanoWitFee
          .standardizeWitUnits(
              outputUnit: WitUnit.Wit, inputUnit: WitUnit.nanoWit)
          .toString();
    } catch (e) {
      return '0';
    }
  }

  void _setSavedFeeData() {
    _minerFeeOptionsNanoWit = vttBloc.minerFeeOptions;
    _feeOption = vttBloc.feeOption;
    _feeType = vttBloc.feeType;
    _savedFeeAmount = vttBloc.feeNanoWit.toString();
    selectedIndex = _feeType == FeeType.Absolute ? 0 : 1;
    String savedFee = _nanoWitFeeToWit(_savedFeeAmount,
        addMinFee: allowSetMinFeeValue(_feeOption));
    _minerFeeController.text = savedFee;

    setState(() {
      setMinerFeeValue(savedFee, validate: false);
    });
  }

  void setMinerFeeValue(String amount, {bool? validate}) {
    int weightedFeeAmount =
        vttBloc.calculatedWeightedFee(_minerFeeWitToNanoWitNumber());
    _minerFeeWit = FeeAmountInput.dirty(
        allowValidation:
            validate ?? validationUtils.isFormUnFocus(_formFocusElements()),
        availableNanoWit: balanceInfo.availableNanoWit,
        value: amount,
        vttAmount: vttAmount ?? 0,
        minFee: widget.minFee,
        weightedAmount: _feeType == FeeType.Weighted ? weightedFeeAmount : null,
        allowZero: true);
  }

  void _setFeeType(FeeType? type) {
    setState(() => _feeType = type ?? FeeType.Absolute);
  }

  void _updateTxFee() {
    if (_feeType == FeeType.Absolute) {
      _setAbsoluteFee();
    }
    if (_feeType == FeeType.Weighted) {
      _setWeightedFee();
    }
    validateForm(force: true);
  }

  void _setAbsoluteFee() {
    vttBloc.add(UpdateFeeEvent(
        feeType: FeeType.Absolute,
        feeNanoWit: _minerFeeWitToNanoWitNumber(),
        feeOption: _feeOption));
  }

  void _setWeightedFee() {
    vttBloc.add(UpdateFeeEvent(
        feeType: FeeType.Weighted,
        feeNanoWit: _minerFeeWitToNanoWitNumber(),
        feeOption: _feeOption));
  }

  bool formValidation() {
    return _minerFeeWit.isValid;
  }

  bool validateForm({force = false}) {
    if (force) {
      setState(() {
        setMinerFeeValue(_minerFeeWit.value, validate: true);
      });
    }
    return formValidation() && !_connectionError;
  }

  void nextAction() {
    if (validateForm(force: true)) {
      _updateTxFee();
    }
  }

  NavAction next() {
    return NavAction(
      label: localization.continueLabel,
      action: nextAction,
    );
  }

  Widget _buildFeeOptionButton(EstimatedFeeOptions label, String value) {
    final theme = Theme.of(context);
    FeeAmountInput _feePriority = FeeAmountInput.dirty(
        value: value,
        allowValidation: true,
        vttAmount: vttAmount ?? 0,
        minFee: widget.minFee,
        availableNanoWit: balanceInfo.availableNanoWit);
    String? errorText =
        _feePriority.validator(value, avoidWeightedAmountCheck: true);
    if (_feeOption != EstimatedFeeOptions.Custom && _feeOption == label) {
      setMinerFeeValue(value);
    }
    return ClickableBox(
      label: localizedFeeOptions[label],
      isSelected: _feeOption == label,
      error: label != EstimatedFeeOptions.Custom ? errorText : null,
      value: value,
      content: [
        Expanded(
            flex: 1,
            child: Text(localizedFeeOptions[label]!,
                style: theme.textTheme.bodyMedium)),
        Expanded(
            flex: 0,
            child: Text(
                label != EstimatedFeeOptions.Custom
                    ? '$value ${WIT_UNIT[WitUnit.Wit]}'
                    : '',
                style: theme.textTheme.bodyMedium)),
      ],
      onClick: (value) => {
        _setFeeType(FeeType.Absolute),
        setState(() {
          setMinerFeeValue(value);
          _minerFeeController.text = value;
          _feeOption = label;
        }),
        _updateTxFee()
      },
    );
  }

  Widget _buildFeeOptionsButtonGroup(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: localizedFeeOptions.length,
      itemBuilder: (context, index) {
        String? fee = _minerFeeOptionsNanoWit.values.toList()[index];
        EstimatedFeeOptions label =
            _minerFeeOptionsNanoWit.keys.toList()[index];
        return _buildFeeOptionButton(
            label,
            _nanoWitFeeToWit(fee ?? '1',
                addMinFee: allowSetMinFeeValue(label)));
      },
    );
  }

  Widget _buildCustomInput(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>();
    _minerFeeFocusNode.addListener(() => validateForm());
    if (_feeOption == EstimatedFeeOptions.Custom) {
      return Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 16),
          child: Column(children: [
            SizedBox(height: 8),
            InputAmount(
              hint: localization.minerFeeInputHint,
              validator: (String? amount) => _minerFeeWit.error ?? null,
              errorText: _minerFeeWit.error ?? null,
              textEditingController: _minerFeeController,
              focusNode: _minerFeeFocusNode,
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setMinerFeeValue(value);
              },
              onTap: () {
                _minerFeeFocusNode.requestFocus();
              },
              onFieldSubmitted: (String value) {
                FocusManager.instance.primaryFocus?.unfocus();
                widget.goNext();
              },
              onEditingComplete: () {
                _setAbsoluteFee();
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Tooltip(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: theme.colorScheme.surface,
                      ),
                      textStyle: theme.textTheme.bodyMedium,
                      height: 100,
                      message: localization.minerFeeHint,
                      child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(FontAwesomeIcons.circleQuestion,
                              size: 12, color: extendedTheme?.inputIconColor))),
                ),
                ToggleSwitch(
                  minWidth: 90.0,
                  inactiveBgColor: extendedTheme?.switchInactiveBg,
                  initialLabelIndex: selectedIndex,
                  activeFgColor: extendedTheme?.switchActiveFg,
                  inactiveFgColor: extendedTheme?.switchInactiveFg,
                  activeBgColor: [extendedTheme!.switchActiveBg!],
                  cornerRadius: 4,
                  borderWidth: 1.0,
                  borderColor: [extendedTheme.switchBorderColor!],
                  totalSwitches: 2,
                  labels: localizedFeeTypeOptions.values.toList(),
                  onToggle: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                    _setFeeType(FeeType.values[index]);
                    _updateTxFee();
                  },
                ),
                SizedBox(height: 8)
              ],
            ),
          ]));
    } else {
      return SizedBox(height: 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<TransactionBloc, TransactionState>(
        listenWhen: (previousState, currentState) {
          if (showTxConnectionReEstablish(previousState.transactionStatus,
              currentState.transactionStatus)) {
            setState(() {
              _connectionError = false;
            });
          }
          return true;
        },
        listener: (context, state) {
          if (state.transactionStatus == TransactionStatus.exception) {
            setState(() {
              _connectionError = true;
            });
          }
        },
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      localization.chooseMinerFee,
                      style: theme.textTheme.titleSmall,
                    ))
              ]),
              SizedBox(height: 16),
              _buildFeeOptionsButtonGroup(context),
              _buildCustomInput(context),
              if (_feeOption != EstimatedFeeOptions.Custom &&
                  _errorFeeText != null)
                Text(
                  _errorFeeText!,
                  style: theme.inputDecorationTheme.errorStyle,
                ),
            ],
          ),
        ));
  }
}
