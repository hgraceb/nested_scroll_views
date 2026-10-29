import 'package:flutter/gestures.dart';

typedef ProxyOnUpdate = GestureDragUpdateCallback? Function(
  GestureDragUpdateCallback? parent,
);
typedef OnPointerMoveEvent = Function(
  PointerMoveEvent event,
  Offset delta,
  double primaryDelta,
);

class OverscrollVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer {
  OverscrollVerticalDragGestureRecognizer({
    required this.proxyOnUpdate,
    required this.onPointerMoveEvent,
  });

  final ProxyOnUpdate proxyOnUpdate;
  final OnPointerMoveEvent onPointerMoveEvent;

  @override
  GestureDragUpdateCallback? get onUpdate => proxyOnUpdate(super.onUpdate);

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      // 如果是 PointerMoveEvent 则取 localDelta 作为 Offset 进行计算
      onPointerMoveEvent(
        event,
        Offset(0.0, event.localDelta.dy),
        event.localDelta.dy,
      );
    }
    super.handleEvent(event);
  }
}

class OverscrollHorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  OverscrollHorizontalDragGestureRecognizer({
    required this.proxyOnUpdate,
    required this.onPointerMoveEvent,
  });

  final ProxyOnUpdate proxyOnUpdate;
  final OnPointerMoveEvent onPointerMoveEvent;

  @override
  GestureDragUpdateCallback? get onUpdate => proxyOnUpdate(super.onUpdate);

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      // 如果是 PointerMoveEvent 则取 localDelta 作为 Offset 进行计算
      onPointerMoveEvent(
        event,
        Offset(event.localDelta.dx, 0.0),
        event.localDelta.dx,
      );
    }
    super.handleEvent(event);
  }
}
