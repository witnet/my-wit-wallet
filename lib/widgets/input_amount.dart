import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/text_input_formatter.dart';
import 'package:my_wit_wallet/widgets/buttons/text_btn.dart';
import 'package:my_wit_wallet/widgets/input_text.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';
import 'package:my_wit_wallet/widgets/validations/vtt_amount_input.dart';


class InputAmount extends InputText {
  InputAmount({
    required this.amount,
    required FocusNode focusNode,
    required StyledTextController styledTextController,
    IconData? prefixIcon,
    String? errorText,
    String? Function(String?)? validator,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    this.route,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
    void Function(String)? onFieldSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    void Function()? onSuffixTap,
    List<TextInputFormatter>? inputFormatters,
  }) : super(
          prefixIcon: prefixIcon,
          focusNode: focusNode,
          errorText: errorText,
          validator: validator,
          hint: hint,
          keyboardType: keyboardType,
          styledTextController: styledTextController,
          obscureText: obscureText,
          inputFormatters: [WitValueFormatter()],
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          onTapOutside: onTapOutside,
          onTap: onTap,
          onSuffixTap: onSuffixTap,
        );
  final VttAmountInput amount;
  final String? route;

  @override
  _InputAmountState createState() => _InputAmountState();
}

class _InputAmountState extends State<InputAmount> {
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
      theme.textTheme.bodyLarge!,
      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.buildInput(
            context: context,
            decoration: InputDecoration(
              hintText: widget.hint ?? localization.inputAmountHint,
              errorText: widget.errorText,
              prefixIcon:
                  widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
              suffixText: WIT_UNIT[WitUnit.Wit],
              suffixIconConstraints: BoxConstraints(minHeight: 44),
            ),
          ),
          widget.onSuffixTap != null ? SizedBox(height: 8) : Container(),
          widget.onSuffixTap != null
              ? Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Semantics(
                    label: 'Max amount',
                    child: TextBtn(
                      padding: EdgeInsets.zero,
                      boldText: false,
                      text: 'Max',
                      onPressed: widget.onSuffixTap ?? () {},
                    ),
                  ))
              : Container(),
        ]);
  }
}
