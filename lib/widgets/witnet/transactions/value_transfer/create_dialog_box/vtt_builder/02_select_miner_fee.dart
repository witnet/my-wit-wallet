import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  VttAmountInput? _minerFeeWit;
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

  int _minerFeeWitToNanoWitNumber() {
    try {
      final number = num.parse(_minerFeeWit?.value ?? '')
          .standardizeWitUnits(
              outputUnit: WitUnit.nanoWit, inputUnit: WitUnit.Wit)
          .toString();
      return int.parse((number) != '' ? number : '0');
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
      _setFeeType(widget.savedFeeType?.name);
      selectedIndex = widget.savedFeeType == FeeType.Absolute ? 0 : 1;
    }
    _minerFeeController.text = _nanoWitFeeToWit(widget.savedFeeAmount ?? '1');
    _minerFeeWit = VttAmountInput.dirty(
        availableNanoWit: balanceInfo.availableNanoWit,
        value: _nanoWitFeeToWit(widget.savedFeeAmount ?? '1'),
        allowZero: true);
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

  bool validateForm({force = false}) {
    if (force || (!_minerFeeFocusNode.hasFocus)) {
      if (_minerFeeWit != null) {
        return _minerFeeWit?.valid ?? false;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void nextAction() {
    if (validateForm(force: true)) {
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
          _minerFeeWit?.validator(value) != null) {
        _selectedFeeOption = null;
      } else if (_selectedFeeOption == label) {
        _minerFeeWit = VttAmountInput.dirty(
            availableNanoWit: balanceInfo.availableNanoWit,
            value: value,
            allowZero: true);
      }
    }
    return ClickableBox(
      label: label.name,
      isSelected: _selectedFeeOption == label,
      error: _minerFeeWit?.validator(value),
      value: value,
      content: [
        Expanded(
            flex: 1,
            child: Text(label.name, style: theme.textTheme.bodyMedium)),
        Expanded(
            flex: 0,
            child: Text(
                label != EstimatedFeeOptions.Custom
                    ? '$value ${WIT_UNIT[WitUnit.Wit]}'
                    : '',
                style: theme.textTheme.bodyMedium)),
      ],
      onClick: (value) => {
        _setFeeType(FeeType.Absolute.name),
        setState(() {
          _minerFeeWit = VttAmountInput.dirty(
              availableNanoWit: balanceInfo.availableNanoWit,
              value: value,
              allowZero: true);
          _minerFeeController.text = value;
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
              hint: 'Input the miner fee',
              validator: (String? amount) => _minerFeeWit?.error ?? null,
              errorText: _minerFeeWit?.error ?? null,
              textEditingController: _minerFeeController,
              focusNode: _minerFeeFocusNode,
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setState(() {
                  if (value == '') {
                    _minerFeeWit = VttAmountInput.dirty(
                        availableNanoWit: balanceInfo.availableNanoWit,
                        value: '',
                        allowZero: true);
                  } else {
                    _minerFeeWit = VttAmountInput.dirty(
                        availableNanoWit: balanceInfo.availableNanoWit,
                        value: value,
                        allowZero: true);
                  }
                });
              },
              onTap: () {
                _minerFeeFocusNode.requestFocus();
              },
              onFieldSubmitted: (String value) {
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
                    _setFeeType(
                        FeeType.values.map((e) => e.name).toList()[index]);
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
