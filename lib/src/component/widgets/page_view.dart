part of 'package:nested_scroll_views/src/assembly/widgets/page_view.dart';

class NestedPageView extends PageView {
  NestedPageView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.physics,
    super.pageSnapping,
    super.onPageChanged,
    super.children,
    super.dragStartBehavior,
    super.allowImplicitScrolling,
    super.scrollCacheExtent,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
    super.scrollBehavior,
    super.padEnds,
    this.wantKeepAlive = true,
  });

  NestedPageView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.physics,
    super.pageSnapping,
    super.onPageChanged,
    required super.itemBuilder,
    super.findChildIndexCallback,
    super.itemCount,
    super.dragStartBehavior,
    super.allowImplicitScrolling,
    super.scrollCacheExtent,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
    super.scrollBehavior,
    super.padEnds,
    this.wantKeepAlive = true,
  }) : super.builder();

  NestedPageView.custom({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.physics,
    super.pageSnapping,
    super.onPageChanged,
    required super.childrenDelegate,
    super.dragStartBehavior,
    super.allowImplicitScrolling,
    super.scrollCacheExtent,
    super.restorationId,
    super.clipBehavior,
    super.hitTestBehavior,
    super.scrollBehavior,
    super.padEnds,
    this.wantKeepAlive = true,
  }) : super.custom();

  /// 是否缓存可滚动页面，不缓存可能导致页面在嵌套滚动时被销毁导致手势事件丢失
  final bool wantKeepAlive;

  @override
  State<PageView> createState() => _NestedPageViewState();
}

class _NestedPageViewState extends _PageViewState {
  /// 是否已将本次拖动交给更上层的分页
  bool _ignoreOverscroll = false;
  ScrollDragController? _dragController;

  /// 处理滚动事件通知
  bool _handleNotification(ScrollNotification notification) {
    // 不处理默认滚动事件
    if (notification.depth == 0) {
      return false;
    }

    // 获取可滚动组件当前位置信息
    final position = _controller.position;

    // 当前不允许滚动
    if (!position.physics.shouldAcceptUserOffset(position)) {
      return false;
    }

    // 如果当前组件与边界滚动事件的滚动方向不一致
    if (position.axis != notification.metrics.axis) {
      return false;
    }

    switch (notification) {
      case OverscrollNotification():
        return _handleOverscroll(notification, position);
      case ScrollEndNotification():
        // 保留松手速度；没有拖动数据时让原生机制复位页面
        if (notification.dragDetails case final details?) {
          _dragController?.end(details);
        } else {
          _dragController?.cancel();
        }
        _dragController?.dispose();
        _dragController = null;
        _ignoreOverscroll = false;
        return false;
      case NestedScrollNotification():
        if (runtimeType != notification.expectType) {
          return false;
        }
        notification.accepted = true;
        return true;
      default:
        return false;
    }
  }

  bool _handleOverscroll(OverscrollNotification notification, ScrollPosition position) {
    if (_ignoreOverscroll) {
      return false;
    }
    // 取消时只清空引用，不能再次 dispose，否则会递归调用
    // 不使用子层的 ScrollStartNotification 数据；Tab 切换可能产生多轮 Start / End
    _dragController ??= position.drag(DragStartDetails(), () => _dragController = null) as ScrollDragController;
    if (notification.dragDetails case final details?) {
      _dragController?.update(details);
    }
    if (position.hasPixels && position.atEdge) {
      final parentNotification = NestedScrollNotification(
        metrics: notification.metrics,
        context: notification.context,
        expectType: runtimeType,
      );
      parentNotification.dispatch(context);
      _ignoreOverscroll = parentNotification.accepted;
    }
    return true;
  }

  @override
  void dispose() {
    _dragController?.dispose();
    _dragController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationListener = super.build(context) as NotificationListener<ScrollNotification>;
    final scrollable = notificationListener.child as Scrollable;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => notificationListener.onNotification!(notification) || _handleNotification(notification),
      child: WrapperKeepAlive(wantKeepAlive: (widget as NestedPageView).wantKeepAlive, child: OverscrollScrollable.from(scrollable)),
    );
  }
}
