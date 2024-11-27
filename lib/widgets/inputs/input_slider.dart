import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/widgets/inputs/input_amount.dart';

import 'input_text.dart';

class InputSlider extends InputText {
  InputSlider({
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
    super.enabled,
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

  double getSliderValue({maxAmount, value, minAmount}) {
    if (value >= maxAmount) {
      return maxAmount;
    } else if (value <= minAmount) {
      return minAmount;
    } else {
      return value;
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    widget.styledTextController.setStyle(
      theme.textTheme.bodyLarge!,
      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
    );

    String? inputValue = widget.styledTextController.text;
    double sliderValue = 0;
    bool isSliderDisabled = widget.maxAmount < widget.minAmount;
    double maxAmount = isSliderDisabled ? 0 : widget.maxAmount;
    double minAmount = isSliderDisabled ? 0 : widget.minAmount;
    try {
      sliderValue = inputValue != '' ? double.parse(inputValue) : 0;
    } catch (err) {
      print('Error parsing sliderValue $inputValue');
    }
    return Column(children: [
      Container(
        child: InputAmount(
          hint: localization.amount,
          validator: (String? amount) => widget.errorText ?? null,
          errorText: widget.errorText,
          styledTextController: widget.styledTextController,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          onFieldSubmitted: widget.onFieldSubmitted,
          onEditingComplete: widget.onEditingComplete,
        ),
      ),
      SizedBox(height: 8),
      Column(children: [
        Slider(
          value: getSliderValue(
              maxAmount: maxAmount, minAmount: minAmount, value: sliderValue),
          max: maxAmount,
          min: minAmount,
          label: sliderValue.toString(),
          onChanged: (double value) =>
              {widget.onChanged!(value.toStringAsFixed(9))},
        ),
        Row(
          children: [
            Text(
                'Min ${widget.minAmount.standardizeWitUnits(inputUnit: WitUnit.Wit, outputUnit: WitUnit.Wit)} ${WIT_UNIT[WitUnit.Wit]}',
                style: theme.textTheme.bodySmall),
            Spacer(),
            Text(
                'Max ${widget.maxAmount.standardizeWitUnits(inputUnit: WitUnit.Wit, outputUnit: WitUnit.Wit)} ${WIT_UNIT[WitUnit.Wit]}',
                style: theme.textTheme.bodySmall),
          ],
        )
      ])
    ]);
  }
}
