import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/wallet_list.dart';
import 'package:my_wit_wallet/globals.dart' as globals;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelUtils {
  Widget panelContent = WalletList();

  void setContent(Widget content) {
    panelContent = content;
  }

  Widget getContent() {
    return panelContent;
  }

  void toggle(Widget content) {
    if (panelContent.runtimeType != content.runtimeType) {
      close(content: content);
      open(content: content);
      return;
    }
    if (globals.panelController.isPanelClosed) {
      open(content: content);
    } else {
      close(content: content);
    }
  }

  PanelController getPanelController() {
    return globals.panelController;
  }

  bool isAttached() {
    return globals.panelController.isAttached;
  }

  bool isOpen() {
    return globals.panelController.isPanelOpen;
  }

  bool isClose() {
    return globals.panelController.isPanelClosed;
  }

  void open({required Widget content}) {
    setContent(content);
    globals.panelController.open();
    globals.isPanelClose = false;
  }

  void setCloseState() {
    globals.isPanelClose = true;
  }

  void close({Widget? content}) {
    if (isAttached() && globals.panelController.isPanelOpen) {
      Widget defaultContent = WalletList();
      setContent(content ?? defaultContent);
      globals.panelController.close();
    }
  }
}
