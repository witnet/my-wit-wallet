import 'package:flutter/material.dart';
import 'package:my_wit_wallet/globals.dart' as globals;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelUtils {
  Widget panelContent = Text('');
  double contentHeight = 0;
  final PanelController panelController = PanelController();

  void setContent(Widget content) {
    panelContent = content;
  }

  Widget getContent() {
    return panelContent;
  }

  void setHeight(double height) {
    contentHeight = height;
  }

  double getHeight() {
    return contentHeight;
  }

  Future<void> toggle() async {
    if (panelController.isPanelClosed) {
      await open();
    } else {
      await close();
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

  Future<void> open() async {
    globals.isPanelClose = false;
    await panelController.open();
  }

  void setCloseState() {
    globals.isPanelClose = true;
  }

  Future<void> close() async {
    if (isAttached() && panelController.isPanelOpen) {
      Widget defaultContent = Text('');
      setContent(defaultContent);
      await panelController.close();
    }
  }
}
