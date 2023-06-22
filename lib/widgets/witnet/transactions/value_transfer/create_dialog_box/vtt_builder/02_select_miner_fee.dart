import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/balance_info.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/clickable_box.dart';
import 'package:my_wit_wallet/widgets/input_amount.dart';
import 'package:my_wit_wallet/util/extensions/text_input_formatter.dart';
import 'package:my_wit_wallet/widgets/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

EstimatedFeeOptions? _selectedFeeOption = EstimatedFeeOptions.Medium;

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
  String _minerFeeNanoWit = '';
  String? _errorFeeText;
  int selectedIndex = 0;
  FeeType _feeType = FeeType.Absolute;
  final _minerFeeController = TextEditingController();
  final _minerFeeFocusNode = FocusNode();

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

  int _minerFeeNanoWitToNumber() {
    try {
      return int.parse(_minerFeeNanoWit != '' ? _minerFeeNanoWit : '0');
    } catch (e) {
      return 0;
    }
  }

  String _nanoWitFeeToWit(String fee) {
    try {
      return num.parse(fee).standardizeWitUnits(
          outputUnit: WitUnit.Wit, inputUnit: WitUnit.nanoWit);
    } catch (e) {
      return '0';
    }
  }

  String _witFeeTonanoWit(String fee) {
    try {
      return num.parse(fee).standardizeWitUnits(
          outputUnit: WitUnit.nanoWit, inputUnit: WitUnit.Wit);
    } catch (e) {
      return '0';
    }
  }

  bool _isAbsoluteFee() {
    return _feeType == FeeType.Absolute;
  }

  bool _notEnoughFunds({int? customFee, FeeType? feeType}) {
    final balance = balanceInfo.availableNanoWit;
    final localFeeType = feeType != null ? feeType : _feeType;
    final amount = BlocProvider.of<VTTCreateBloc>(context)
        .state
        .vtTransaction
        .body
        .outputs
        .first
        .value
        .toInt();
    if (localFeeType == FeeType.Absolute) {
      int minerFee = customFee ?? _minerFeeNanoWitToNumber();
      int totalToSpend = minerFee + amount;
      return balance < totalToSpend;
    } else {
      int? _weightedFee = balanceInfo.weightedVttFee(amount);
      return _weightedFee != null ? balance < _weightedFee + amount : true;
    }
  }

  void _setSavedFeeData() {
    if (widget.savedFeeType != null) _setFeeType(widget.savedFeeType?.name);
    if (_isAbsoluteFee() && widget.savedFeeAmount != null) {
      _minerFeeController.text = widget.savedFeeAmount!;
      _minerFeeNanoWit = widget.savedFeeAmount!;
    }
  }

  void _setFeeType(type) {
    setState(() {
      _feeType = type == "Absolute" ? FeeType.Absolute : FeeType.Weighted;
    });
  }

  void _updateTxFee() {
    if (_isAbsoluteFee()) {
      _setAbsoluteFee();
    } else {
      _setWeightedFee();
    }
    validateForm();
  }

  void _setAbsoluteFee() {
    BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
        feeType: FeeType.Absolute, feeNanoWit: _minerFeeNanoWitToNumber()));
  }

  void _setWeightedFee() {
    BlocProvider.of<VTTCreateBloc>(context)
        .add(UpdateFeeEvent(feeType: FeeType.Weighted));
  }

  String? _validateFee(String? input) {
    String? errorText;
    try {
      num.parse(_minerFeeNanoWit != '' ? _minerFeeNanoWit : '0');
    } catch (e) {
      errorText = 'Invalid amount';
    }
    if (_notEnoughFunds()) {
      errorText = 'Not enough Funds';
    }
    if (_isAbsoluteFee()) {
      errorText = errorText ?? validateWitValue(input);
    }
    return errorText;
  }

  bool validateForm() {
    setState(() {
      _errorFeeText = _validateFee(_minerFeeNanoWit);
    });
    return _errorFeeText == null;
  }

  void nextAction() {
    if (validateForm() && _formKey.currentState!.validate()) {
      _updateTxFee();
    }
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
      action: nextAction,
    );
  }

  Widget _buildFeeOptionButton(EstimatedFeeOptions label, String value) {
    final theme = Theme.of(context);
    if (_selectedFeeOption != EstimatedFeeOptions.Custom) {
      if (_selectedFeeOption == label &&
          _notEnoughFunds(customFee: int.parse(value))) {
        _selectedFeeOption = null;
      } else if (_selectedFeeOption == label) {
        _minerFeeNanoWit = value;
      }
    }
    return ClickableBox(
      label: label.name,
      isSelected: _selectedFeeOption == label,
      error: label != EstimatedFeeOptions.Custom &&
              _notEnoughFunds(
                  customFee: int.parse(value), feeType: FeeType.Absolute)
          ? 'Not enough Funds'
          : null,
      value: value,
      content: [
        Expanded(
            flex: 1,
            child: Text(label.name, style: theme.textTheme.bodyMedium)),
        Expanded(
            flex: 0,
            child: Text(
                label != EstimatedFeeOptions.Custom
                    ? '${_nanoWitFeeToWit(value)} ${WIT_UNIT[WitUnit.Wit]}'
                    : '',
                style: theme.textTheme.bodyMedium)),
      ],
      onClick: (value) => {
        setState(() {
          _minerFeeNanoWit = value;
          _minerFeeController.text = _nanoWitFeeToWit(value);
          _selectedFeeOption = label;
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
        EstimatedFeeOptions label =
            _minerFeeOptionsNanoWit.keys.toList()[index];
        return _buildFeeOptionButton(label, fee ?? '1');
      },
    );
  }

  Widget _buildCustomInput(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>();
    if (_selectedFeeOption == EstimatedFeeOptions.Custom) {
      return Column(children: [
        SizedBox(height: 8),
        InputAmount(
          hint: 'Input the miner fee',
          errorText: _errorFeeText,
          textEditingController: _minerFeeController,
          focusNode: _minerFeeFocusNode,
          keyboardType: TextInputType.number,
          validator: _validateFee,
          onChanged: (String value) {
            setState(() {
              if (value == '') {
                _minerFeeNanoWit = '';
              } else {
                _minerFeeNanoWit = _witFeeTonanoWit(value);
              }
              if (_validateFee(_minerFeeNanoWit) == null) {
                _errorFeeText = null;
              }
            });
          },
          onTap: () {
            _minerFeeFocusNode.requestFocus();
          },
          onFieldSubmitted: (String value) {
            widget.goNext();
          },
          onTapOutside: (PointerDownEvent event) {
            if (_minerFeeFocusNode.hasFocus) {
              setState(() {
                _errorFeeText = _validateFee(_minerFeeNanoWit);
              });
            }
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.background,
                  ),
                  textStyle: theme.textTheme.bodyMedium,
                  height: 100,
                  message:
                      'By default, \'Absolute fee\' is selected.\nTo set a custom weighted fee, you need to select \'Weighted\'. \nThe Weighted fee is automatically calculated by the wallet considering the network congestion and transaction weight multiplied by the value selected as custom.',
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
              labels: FeeType.values.map((e) => e.name).toList(),
              onToggle: (index) {
                setState(() {
                  selectedIndex = index;
                });
                _setFeeType(FeeType.values.map((e) => e.name).toList()[index]);
                _updateTxFee();
              },
            ),
          ],
        ),
      ]);
    } else {
      return SizedBox(height: 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'Choose your desired miner fee',
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
    );
  }
}
