import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/widgets/wallet_list.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

class Panel {
  Widget panelContent = WalletList();

  void setContent(Widget content) {
    panelContent = content;
  }

  Widget getContent() {
    print('panel content ${panelContent.runtimeType}');
    return panelContent;
  }

  void toggle(Widget content) {
    if (panelContent.runtimeType != content.runtimeType) {
      close(content: content);
      open(content: content);
      return;
    }
    if (panelController.isPanelClosed) {
      open(content: content);
    } else {
      close(content: content);
    }
  }

  void open({required Widget content}) {
    // FocusScope.of(context).unfocus();
    setContent(content);
    panelController.open();
    globals.isPanelClose = false;
  }

  void setCloseState() {
    globals.isPanelClose = true;
  }

  void close({Widget? content}) {
    if (panelController.isPanelOpen) {
      Widget defaultContent = WalletList();
      setContent(content ?? defaultContent);
      panelController.close();
    }
  }
}
