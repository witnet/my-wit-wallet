import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';

import 'input_text.dart';

class InputSlider extends InputText {
  InputSlider({
    String? route,
    required this.maxAmount,
    required this.minAmount,
    required super.focusNode,
    required super.styledTextController,
    super.validator,
    super.prefixIcon,
    super.errorText,
    super.hint,
    super.keyboardType,
    super.obscureText = false,
    super.onChanged,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onTapOutside,
    super.onTap,
    super.onSuffixTap,
    super.inputFormatters,
  });

  final double maxAmount;
  final double minAmount;

  @override
  _InputSliderState createState() => _InputSliderState();
}

class _InputSliderState extends State<InputSlider> {
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

    String? inputValue = widget.styledTextController.text;
    double sliderValue = 0;
    try {
      sliderValue = inputValue != '' ? double.parse(inputValue) : 0;
    } catch (err) {
      print('Error parsing sliderValue $inputValue');
    }
    return Column(children: [
      Container(
        child: widget.buildInput(
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
      ),
      SizedBox(height: 8),
      Column(children: [
        Slider(
          value:
              sliderValue >= widget.maxAmount ? widget.maxAmount : sliderValue,
          max: widget.maxAmount,
          min: widget.minAmount,
          label: sliderValue.toString(),
          onChanged: (double value) =>
              {widget.onChanged!(value.toStringAsFixed(9))},
        ),
        Row(
          children: [
            Text('Min ${widget.minAmount} ${WIT_UNIT[WitUnit.Wit]}',
                style: theme.textTheme.bodySmall),
            Spacer(),
            Text('Max ${widget.maxAmount} ${WIT_UNIT[WitUnit.Wit]}',
                style: theme.textTheme.bodySmall),
          ],
        )
      ])
    ]);
  }
}
