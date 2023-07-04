import 'package:flutter/gestures.dart';

class FourthButtonTapGestureRecognizer extends BaseTapGestureRecognizer {
  GestureTapDownCallback? onTapDown;
  @override
  void handleTapCancel(
      {required PointerDownEvent down,
      PointerCancelEvent? cancel,
      required String reason}) {
    // TODO: implement handleTapCancel
  }
  @override
  void handleTapDown({required PointerDownEvent down}) {
    final TapDownDetails details = TapDownDetails(
      globalPosition: down.position,
      localPosition: down.localPosition,
      kind: getKindForPointer(down.pointer),
    );
    switch (down.buttons) {
      case 8:
        if (onTapDown != null) {
          invokeCallback<void>('onTapDown', () => onTapDown!(details));
        }
        break;
      default:
    }
  }

  @override
  void handleTapUp(
      {required PointerDownEvent down, required PointerUpEvent up}) {
    // TODO: implement handleTapUp
  }
}
