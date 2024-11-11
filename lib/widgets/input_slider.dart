import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';

import 'input_text.dart';

class InputSlider extends InputText {
  InputSlider({
    String? route,
    required this.maxAmount,
    required this.minAmount,
    required FocusNode focusNode,
    required StyledTextController styledTextController,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    String? errorText,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
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
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          onTapOutside: onTapOutside,
          onTap: onTap,
          onSuffixTap: onSuffixTap,
          inputFormatters: inputFormatters,
        );

  final double maxAmount;
  final double minAmount;

  @override
  _InputSliderState createState() => _InputSliderState();
}

typedef StringCallback = void Function(String);
typedef BlankCallback = void Function();
typedef PointerDownCallback = void Function(PointerDownEvent);

class _InputSliderState extends State<InputSlider> {
  TextSelection? lastSelection;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    int offset = widget.styledTextController.selection.baseOffset;
    TextSelection collapsed = TextSelection.collapsed(
      offset: offset,
      affinity: TextAffinity.upstream,
    );
    if (!widget.focusNode.hasFocus) {
      lastSelection = widget.styledTextController.selection;
      widget.styledTextController.selection = collapsed;
    } else {
      widget.styledTextController.selection = lastSelection ?? collapsed;
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
    try {
      sliderValue = inputValue != '' ? double.parse(inputValue) : 0;
    } catch (err) {
      print('Error parsing sliderValue $inputValue');
    }
    return Column(children: [
      Container(
        child: widget.buildInput(context: context,
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
