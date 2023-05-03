import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/storage/database/balance_info.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/input_amount.dart';
import 'package:witnet_wallet/widgets/select.dart';
import 'package:witnet_wallet/util/extensions/text_input_formatter.dart';

class SelectMinerFeeStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  final String? savedFeeAmount;
  final FeeType? savedFeeType;

  SelectMinerFeeStep({
    required Key? key,
    required this.savedFeeAmount,
    required this.savedFeeType,
    required this.currentWallet,
    required this.nextAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SelectMinerFeeStepState();
}

class SelectMinerFeeStepState extends State<SelectMinerFeeStep>
    with SingleTickerProviderStateMixin {
  late BalanceInfo balanceInfo = widget.currentWallet.balanceNanoWit();
  late AnimationController _loadingController;
  final _formKey = GlobalKey<FormState>();
  String _minerFee = '';
  String? _errorFeeText;
  FeeType _feeType = FeeType.Weighted;
  bool _showFeeInput = false;
  final _minerFeeController = TextEditingController();
  final _minerFeeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
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

  num _minerFeeToNumber() {
    try {
      return num.parse(_minerFee != '' ? _minerFee : '0');
    } catch (e) {
      return 0;
    }
  }

  bool _isAbsoluteFee() {
    return _feeType == FeeType.Absolute;
  }

  bool _notEnoughFunds() {
    final balance = balanceInfo.availableNanoWit;
    final amount = BlocProvider.of<VTTCreateBloc>(context)
        .state
        .vtTransaction
        .body
        .outputs
        .first
        .value
        .toInt();
    if (_feeType == FeeType.Absolute) {
      int minerFee = int.parse(_minerFeeToNumber().standardizeWitUnits(
          inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit));
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
      _minerFee = widget.savedFeeAmount!;
    }
    ;
  }

  void _setFeeType(type) {
    setState(() {
      _feeType = type == "Absolute" ? FeeType.Absolute : FeeType.Weighted;
      _showFeeInput = _isAbsoluteFee() ? true : false;
    });
  }

  void _updateTxFee() {
    if (_isAbsoluteFee()) {
      _setAbsoluteFee();
    } else {
      _setWeightedFee();
      validateForm();
    }
  }

  void _setAbsoluteFee() {
    BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
        feeType: FeeType.Absolute,
        feeNanoWit: int.parse(_minerFeeToNumber().standardizeWitUnits(
            inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit))));
  }

  void _setWeightedFee() {
    BlocProvider.of<VTTCreateBloc>(context)
        .add(UpdateFeeEvent(feeType: FeeType.Weighted));
  }

  String? _validateFee(String? input) {
    String? errorText;
    try {
      num.parse(_minerFee != '' ? _minerFee : '0');
    } catch (e) {
      errorText = 'Invalid Amount';
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
      _errorFeeText = _validateFee(_minerFee);
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

  _buildForm(BuildContext context, ThemeData theme) {
    final extendedTheme = theme.extension<ExtendedTheme>();
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              'Miner fee',
              style: theme.textTheme.titleSmall,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Tooltip(
                  height: 100,
                  message:
                      'By default, \'Weighted fee\' is selected.\n\nThe amount of the fee will be calculated, taking into account the weight of the transaction.\n\nTo set an absolute fee, you need to select \'Absolute\' and input a value.',
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(FontAwesomeIcons.circleQuestion,
                          size: 12, color: extendedTheme?.inputIconColor))),
            )
          ]),
          SizedBox(height: 8),
          Select(
              selectedItem: _feeType.name,
              listItems:
                  FeeType.values.map((e) => e.name).toList().reversed.toList(),
              onChanged: (value) => {_setFeeType(value), _updateTxFee()}),
          SizedBox(height: 8),
          _showFeeInput
              ? InputAmount(
                  hint: 'Input the miner fee',
                  errorText: _errorFeeText,
                  textEditingController: _minerFeeController,
                  focusNode: _minerFeeFocusNode,
                  keyboardType: TextInputType.number,
                  validator: _validateFee,
                  onChanged: (String value) {
                    setState(() {
                      _minerFee = value;
                      if (_validateFee(_minerFee) == null) {
                        _errorFeeText = null;
                      }
                    });
                  },
                  onTap: () {
                    _minerFeeFocusNode.requestFocus();
                  },
                  onTapOutside: (PointerDownEvent event) {
                    if (_minerFeeFocusNode.hasFocus) {
                      setState(() {
                        _errorFeeText = _validateFee(_minerFee);
                      });
                    }
                  },
                  onEditingComplete: () {
                    _setAbsoluteFee();
                  },
                )
              : SizedBox(height: 8),
          if (!_showFeeInput && _errorFeeText != null)
            Text(
              _errorFeeText!,
              style: theme.inputDecorationTheme.errorStyle,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _buildForm(context, theme);
  }
}
