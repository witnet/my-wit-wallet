import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/custom_page_route.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/util/storage/database/balance_info.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/input_amount.dart';
import 'package:my_wit_wallet/util/extensions/text_input_formatter.dart';
import 'dart:io' show Platform;
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';

class RecipientStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  final ValueTransferOutput? ongoingOutput;
  final VoidCallback goNext;

  RecipientStep({
    required Key? key,
    required this.ongoingOutput,
    required this.currentWallet,
    required this.nextAction,
    required this.goNext,
  }) : super(key: key);

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
  String? _errorAddressText;
  String? _errorAmountText;
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();
  bool _connectionError = false;
  FocusNode _scanQrFocusNode = FocusNode();
  bool isScanQrFocused = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scanQrFocusNode.addListener(_handleFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          widget.nextAction(next),
          _setSavedTxData(),
        });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  _handleFocus() {
    setState(() {
      isScanQrFocused = _scanQrFocusNode.hasFocus;
    });
  }

  num _amountToNumber() {
    try {
      return num.parse(_amount != '' ? _amount : '0');
    } catch (e) {
      return 0;
    }
  }

  bool _notEnoughFunds() {
    final balance = balanceInfo.availableNanoWit;
    int nanoWitAmount = int.parse(_amountToNumber().standardizeWitUnits(
        inputUnit: WitUnit.Wit, outputUnit: WitUnit.nanoWit));
    return balance < nanoWitAmount;
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
      errorText = 'Invalid amount';
    }
    return errorText;
  }

  bool validateForm() {
    setState(() {
      _errorAddressText = _validateAddress(_address);
      _errorAmountText = _validateAmount(_amount);
    });
    return ((_errorAddressText == null && _errorAmountText == null) &&
        _address.isNotEmpty &&
        _amount.isNotEmpty &&
        !_connectionError);
  }

  void _setSavedTxData() {
    String? savedAddress = widget.ongoingOutput?.pkh.address;
    String? savedAmount =
        widget.ongoingOutput?.value.toInt().standardizeWitUnits();

    if (savedAddress != null) {
      _addressController.text = savedAddress;
      _address = savedAddress;
    }

    if (savedAmount != null) {
      _amountController.text = savedAmount;
      _amount = savedAmount;
    }

    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
  }

  void nextAction() {
    final theme = Theme.of(context);
    final vttBloc = BlocProvider.of<VTTCreateBloc>(context);
    if (_connectionError) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          buildExplorerConnectionSnackbar(
              theme,
              'myWitWallet is experiencing connection problems',
              theme.colorScheme.error));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    if (validateForm() && _formKey.currentState!.validate()) {
      vttBloc.add(AddValueTransferOutputEvent(
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
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
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
                          focusNode: _scanQrFocusNode,
                          splashRadius: 1,
                          icon: Icon(FontAwesomeIcons.qrcode),
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    CustomPageRoute(
                                        builder: (BuildContext context) {
                                          return QrScanner(
                                              onChanged: (String value) => {
                                                    Navigator.popUntil(
                                                        context,
                                                        ModalRoute.withName(
                                                            CreateVttScreen
                                                                .route)),
                                                    _addressController.text =
                                                        value,
                                                    _address = value,
                                                    setState(() {
                                                      _errorAddressText =
                                                          _validateAddress(
                                                              value);
                                                    })
                                                  });
                                        },
                                        maintainState: false))
                              },
                          color: isScanQrFocused
                              ? theme.textSelectionTheme.cursorColor
                              : theme.inputDecorationTheme.enabledBorder
                                  ?.borderSide.color)
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
                textEditingController: _amountController,
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
                  widget.goNext();
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
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<VTTCreateBloc, VTTCreateState>(
      listener: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.exception) {
          setState(() {
            _connectionError = true;
          });
        } else {
          setState(() {
            _connectionError = false;
          });
        }
      },
      child: _buildForm(context, theme),
    );
  }
}
