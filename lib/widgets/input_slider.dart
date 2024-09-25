import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/text_input_formatter.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/input_amount.dart';

class InputSlider extends StatefulWidget {
  InputSlider({
    Key? key,
    this.prefixIcon,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.textEditingController,
    this.validator,
    this.errorText,
    this.focusNode,
    required this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onTapOutside,
    this.onTap,
    this.onSuffixTap,
    required this.maxAmount,
    required this.minAmount,
  });
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final String? errorText;
  final String? Function(String?)? validator;
  final String? hint;
  final TextInputType? keyboardType;
  final TextEditingController? textEditingController;
  final bool obscureText;
  final StringCallback onChanged;
  final BlankCallback? onEditingComplete;
  final StringCallback? onFieldSubmitted;
  final PointerDownCallback? onTapOutside;
  final BlankCallback? onTap;
  final BlankCallback? onSuffixTap;
  final double maxAmount;
  final double minAmount;
  @override
  _InputSliderState createState() => _InputSliderState();
}

typedef StringCallback = void Function(String);
typedef BlankCallback = void Function();
typedef PointerDownCallback = void Function(PointerDownEvent);

class _InputSliderState extends State<InputSlider> {
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? inputValue = widget.textEditingController?.text;
    double sliderValue = 0;
    try {
      sliderValue =
          inputValue != null && inputValue != '' ? double.parse(inputValue) : 0;
    } catch (err) {
      print('Error parsing sliderValue $inputValue');
    }
    return Column(children: [
      Container(
        child: InputAmount(
          hint: widget.hint ?? localization.inputAmountHint,
          errorText: widget.errorText,
          onSuffixTap: widget.onSuffixTap ?? () {},
          validator: widget.validator,
          onTap: widget.onTap ?? () {},
          onFieldSubmitted: widget.onFieldSubmitted ?? (String? value) {},
          onEditingComplete: widget.onEditingComplete ?? () {},
          onChanged: widget.onChanged,
          textEditingController: widget.textEditingController,
          focusNode: widget.focusNode,
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
              {widget.onChanged(value.toStringAsFixed(9))},
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
