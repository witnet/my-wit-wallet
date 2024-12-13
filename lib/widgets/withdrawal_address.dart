import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/copy_button.dart';
import 'package:my_wit_wallet/widgets/inputs/input_text.dart';

import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/scanned_content.dart';

class WithdrawerAddress extends InputText {
  WithdrawerAddress({
    required super.focusNode,
    required super.styledTextController,
    super.prefixIcon,
    super.enabled = true,
    super.errorText,
    super.validator,
    super.hint,
    super.keyboardType,
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
    super.maxLines = 1,
    this.setAddressCallback,
  });

  final String? route;
  final void Function(String, {bool? validate})? setAddressCallback;
  @override
  _WithdrawerAddressState createState() => _WithdrawerAddressState();
}

class _WithdrawerAddressState extends State<WithdrawerAddress> {
  bool isScanQrFocused = false;
  ScannedContent scannedContent = ScannedContent();
  TextSelection? lastSelection;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    widget.styledTextController.setStyle(
      extendedTheme.monoLargeText!
          .copyWith(color: theme.textTheme.bodyMedium!.color),
      extendedTheme.monoLargeText!.copyWith(color: Colors.black),
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.buildInput(
              context: context,
              decoration: widget.decoration ??
                  InputDecoration(
                    hintStyle: extendedTheme.monoLargeText!
                        .copyWith(color: theme.textTheme.bodyMedium!.color),
                    hintText: localization.recipientAddress,
                    suffixIcon: Semantics(
                        label: localization.copyAddressLabel,
                        child: CopyButton(copyContent: 'copyContent')),
                    errorText: widget.errorText,
                  )),
        ]);
  }
}
