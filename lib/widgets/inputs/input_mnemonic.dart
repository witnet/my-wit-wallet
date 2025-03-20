import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/inputs/input_text.dart';
import 'package:my_wit_wallet/widgets/validations/address_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

class InputMnemonic extends InputText {
  InputMnemonic({
    super.prefixIcon,
    required super.focusNode,
    super.errorText,
    super.validator,
    super.hint,
    super.keyboardType,
    required super.styledTextController,
    super.obscureText = false,
    this.route,
    super.onChanged,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onTapOutside,
    super.onTap,
    super.onSuffixTap,
    super.inputFormatters,
    super.decoration,
    super.textInputAction,
    super.maxLines = 3,
  });

  final String? route;
  @override
  _InputMnemonicState createState() => _InputMnemonicState();
}

class _InputMnemonicState extends State<InputMnemonic> {
  AddressInput address = AddressInput.pure();
  bool isScanQrFocused = false;
  ValidationUtils validationUtils = ValidationUtils();

  TextSelection? lastSelection;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(widget.onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(widget.onFocusChange);
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    widget.styledTextController.setStyle(
      theme.textTheme.titleLarge!
          .copyWith(color: theme.textTheme.titleLarge!.color),
      theme.textTheme.titleLarge!.copyWith(color: Colors.black),
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.buildInput(
              context: context,
              decoration: InputDecoration(
                suffix: SizedBox(
                  height: 8,
                ),
                hintStyle: theme.textTheme.titleLarge!.copyWith(
                    color: theme.textTheme.titleLarge!.color!
                      ..withValues(alpha: 0.5)),
                hintText: 'recovery phrase',
                errorText: widget.errorText,
              )),
          SizedBox(
            height: 8,
          )
        ]);
  }
}
