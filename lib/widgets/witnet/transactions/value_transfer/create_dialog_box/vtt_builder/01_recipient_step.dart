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
  bool _hasAddressError = false;
  String _errorAddressText = '';
  bool _hasAmountError = false;
  String _errorAmountText = '';
  bool _hasFeeError = false;
  String _errorFeeText = '';
  String _feeType = 'Weighted';
  bool _showFeeInput = false;

  @override
  void initState() {
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    super.initState();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  int _minerFeeToNumber() {
    return int.parse(_amount != '' ? _amount : '0');
  }

  bool _isAbsoluteFee(String type) {
    return type == 'Absolute';
  }

  bool _notFocusForm() {
    return !_addressFocusNode.hasFocus &&
        !_amountFocusNode.hasFocus &&
        !_minerFeeFocusNode.hasFocus;
  }

  bool isAnyFormError() {
    if (_isAbsoluteFee(_feeType)) {
      return (_hasAddressError || _hasAmountError || _hasFeeError) ||
          (_address.isEmpty || _amount.isEmpty || _minerFee.isEmpty);
    } else {
      return (_hasAddressError || _hasAmountError) ||
          (_address.isEmpty || _amount.isEmpty);
    }
  }

  void _setFeeType(type) {
    if (mounted) {
      if (_isAbsoluteFee(type)) {
        setState(() {
          _feeType = type;
          _showFeeInput = true;
        });
        BlocProvider.of<VTTCreateBloc>(context).add(UpdateFeeEvent(
            feeType: FeeType.Absolute, feeNanoWit: _minerFeeToNumber()));
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

  void _validateAddress() {
    if (_notFocusForm()) {
      if (this.mounted) {
        if (_address.length == 42) {
          try {
            Address address = Address.fromAddress(_address);
            assert(address.address.isNotEmpty);
            setState(() {
              _hasAddressError = false;
            });
          } catch (e) {
            setState(() {
              _hasAddressError = true;
              _errorAddressText = 'Invalid address';
            });
          }
        } else {
          isAnyFormError() ? widget.nextAction(null) : widget.nextAction(next);
          setState(() {
            _hasAddressError = true;
            _errorAddressText = 'Invalid address';
          });
        }
      }
    } else {
      widget.nextAction(null);
    }
  }

  void _validateAmount() {
    if (_notFocusForm()) {
      if (this.mounted) {
        if (_amount.isEmpty) {
          setState(() {
            _hasAmountError = true;
            _errorAmountText = 'This field is required';
          });
        } else if (balanceInfo.availableNanoWit < _minerFeeToNumber()) {
          setState(() {
            _hasAmountError = true;
            _errorAmountText = 'Not enough funds';
          });
        } else {
          isAnyFormError() ? widget.nextAction(null) : widget.nextAction(next);
          setState(() {
            _hasAmountError = false;
          });
        }
      }
    } else {
      widget.nextAction(null);
    }
  }

  void _validateFee() {
    if (!_isAbsoluteFee(_feeType)) {
      isAnyFormError() ? widget.nextAction(null) : widget.nextAction(next);
    } else {
      if (_notFocusForm()) {
        if (this.mounted) {
          if (_minerFee.isEmpty) {
            setState(() {
              _hasFeeError = true;
              _errorFeeText = 'This field is required';
            });
            widget.nextAction(null);
          } else if (balanceInfo.availableNanoWit < _minerFeeToNumber()) {
            setState(() {
              _hasFeeError = true;
              _errorFeeText = 'Not enough funds';
            });
            widget.nextAction(null);
          } else {
            isAnyFormError()
                ? widget.nextAction(null)
                : widget.nextAction(next);
            setState(() {
              _hasFeeError = false;
            });
          }
        }
      } else {
        widget.nextAction(null);
      }
    }
  }

  void nextAction() {
    BlocProvider.of<VTTCreateBloc>(context).add(AddValueTransferOutputEvent(
        output: ValueTransferOutput.fromJson(
            {'pkh': _address, 'value': int.parse(_amount), 'time_lock': 0}),
        merge: true));
    BlocProvider.of<VTTCreateBloc>(context).add(ValidateTransactionEvent());
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
            style: theme.textTheme.subtitle2,
          ),
          SizedBox(height: 8),
          TextField(
            style: theme.textTheme.bodyText1,
            decoration: InputDecoration(
              hintText: 'Recipient address',
              errorText: _hasAddressError ? _errorAddressText : null,
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
            style: theme.textTheme.subtitle2,
          ),
          SizedBox(height: 8),
          TextField(
            style: theme.textTheme.bodyText1,
            decoration: InputDecoration(
              hintText: 'Amount',
              errorText: _hasAmountError ? _errorAmountText : null,
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
              style: theme.textTheme.subtitle2,
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
                  style: theme.textTheme.bodyText1,
                  decoration: InputDecoration(
                    hintText: 'Input the miner fee',
                    errorText: _hasFeeError ? _errorFeeText : null,
                  ),
                  controller: _minerFeeController,
                  focusNode: _minerFeeFocusNode,
                  onSubmitted: (String value) => null,
                  onChanged: (String value) {
                    setState(() {
                      _minerFee = value;
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
