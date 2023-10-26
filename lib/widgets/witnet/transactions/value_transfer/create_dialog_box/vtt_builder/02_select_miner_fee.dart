import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/showTxConnectionError.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/validations/vtt_amount_input.dart';
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

class SelectMinerFeeStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  final String? savedFeeAmount;
  final FeeType? savedFeeType;
  final VoidCallback goNext;

  SelectMinerFeeStep({
    required Key? key,
    required this.savedFeeAmount,
    required this.savedFeeType,
    required this.currentWallet,
    required this.nextAction,
    required this.goNext,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SelectMinerFeeStepState();
}

class SelectMinerFeeStepState extends State<SelectMinerFeeStep>
    with SingleTickerProviderStateMixin {
  late BalanceInfo balanceInfo = widget.currentWallet.balanceNanoWit();
  late AnimationController _loadingController;
  final _formKey = GlobalKey<FormState>();
  Map<EstimatedFeeOptions, String?> _minerFeeOptionsNanoWit =
      DEFAULT_MINER_FEE_OPTIONS;
  VttAmountInput _minerFeeWit = VttAmountInput.pure();
  String? _errorFeeText;
  int selectedIndex = 0;
  FeeType _feeType = FeeType.Absolute;
  final _minerFeeController = TextEditingController();
  final _minerFeeFocusNode = FocusNode();
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements() => [_minerFeeFocusNode];
  bool _connectionError = false;
  EstimatedFeeOptions? _selectedFeeOption = EstimatedFeeOptions.Medium;

  /// Overrides
  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    VTTCreateBloc vttCreateBloc = BlocProvider.of<VTTCreateBloc>(context);
    _minerFeeOptionsNanoWit = vttCreateBloc.minerFeeOptions;

    if (widget.savedFeeAmount != null) {
      if (_minerFeeOptionsNanoWit.containsValue(widget.savedFeeAmount)) {
        _selectedFeeOption = _minerFeeOptionsNanoWit.entries
            .firstWhere((element) => element.value == widget.savedFeeAmount)
            .key;
      } else {
        _selectedFeeOption = EstimatedFeeOptions.Custom;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => {widget.nextAction(next), _setSavedFeeData()});
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _minerFeeController.dispose();
    _minerFeeFocusNode.dispose();
    super.dispose();
  }

  int _minerFeeWitToNanoWitNumber() {
    num number = 0;
    try {
      if (num.tryParse(_minerFeeWit.value) != null) {
        number = num.parse(_minerFeeWit.value)
            .standardizeWitUnits(
                outputUnit: WitUnit.nanoWit, inputUnit: WitUnit.Wit)
            .toBigInt()
            .toInt();
      }
      return number.toInt();
    } catch (e) {
      return 0;
    }
  }

  String _nanoWitFeeToWit(String fee) {
    try {
      return num.parse(fee)
          .standardizeWitUnits(
              outputUnit: WitUnit.Wit, inputUnit: WitUnit.nanoWit)
          .toString();
    } catch (e) {
      return '0';
    }
  }

  void _setSavedFeeData() {
    if (widget.savedFeeType != null) {
      _setFeeType(widget.savedFeeType);
      selectedIndex = widget.savedFeeType == FeeType.Absolute ? 0 : 1;
    }
    String savedFee = _nanoWitFeeToWit(widget.savedFeeAmount ?? '1');
    _minerFeeController.text = savedFee;
    setState(() {
      setMinerFeeValue(savedFee, validate: false);
    });
  }

  void setMinerFeeValue(String amount, {bool? validate}) {
    int weightedFeeAmount = BlocProvider.of<VTTCreateBloc>(context)
        .calculatedWeightedFee(_minerFeeWitToNanoWitNumber());
    _minerFeeWit = VttAmountInput.dirty(
        allowValidation:
            validate ?? validationUtils.isFormUnFocus(_formFocusElements()),
        availableNanoWit: balanceInfo.availableNanoWit,
        value: amount,
        weightedAmount: _feeType == FeeType.Weighted ? weightedFeeAmount : null,
        allowZero: true);
    // _updateTxFee();
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
    BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
        feeType: FeeType.Absolute, feeNanoWit: _minerFeeWitToNanoWitNumber()));
  }

  void _setWeightedFee() {
    BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
        feeType: FeeType.Weighted, feeNanoWit: _minerFeeWitToNanoWitNumber()));
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

  Widget _buildFeeOptionButton(String label, String value) {
    final theme = Theme.of(context);
    VttAmountInput _feePriority = VttAmountInput.dirty(
        value: value,
        allowValidation: true,
        availableNanoWit: balanceInfo.availableNanoWit);
    String? errorText =
        _feePriority.validator(value, avoidWeightedAmountCheck: true);

    return ClickableBox(
      label: label,
      isSelected: label == localizedFeeOptions[_selectedFeeOption],
      error:
          label != localizedFeeOptions[_selectedFeeOption] ? errorText : null,
      value: value,
      content: [
        Expanded(
            flex: 1, child: Text(label, style: theme.textTheme.bodyMedium)),
        Expanded(
            flex: 0,
            child: Text(
                label == localizedFeeOptions[EstimatedFeeOptions.Custom]
                    ? ''
                    : '$value ${WIT_UNIT[WitUnit.Wit]}',
                style: theme.textTheme.bodyMedium)),
      ],
      onClick: (value) => {
        setState(() {
          _selectedFeeOption = localizedFeeOptions.entries
              .firstWhere((element) => element.value == label)
              .key;
          setMinerFeeValue(value);
          _minerFeeController.text = value;
          _updateTxFee();
        }),
      },
    );
  }

  Widget _buildFeeOptionsButtonGroup(BuildContext context) {
    // TODO:
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: localizedFeeOptions.length,
      itemBuilder: (context, index) {
        EstimatedFeeOptions currentFeeOption =
            localizedFeeOptions.keys.toList()[index];
        String? fee = _minerFeeOptionsNanoWit[currentFeeOption];
        String label = localizedFeeOptions[currentFeeOption]!;
        return _buildFeeOptionButton(label, _nanoWitFeeToWit(fee ?? '1'));
      },
    );
  }

  Widget _buildCustomInput(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>();
    _minerFeeFocusNode.addListener(() => validateForm());
    if (_selectedFeeOption == EstimatedFeeOptions.Custom) {
      return Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
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
                _setSavedFeeData();
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
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.background,
                      ),
                      textStyle: theme.textTheme.bodyMedium,
                      height: 100,
                      message: localization.minerFeeHint,
                      child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(FontAwesomeIcons.circleQuestion,
                              size: 12, color: extendedTheme?.inputIconColor))),
                ),
                // TODO:
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
                      _setFeeType(FeeType.values[index]);
                      _updateTxFee();
                    });
                  },
                ),
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
              SizedBox(height: 8),
              _buildFeeOptionsButtonGroup(context),
              _buildCustomInput(context),
              if (_selectedFeeOption != EstimatedFeeOptions.Custom &&
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
