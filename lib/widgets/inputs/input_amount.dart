import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/widgets/buttons/text_btn.dart';
import 'package:my_wit_wallet/widgets/inputs/input_text.dart';

class InputAmount extends InputText {
  InputAmount({
    required super.focusNode,
    required super.styledTextController,
    super.prefixIcon,
    super.errorText,
    super.validator,
    super.hint,
    super.keyboardType,
    super.obscureText,
    super.onChanged,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onTapOutside,
    super.onTap,
    super.onSuffixTap,
    super.inputFormatters,
  });

  @override
  _InputAmountState createState() => _InputAmountState();
}

class _InputAmountState extends State<InputAmount> {
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
