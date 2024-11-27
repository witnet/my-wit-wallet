import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';

import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/scanned_content.dart';
import 'input_text.dart';

class InputXprv extends InputText {
  InputXprv({
    required super.focusNode,
    required super.styledTextController,
    super.prefixIcon,
    super.errorText,
    super.validator,
    super.hint,
    super.keyboardType,
    super.obscureText = false,
    required this.route,
    super.onChanged,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onTapOutside,
    super.onTap,
    super.onSuffixTap,
    super.maxLines = 3,
    this.setXprvCallback,
    super.decoration,
  });

  @override
  _InputXprvState createState() => _InputXprvState();
  final String route;
  final void Function(String)? setXprvCallback;
}

class _InputXprvState extends State<InputXprv> {
  FocusNode _scanQrFocusNode = FocusNode();
  bool isScanQrFocused = false;
  ScannedContent scannedContent = ScannedContent();
  @override
  void initState() {
    super.initState();
    if (scannedContent.scannedXprv != null) {
      _handleQrAddressResults(scannedContent.scannedXprv!);
    }
    widget.focusNode.addListener(widget.onFocusChange);
    _scanQrFocusNode.addListener(_handleQrFocus);
  }

  _handleQrAddressResults(String value) {
    widget.styledTextController.text = value;
    widget.setXprvCallback!(value);
  }

  _handleQrFocus() {
    setState(() {
      isScanQrFocused = _scanQrFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(widget.onFocusChange);
    _scanQrFocusNode.removeListener(_handleQrFocus);
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
                  hintStyle: extendedTheme.monoMediumText!
                      .copyWith(color: theme.textTheme.bodyMedium!.color),
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
                              {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => QrScanner(
                                          currentRoute: widget.route,
                                          onChanged: (_value) => {},
                                          type: ScannedType.xprv,
                                        )))
                              },
                            },
                          ))
                      : null,
                  errorText: widget.errorText,
                ),
          ),
        ]);
  }
}
