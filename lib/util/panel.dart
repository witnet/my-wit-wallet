import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/wallet_list.dart';
import 'package:my_wit_wallet/globals.dart' as globals;
import 'package:sliding_up_panel/sliding_up_panel.dart';

PanelController panelController = PanelController();

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
    if (panelController.isPanelClosed) {
      open(content: content);
    } else {
      close(content: content);
    }
  }

  PanelController getPanelController() {
    return panelController;
  }

  bool isAttached() {
    return panelController.isAttached;
  }

  bool isOpen() {
    return panelController.isPanelOpen;
  }

  bool isClose() {
    return panelController.isPanelClosed;
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
    if (isAttached() && panelController.isPanelOpen) {
      Widget defaultContent = WalletList();
      setContent(content ?? defaultContent);
      panelController.close();
    }
  }
}
