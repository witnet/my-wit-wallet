import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/inputs/input_text.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/qr_scanner.dart';

import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/scanned_content.dart';

class InputAddress extends InputText {
  InputAddress({
    required super.focusNode,
    required super.styledTextController,
    super.prefixIcon,
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
  _InputAddressState createState() => _InputAddressState();
}

class _InputAddressState extends State<InputAddress> {
  FocusNode _scanQrFocusNode = FocusNode();
  bool isScanQrFocused = false;
  ScannedContent scannedContent = ScannedContent();
  TextSelection? lastSelection;

  @override
  void initState() {
    super.initState();
    if (scannedContent.scannedContent != null) {
      _handleQrAddressResults(scannedContent.scannedContent!);
    }
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

  _handleQrAddressResults(String value) {
    widget.styledTextController.text = value;
    widget.setAddressCallback!(value);
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
                    hintStyle: extendedTheme.monoLargeText!.copyWith(
                        color: theme.inputDecorationTheme.hintStyle!.color),
                    hintText: localization.recipientAddress,
                    suffixIcon: !Platform.isWindows && !Platform.isLinux
                        ? Semantics(
                            label: localization.scanQrCodeLabel,
                            child: SuffixIcon(
                                onPressed: () => {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => QrScanner(
                                                  currentRoute: widget.route!,
                                                  onChanged: (_value) => {})))
                                    },
                                icon: FontAwesomeIcons.qrcode,
                                isFocus: isScanQrFocused,
                                focusNode: _scanQrFocusNode))
                        : null,
                    errorText: widget.errorText,
                  )),
        ]);
  }
}
