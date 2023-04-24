import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/storage/database/balance_info.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/input_amount.dart';
import 'package:witnet_wallet/widgets/select.dart';
import 'package:witnet_wallet/util/extensions/text_input_formatter.dart';
import 'dart:io' show Platform;
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';

class RecipientStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;

  RecipientStep({
    required this.currentWallet,
    required this.nextAction,
  });

  @override
  State<StatefulWidget> createState() => RecipientStepState();
}

class RecipientStepState extends State<RecipientStep>
    with SingleTickerProviderStateMixin {
  late BalanceInfo balanceInfo = widget.currentWallet.balanceNanoWit();
  late AnimationController _loadingController;
  final _formKey = GlobalKey<FormState>();
  String _address = '';
  String _amount = '';
  String _minerFee = '';
  String? _errorAddressText;
  String? _errorAmountText;
  String? _errorFeeText;
  FeeType _feeType = FeeType.Weighted;
  bool _showFeeInput = false;
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _minerFeeController = TextEditingController();
  final _minerFeeFocusNode = FocusNode();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    _amountController.dispose();
    _minerFeeController.dispose();
    _amountFocusNode.dispose();
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

  num _amountToNumber() {
    try {
      return num.parse(_amount != '' ? _amount : '0');
    } catch (e) {
      return 0;
    }
  }

  bool _isAbsoluteFee() {
    return _feeType == FeeType.Absolute;
  }

  bool _notEnoughFunds() {
    final balance = balanceInfo.availableNanoWit;
    int nanoWitAmount = int.parse(_amountToNumber().standardizeWitUnits(
        inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit));
    if (_feeType == FeeType.Absolute) {
      int minerFee = int.parse(_minerFeeToNumber().standardizeWitUnits(
          inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit));
      int totalToSpend = minerFee + nanoWitAmount;
      return balance < totalToSpend;
    } else {
      int? _weightedFee = balanceInfo.weightedVttFee(nanoWitAmount);
      return _weightedFee != null
          ? balance < _weightedFee + nanoWitAmount
          : true;
    }
  }

  void _setFeeType(type) {
    setState(() {
      _feeType = type == "Absolute" ? FeeType.Absolute : FeeType.Weighted;
      _showFeeInput = _isAbsoluteFee() ? true : false;
    });
    if (_isAbsoluteFee()) {
      _validateFee(_minerFee);
      BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
          feeType: FeeType.Absolute,
          feeNanoWit: int.parse(_minerFeeToNumber().standardizeWitUnits(
              inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit))));
    } else {
      BlocProvider.of<VTTCreateBloc>(context)
          .add(UpdateFeeEvent(feeType: FeeType.Weighted));
    }
  }

  String? _validateAddress(String? input) {
    return validateAddress(input);
  }

  String? _validateAmount(String? input) {
    String? errorText;
    if (_notEnoughFunds()) {
      errorText = 'Not enough Funds';
    }
    errorText = errorText ?? validateWitValue(input);
    try {
      if (num.parse(input!) == 0) {
        errorText = errorText ?? 'Amount cannot be zero';
      }
    } catch (e) {
      errorText = 'Invalid Amount';
    }
    return errorText;
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
      _errorAddressText = _validateAddress(_address);
      _errorAmountText = _validateAmount(_amount);
      if (_feeType == FeeType.Absolute) {
        _errorFeeText = _validateFee(_minerFee);
      }
    });
    if (_isAbsoluteFee()) {
      if ((_errorAddressText == null &&
              _errorAmountText == null &&
              _errorFeeText == null) &&
          !(_address.isEmpty || _amount.isEmpty || _minerFee.isEmpty)) {
        return true;
      }
    } else {
      if ((_errorAddressText == null && _errorAmountText == null) &&
          !(_address.isEmpty || _amount.isEmpty)) {
        return true;
      }
    }
    return false;
  }

  void nextAction() {
    if (validateForm() && _formKey.currentState!.validate()) {
      BlocProvider.of<VTTCreateBloc>(context).add(AddValueTransferOutputEvent(
          currentWallet: widget.currentWallet,
          output: ValueTransferOutput.fromJson({
            'pkh': _address,
            'value': int.parse(_amountToNumber().standardizeWitUnits(
                inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit)),
            'time_lock': 0
          }),
          merge: true));
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
          Text(
            'Address',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextFormField(
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Recipient address',
              suffixIcon: !Platform.isWindows && !Platform.isLinux
                  ? IconButton(
                      splashRadius: 1,
                      icon: Icon(FontAwesomeIcons.qrcode),
                      onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QrScanner(
                                        onChanged: (String value) => {
                                              Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      CreateVttScreen.route)),
                                              _addressController.text = value,
                                              _address = value,
                                              setState(() {
                                                _errorAddressText =
                                                    _validateAddress(value);
                                              })
                                            })))
                          },
                      color: theme
                          .inputDecorationTheme.enabledBorder?.borderSide.color)
                  : null,
              errorText: _errorAddressText,
            ),
            controller: _addressController,
            focusNode: _addressFocusNode,
            keyboardType: TextInputType.text,
            validator: _validateAddress,
            inputFormatters: [WitAddressFormatter()],
            onChanged: (String value) {
              setState(() {
                _address = value;
                if (_validateAddress(_address) == null) {
                  _errorAddressText = _validateAddress(_address);
                }
              });
            },
            onFieldSubmitted: (String value) {
              _amountFocusNode.requestFocus();
            },
            onTap: () {
              _addressFocusNode.requestFocus();
            },
            onTapOutside: (PointerDownEvent event) {
              if (_addressFocusNode.hasFocus) {
                setState(() {
                  _errorAddressText = _validateAddress(_address);
                });
              }
            },
          ),
          SizedBox(height: 16),
          Text(
            'Amount',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          InputAmount(
            hint: 'Amount',
            errorText: _errorAmountText,
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: TextInputType.number,
            validator: _validateAmount,
            onChanged: (String value) {
              setState(() {
                _amount = value;
                if (_validateAmount(_amount) == null) {
                  _errorAmountText = null;
                }
              });
            },
            onTap: () {
              _amountFocusNode.requestFocus();
            },
            onFieldSubmitted: (String value) {
              if (_feeType == FeeType.Absolute) {
                _amountFocusNode.requestFocus();
              }
            },
            onTapOutside: (PointerDownEvent event) {
              if (_amountFocusNode.hasFocus) {
                setState(() {
                  _errorAmountText = _validateAmount(_amount);
                });
              }
            },
          ),
          SizedBox(height: 16),
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
              onChanged: (value) => _setFeeType(value)),
          SizedBox(height: 8),
          _showFeeInput ? InputAmount(
            hint: 'Input the miner fee',
            errorText: _errorFeeText,
            controller: _minerFeeController,
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
              BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
                  feeType: FeeType.Absolute,
                  feeNanoWit: int.parse(_minerFeeToNumber()
                      .standardizeWitUnits(
                          inputUnit: WitUnit.Wit,
                          outputUnit: WitUnit.nanoWit))));
            },
          ) : SizedBox(height: 8),
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
