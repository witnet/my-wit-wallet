import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  EstimatedFeeOptions? _selectedFeeOption;

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _minerFeeOptionsNanoWit =
        BlocProvider.of<VTTCreateBloc>(context).minerFeeOptions;
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

  bool _isAbsoluteFee() {
    return _feeType == FeeType.Absolute;
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
  }

  void _setFeeType(FeeType? type) {
    setState(() {
      _feeType = type == FeeType.Absolute ? type! : FeeType.Weighted;
    });
  }

  void _updateTxFee() {
    if (_isAbsoluteFee()) {
      _setAbsoluteFee();
    } else {
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

  Map<String, EstimatedFeeOptions> localizedFeeOptions(BuildContext context) =>
      {
        _localization.estimatedFeeOptions('stinky'): EstimatedFeeOptions.Stinky,
        _localization.estimatedFeeOptions('low'): EstimatedFeeOptions.Low,
        _localization.estimatedFeeOptions('medium'): EstimatedFeeOptions.Medium,
        _localization.estimatedFeeOptions('high'): EstimatedFeeOptions.High,
        _localization.estimatedFeeOptions('opulent'):
            EstimatedFeeOptions.Opulent,
        _localization.estimatedFeeOptions('custom'): EstimatedFeeOptions.Custom,
      };

  Map<FeeType, String> localizedFeeTypeOptions(BuildContext context) => {
        FeeType.Absolute: _localization.feeTypeOptions('absolute'),
        FeeType.Weighted: _localization.feeTypeOptions('weighted'),
      };

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
      label: _localization.continueLabel,
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
    if (_selectedFeeOption != EstimatedFeeOptions.Custom &&
        localizedFeeOptions(context) == label) {
      setMinerFeeValue(value);
    }
    return ClickableBox(
      label: label,
      isSelected: _selectedFeeOption == localizedFeeOptions(context)[label],
      error: label != localizedFeeOptions(context)[_selectedFeeOption!]
          ? errorText
          : null,
      value: value,
      content: [
        Expanded(
            flex: 1, child: Text(label, style: theme.textTheme.bodyMedium)),
        Expanded(
            flex: 0,
            child: Text(
                EstimatedFeeOptions.Custom != localizedFeeOptions(context)[label]
                    ? '$value ${WIT_UNIT[WitUnit.Wit]}'
                    : '',
                style: theme.textTheme.bodyMedium)),
      ],
      onClick: (value) => {
        _setFeeType(FeeType.Absolute),
        setState(() {
          setMinerFeeValue(value);
          _minerFeeController.text = value;
          _selectedFeeOption = localizedFeeOptions(context)[label]!;
        }),
        _updateTxFee(),
      },
    );
  }

  Widget _buildFeeOptionsButtonGroup(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _minerFeeOptionsNanoWit.length,
      itemBuilder: (context, index) {
        String? fee = _minerFeeOptionsNanoWit.values.toList()[index];
        String label = localizedFeeOptions(context).keys.toList()[index];
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
              hint: _localization.minerFeeInputHint,
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
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.background,
                      ),
                      textStyle: theme.textTheme.bodyMedium,
                      height: 100,
                      message: _localization.minerFeeHint,
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
                  labels: localizedFeeTypeOptions(context).values.toList(),
                  onToggle: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                    _setFeeType(FeeType.values[index]);
                    _updateTxFee();
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
    if (_selectedFeeOption == null) {
      _selectedFeeOption = localizedFeeOptions(context).values.first;
    }
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
                      _localization.chooseMinerFee,
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
