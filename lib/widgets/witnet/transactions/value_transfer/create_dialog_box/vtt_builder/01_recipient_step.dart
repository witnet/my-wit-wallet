import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/storage/database/balance_info.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/select.dart';

final _addressController = TextEditingController();
final _addressFocusNode = FocusNode();
final _amountController = TextEditingController();
final _amountFocusNode = FocusNode();
final _minerFeeController = TextEditingController();
final _minerFeeFocusNode = FocusNode();

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
  String _feeType = 'Weighted';
  bool _showFeeInput = false;

  @override
  void initState() {
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _addressController.clear();
    _amountController.clear();
    _minerFeeController.clear();
    super.dispose();
  }

  num _minerFeeToNumber() {
    return num.parse(_minerFee != '' ? _minerFee : '0');
  }

  num _amountToNumber() {
    return num.parse(_amount != '' ? _amount : '0');
  }

  bool _isAbsoluteFee(String type) {
    return type == 'Absolute';
  }

  bool _isValidNumber(String number) {
    return double.tryParse(number) != null;
  }

  bool _notEnoughFunds() {
    final balance = balanceInfo.availableNanoWit;
    int minerFee = int.parse(_minerFeeToNumber().standardizeWitUnits(
        inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit));
    String nanoWitAmount = _amountToNumber().standardizeWitUnits(
        inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit);
    int totalToSpend = minerFee + int.parse(nanoWitAmount);
    return balance < totalToSpend;
  }

  bool _notFocusForm() {
    return !_addressFocusNode.hasFocus &&
        !_amountFocusNode.hasFocus &&
        !_minerFeeFocusNode.hasFocus;
  }

  void _setFeeType(type) {
    if (mounted) {
      if (_isAbsoluteFee(type)) {
        setState(() {
          _feeType = type;
          _showFeeInput = true;
        });
        BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
            feeType: FeeType.Absolute,
            feeNanoWit: int.parse(_minerFeeToNumber().standardizeWitUnits(
                inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit))));
      } else {
        setState(() {
          _feeType = type;
          _showFeeInput = false;
        });
        BlocProvider.of<VTTCreateBloc>(context)
            .add(UpdateFeeEvent(feeType: FeeType.Weighted));
      }
      _validateFee();
    }
  }

  bool _validateAddress({force = false}) {
    if (this.mounted) {
      if (force || _notFocusForm()) {
        setState(() {
          _errorAddressText = null;
        });
        if (_address.length == 42) {
          try {
            Address address = Address.fromAddress(_address);
            assert(address.address.isNotEmpty);
          } catch (e) {
            setState(() {
              _errorAddressText = 'Invalid address';
            });
          }
        } else {
          setState(() {
            _errorAddressText = 'Invalid address';
          });
        }
      }
    }
    return _errorAddressText != null ? false : true;
  }

  bool _validateAmount({force = false}) {
    if (this.mounted) {
      if (force || _notFocusForm()) {
        setState(() {
          _errorAmountText = null;
        });
        if (_amount.isEmpty) {
          setState(() {
            _errorAmountText = 'This field is required';
          });
        } else if (!_isValidNumber(_amount)) {
          setState(() {
            _errorAmountText = 'Invalid number';
          });
        } else if (_notEnoughFunds()) {
          setState(() {
            _errorAmountText = 'Not enough funds';
          });
        }
      }
    }
    return _errorAmountText != null ? false : true;
  }

  bool _validateFee({force = false}) {
    if (this.mounted && _isAbsoluteFee(_feeType)) {
      if (force || _notFocusForm()) {
        setState(() {
          _errorFeeText = null;
        });
        if (_minerFee.isEmpty) {
          setState(() {
            _errorFeeText = 'This field is required';
          });
        } else if (!_isValidNumber(_amount)) {
          setState(() {
            _errorFeeText = 'Invalid number';
          });
        } else if (_notEnoughFunds()) {
          setState(() {
            _errorFeeText = 'Not enough funds';
          });
        }
      }
    }
    return _errorFeeText != null ? false : true;
  }

  bool validateForm({force = false}) {
    if (_validateAddress(force: true) &&
        _validateAmount(force: true) &&
        _validateFee(force: true)) {
      return true;
    }
    return false;
  }

  void nextAction() {
    if (validateForm(force: true)) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>();
    _addressFocusNode.addListener(() => _validateAddress());
    _amountFocusNode.addListener(() => _validateAmount());
    _minerFeeFocusNode.addListener(() => _validateFee());
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextField(
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Recipient address',
              errorText: _errorAddressText,
            ),
            controller: _addressController,
            focusNode: _addressFocusNode,
            onSubmitted: (String value) => null,
            onChanged: (String value) {
              setState(() {
                _address = value;
              });
            },
          ),
          SizedBox(height: 16),
          Text(
            'Amount',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          TextField(
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Amount',
              errorText: _errorAmountText,
            ),
            controller: _amountController,
            focusNode: _amountFocusNode,
            onSubmitted: (String value) => null,
            onChanged: (String value) {
              setState(() {
                _amount = value;
              });
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
              selectedItem: _feeType,
              listItems: ['Weighted', 'Absolute'],
              onChanged: (value) => _setFeeType(value)),
          SizedBox(height: 8),
          _showFeeInput
              ? TextField(
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Input the miner fee',
                    errorText: _errorFeeText,
                  ),
                  controller: _minerFeeController,
                  focusNode: _minerFeeFocusNode,
                  onSubmitted: (String value) => null,
                  onChanged: (String value) {
                    setState(() {
                      _minerFee = value;
                      BlocProvider.of<VTTCreateBloc>(context).add(
                          UpdateFeeEvent(
                              feeType: FeeType.Absolute,
                              feeNanoWit: int.parse(_minerFeeToNumber()
                                  .standardizeWitUnits(
                                      inputUnit: WitUnit.Wit,
                                      outputUnit: WitUnit.nanoWit))));
                    });
                  },
                )
              : SizedBox(height: 8),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
