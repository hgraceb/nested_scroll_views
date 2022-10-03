import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'flutter/widgets/scrollable.dart';
import 'overscroll_gestures.dart';
import 'overscroll_state_provider.dart';

class OverscrollScrollable extends FlutterScrollable {
  const OverscrollScrollable({
    super.key,
    super.axisDirection,
    super.controller,
    super.physics,
    required super.viewportBuilder,
    super.incrementCalculator,
    super.excludeFromSemantics,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.restorationId,
    super.scrollBehavior,
    super.clipBehavior,
  });

  static FlutterScrollIncrementCalculator? _getFlutterScrollIncrementCalculator(
    Scrollable scrollable,
  ) {
    final incrementCalculator = scrollable.incrementCalculator;
    if (incrementCalculator == null) {
      return null;
    }
    return (details) {
      return incrementCalculator(
        ScrollIncrementDetails(
          metrics: details.metrics,
          type: ScrollIncrementType.values[details.type.index],
        ),
      );
    };
  }

  /// 将 Scrollable 转换为 OverscrollScrollable
  OverscrollScrollable.from(Scrollable scrollable)
      : super(
          key: scrollable.key,
          axisDirection: scrollable.axisDirection,
          controller: scrollable.controller,
          physics: scrollable.physics,
          viewportBuilder: scrollable.viewportBuilder,
          incrementCalculator: _getFlutterScrollIncrementCalculator(scrollable),
          excludeFromSemantics: scrollable.excludeFromSemantics,
          semanticChildCount: scrollable.semanticChildCount,
          dragStartBehavior: scrollable.dragStartBehavior,
          restorationId: scrollable.restorationId,
          scrollBehavior: scrollable.scrollBehavior,
          clipBehavior: scrollable.clipBehavior,
        );

  @override
  FlutterScrollableState createState() => _OverscrollScrollableState();
}

class _OverscrollScrollableState extends FlutterScrollableState {
  bool _overscroll = false;
  late OverscrollChangeNotifier _overscrollNotifier;

  void _overScroll() => _overscroll = _overscrollNotifier.state;

  @override
  void didChangeDependencies() {
    _overscrollNotifier = OverscrollStateProvider.of(context)
      // 移除旧的监听器，避免重复添加
      ..removeListener(_overScroll)
      // 添加新的监听器，
      ..addListener(_overScroll);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // 只需要移除监听器，资源回收由 Provider 处理，避免资源重复回收
    _overscrollNotifier.removeListener(_overScroll);
    super.dispose();
  }

  /// 代理手势更新事件
  GestureDragUpdateCallback? _proxyOnUpdate(GestureDragUpdateCallback? parent) {
    // 如果已经滚动到了边界则不再响应移动事件
    return _overscroll ? null : parent;
  }

  /// 处理手势移动事件
  _onMoveEvent(PointerMoveEvent event, Offset delta, double primaryDelta) {
    // 如果还没滚动到边界或者没有实际移动距离
    if (!_overscroll || primaryDelta == 0.0) {
      return;
    }
    // 边界滚动事件通知
    OverscrollNotification(
      metrics: position.copyWith(),
      context: context,
      overscroll: primaryDelta,
      dragDetails: DragUpdateDetails(
        sourceTimeStamp: event.timeStamp,
        delta: delta,
        primaryDelta: primaryDelta,
        globalPosition: event.position,
        localPosition: event.localPosition,
      ),
    ).dispatch(context);
  }

  @override
  set gestureRecognizers(value) {
    super.gestureRecognizers = value.map((key, value) {
      if (key == VerticalDragGestureRecognizer) {
        return MapEntry(
          OverscrollVerticalDragGestureRecognizer,
          GestureRecognizerFactoryWithHandlers<
              OverscrollVerticalDragGestureRecognizer>(
            () => OverscrollVerticalDragGestureRecognizer(
              supportedDevices: configuration.dragDevices,
              proxyOnUpdate: _proxyOnUpdate,
              onPointerMoveEvent: _onMoveEvent,
            ),
            (instance) => value.initializer(instance),
          ),
        );
      } else if (key == HorizontalDragGestureRecognizer) {
        return MapEntry(
          OverscrollHorizontalDragGestureRecognizer,
          GestureRecognizerFactoryWithHandlers<
              OverscrollHorizontalDragGestureRecognizer>(
            () => OverscrollHorizontalDragGestureRecognizer(
              supportedDevices: configuration.dragDevices,
              proxyOnUpdate: _proxyOnUpdate,
              onPointerMoveEvent: _onMoveEvent,
            ),
            (instance) => value.initializer(instance),
          ),
        );
      }
      return MapEntry(key, value);
    });
  }
}
