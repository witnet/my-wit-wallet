import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/widgets/input_text.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';
import 'package:my_wit_wallet/widgets/validations/address_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

class InputMnemonic extends InputText {
  InputMnemonic(
      {IconData? prefixIcon,
        required FocusNode focusNode,
        String? errorText,
        String? Function(String?)? validator,
        String? hint,
        TextInputType? keyboardType,
        required StyledTextController styledTextController,
        bool obscureText = false,
        this.route,
        void Function(String)? onChanged,
        void Function()? onEditingComplete,
        void Function(String)? onFieldSubmitted,
        void Function(PointerDownEvent)? onTapOutside,
        void Function()? onTap,
        void Function()? onSuffixTap,
        List<TextInputFormatter>? inputFormatters,
        InputDecoration? decoration,
        TextInputAction? textInputAction,
        int? maxLines,
      })
      : super(
    prefixIcon: prefixIcon,
    focusNode: focusNode,
    errorText: errorText,
    validator: validator,
    hint: hint,
    keyboardType: keyboardType,
    styledTextController: styledTextController,
    obscureText: obscureText,
    onChanged: onChanged,
    onEditingComplete: onEditingComplete,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: onTapOutside,
    onTap: onTap,
    onSuffixTap: onSuffixTap,
    inputFormatters: inputFormatters,
    decoration: decoration,
    textInputAction: textInputAction,
    maxLines: maxLines ?? 3
  );

  final String? route;
  @override
  _InputMnemonicState createState() => _InputMnemonicState();
}

class _InputMnemonicState extends State<InputMnemonic> {
  AddressInput address = AddressInput.pure();
  FocusNode _scanQrFocusNode = FocusNode();
  bool isScanQrFocused = false;
  ValidationUtils validationUtils = ValidationUtils();

  TextSelection? lastSelection;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    _scanQrFocusNode.addListener(_handleQrFocus);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(_onFocusChange);
    _scanQrFocusNode.removeListener(_handleQrFocus);
  }

  void _onFocusChange() {
    TextSelection collapsed = TextSelection.collapsed(
      offset: widget.styledTextController.selection.baseOffset,
      affinity: TextAffinity.upstream,
    );
    if (!widget.focusNode.hasFocus) {
      lastSelection = widget.styledTextController.selection;
      widget.styledTextController.selection = collapsed;
    } else {
      widget.styledTextController.selection = lastSelection ?? collapsed;
    }
  }

  _handleQrFocus() {
    setState(() {
      isScanQrFocused = _scanQrFocusNode.hasFocus;
    });
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    widget.styledTextController.setStyle(
      theme.textTheme.titleLarge!.copyWith(color: theme.textTheme.titleLarge!.color),
      theme.textTheme.titleLarge!.copyWith(color: Colors.black),
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.buildInput(context: context, decoration: InputDecoration(suffix: SizedBox(height: 8,),
            hintStyle: theme.textTheme.titleLarge!.copyWith(
                color: theme.textTheme.titleLarge!.color!.withOpacity(0.5)),
            hintText: 'recovery phrase',
            errorText: widget.errorText,
          )),
        SizedBox(height: 8,)
        ]);
  }
}
