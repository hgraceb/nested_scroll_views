part of 'package:nested_scroll_views/src/assembly/widgets/scrollable.dart';

class OverscrollScrollable extends Scrollable {
  /// 将 Scrollable 转换为 OverscrollScrollable
  OverscrollScrollable.from(Scrollable scrollable)
    : super(
        key: scrollable.key,
        axisDirection: scrollable.axisDirection,
        controller: scrollable.controller,
        physics: scrollable.physics,
        viewportBuilder: scrollable.viewportBuilder,
        incrementCalculator: scrollable.incrementCalculator,
        excludeFromSemantics: scrollable.excludeFromSemantics,
        semanticChildCount: scrollable.semanticChildCount,
        dragStartBehavior: scrollable.dragStartBehavior,
        restorationId: scrollable.restorationId,
        scrollBehavior: scrollable.scrollBehavior,
        clipBehavior: scrollable.clipBehavior,
        hitTestBehavior: scrollable.hitTestBehavior,
      );

  /// 沿 ScrollView 和 SingleChildScrollView 的已知包装层替换 Scrollable
  static Widget replace(Widget widget) {
    if (widget is NotificationListener<ScrollUpdateNotification>) {
      return NotificationListener<ScrollUpdateNotification>(
        key: widget.key,
        onNotification: widget.onNotification,
        child: replace(widget.child),
      );
    }
    if (widget is PrimaryScrollController) {
      return PrimaryScrollController.none(key: widget.key, child: replace(widget.child));
    }
    return OverscrollScrollable.from(widget as Scrollable);
  }

  @override
  ScrollableState createState() => _OverscrollScrollableState();
}

class _OverscrollScrollableState extends ScrollableState {
  /// 是否已经滚动到边界
  bool _overscroll = false;

  /// 代理手势更新事件
  GestureDragUpdateCallback? _proxyOnUpdate(GestureDragUpdateCallback? parent) {
    // 如果已经滚动到了边界则不再响应移动事件
    return _overscroll ? null : parent;
  }

  /// 处理手势移动事件
  void _onMoveEvent(PointerMoveEvent event, Offset delta, double primaryDelta) {
    // 如果已经滚动到边界并且又继续移动
    if (_overscroll && primaryDelta != 0.0) _tryDispatchResumeNotification(primaryDelta);
    if (_overscroll && primaryDelta != 0.0) _dispatchOverscrollNotification(event, delta, primaryDelta);
  }

  /// 通知反向恢复事件
  void _tryDispatchResumeNotification(double primaryDelta) {
    final scrollDelta = axisDirectionIsReversed(axisDirection) ? primaryDelta : -primaryDelta;
    final canScroll = (scrollDelta < 0.0 && position.extentBefore > 0.0) || (scrollDelta > 0.0 && position.extentAfter > 0.0);
    if (canScroll) {
      final notification = NestedScrollResumeNotification(metrics: position.copyWith(), context: context);
      notification.dispatch(context);
      if (notification.accepted) _overscroll = false;
    }
  }

  /// 通知边界滚动事件
  void _dispatchOverscrollNotification(PointerMoveEvent event, Offset delta, double primaryDelta) {
    final dragDetails = DragUpdateDetails(
      sourceTimeStamp: event.timeStamp,
      delta: delta,
      primaryDelta: primaryDelta,
      globalPosition: event.position,
      localPosition: event.localPosition,
    );
    final notification = OverscrollNotification(
      metrics: position.copyWith(),
      context: context,
      overscroll: primaryDelta,
      dragDetails: dragDetails,
    );
    notification.dispatch(context);
  }

  @override
  set _gestureRecognizers(value) {
    super._gestureRecognizers = value.map((key, value) {
      if (key == VerticalDragGestureRecognizer) {
        return MapEntry(
          OverscrollVerticalDragGestureRecognizer,
          GestureRecognizerFactoryWithHandlers<OverscrollVerticalDragGestureRecognizer>(
            () => OverscrollVerticalDragGestureRecognizer(proxyOnUpdate: _proxyOnUpdate, onPointerMoveEvent: _onMoveEvent),
            (instance) => value.initializer(instance),
          ),
        );
      } else if (key == HorizontalDragGestureRecognizer) {
        return MapEntry(
          OverscrollHorizontalDragGestureRecognizer,
          GestureRecognizerFactoryWithHandlers<OverscrollHorizontalDragGestureRecognizer>(
            () => OverscrollHorizontalDragGestureRecognizer(proxyOnUpdate: _proxyOnUpdate, onPointerMoveEvent: _onMoveEvent),
            (instance) => value.initializer(instance),
          ),
        );
      }
      return MapEntry(key, value);
    });
  }

  /// 处理滚动事件
  bool _handleNotification(ScrollNotification notification) {
    // 如果当前组件与边界滚动事件的滚动方向不一致
    if (axisDirectionToAxis(axisDirection) != notification.metrics.axis) return false;

    if (notification.depth == 0) {
      // 当边界滚动事件的深度只有一层时，等查询有指定类型的父组件后再进一步处理滚动事件，避免当前组件作为最外层组件时无法正常滚动
      final parentNotification = NestedScrollableNotification(metrics: notification.metrics, context: notification.context);
      parentNotification.dispatch(context);
      if (parentNotification.accepted != true) return false;
    } else if (notification is NestedScrollableNotification) {
      // 确认存在符合条件的父组件
      notification.accepted = true;
      // 消耗嵌套通知事件
      return true;
    }

    if (notification is OverscrollNotification) {
      // 设置边界滚动状态
      _overscroll = true;
    } else if (notification is ScrollEndNotification) {
      // 重置边界滚动状态
      _overscroll = false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(onNotification: _handleNotification, child: super.build(context));
  }
}
