import 'dart:convert';

import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/path_provider_interface.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

class ExportSignMessage extends StatefulWidget {
  final ScrollController scrollController;
  final Map<String, dynamic> signedMessage;

  ExportSignMessage({
    Key? key,
    required this.scrollController,
    required this.signedMessage,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => ExportSignMessageState();
}

class ExportSignMessageState extends State<ExportSignMessage> {
  bool _showMessage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _exportJsonMessage() async {
    setState(() => isLoading = true);
    await PathProviderInterface().writeAndOpenJsonFile(
        JsonEncoder.withIndent('  ').convert(widget.signedMessage),
        "witnetSignature${DateTime.now().timestamp}.json");
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      DashedRect(
          color: Colors.grey,
          strokeWidth: 1.0,
          gap: 3.0,
          showEye: true,
          blur: !_showMessage,
          container: Container(child: JsonViewer(widget.signedMessage)),
          text: widget.signedMessage.toString(),
          updateBlur: () => {
                setState(() {
                  _showMessage = !_showMessage;
                })
              }),
      SizedBox(height: 16),
      PaddedButton(
        text: localization.exportJson,
        type: ButtonType.primary,
        isLoading: false,
        padding: EdgeInsets.zero,
        onPressed: () async {
          await _exportJsonMessage();
        },
      ),
      SizedBox(height: 8),
      PaddedButton(
        text: localization.copyJson,
        type: ButtonType.secondary,
        isLoading: false,
        padding: EdgeInsets.zero,
        onPressed: () async {
          await Clipboard.setData(
              ClipboardData(text: json.encode(widget.signedMessage)));
          if (await Clipboard.hasStrings()) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
                buildCopiedSnackbar(theme, localization.jsonCopied));
          }
        },
      ),
    ]);
  }
}
