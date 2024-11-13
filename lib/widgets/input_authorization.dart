import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';

import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'input_text.dart';

class InputAuthorization extends InputText {
  InputAuthorization({
    required FocusNode focusNode,
    required StyledTextController styledTextController,
    IconData? prefixIcon,
    String? errorText,
    String? Function(String?)? validator,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    required this.route,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
    void Function(String)? onFieldSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    void Function()? onSuffixTap,
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
          maxLines: 3,
        );

  @override
  _InputAuthorizationState createState() => _InputAuthorizationState();
  final String route;
}

class _InputAuthorizationState extends State<InputAuthorization> {
  FocusNode _scanQrFocusNode = FocusNode();
  bool isScanQrFocused = false;
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(widget.onFocusChange);
    _scanQrFocusNode.addListener(_handleQrFocus);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(widget.onFocusChange);
    _scanQrFocusNode.removeListener(_handleQrFocus);
  }

  _handleQrFocus() {
    setState(() {
      isScanQrFocused = _scanQrFocusNode.hasFocus;
    });
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    widget.styledTextController.setStyle(
      extendedTheme.monoMediumText!,
      extendedTheme.monoMediumText!.copyWith(color: Colors.black),
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.buildInput(
            context: context,
            decoration: widget.decoration ??
                InputDecoration(
                  hintStyle: extendedTheme.monoMediumText!.copyWith(
                      color: extendedTheme.monoMediumText!.color!
                          .withOpacity(0.5)),
                  hintText: localization.authorizationInputHint,
                  contentPadding: EdgeInsets.all(16),
                  suffixIcon: !Platform.isWindows && !Platform.isLinux
                      ? Semantics(
                          label: localization.scanQrCodeLabel,
                          child: SuffixIcon(
                            focusNode: _scanQrFocusNode,
                            isFocus: isScanQrFocused,
                            icon: FontAwesomeIcons.qrcode,
                            onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QrScanner(
                                          currentRoute: widget.route,
                                          onChanged: (_value) => {})))
                            },
                          ))
                      : null,
                  errorText: widget.errorText,
                ),
          ),
        ]);
  }
}
