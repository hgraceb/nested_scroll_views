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
  bool _ignoreOverscroll = false;
  double? _dragStartPixels;
  ScrollDragController? _dragController;

  /// 处理拖动取消事件
  void _handleDragCancel() {
    _dragController = null;
    _dragStartPixels = null;
  }

  /// 处理滚动事件通知
  bool _handleNotification(ScrollNotification notification) {
    // 不处理默认滚动事件
    if (notification.depth == 0) return false;
    // 获取可滚动组件当前位置信息
    final position = _controller.position;
    // 如果当前不允许滚动
    if (!position.physics.shouldAcceptUserOffset(position)) return false;
    // 如果当前组件与边界滚动事件的滚动方向不一致
    if (position.axis != notification.metrics.axis) return false;
    // 处理边界滚动事件
    if (notification is OverscrollNotification) return _handleOverscroll(notification, position);
    // 处理滚动结束事件
    if (notification is ScrollEndNotification) return _handleScrollEnd(notification);
    // 处理嵌套滚动事件
    if (notification is NestedPageViewNotification) return _handleNestedPageView(notification);
    // 处理反向恢复事件
    if (notification is NestedScrollResumeNotification) return _handleScrollResume(notification, position);
    // 忽略其他滚动事件
    return false;
  }

  /// 处理边界滚动事件
  bool _handleOverscroll(OverscrollNotification notification, ScrollPosition position) {
    // 如果被父组件通知需要忽略边界滚动事件
    if (_ignoreOverscroll) return false;
    // 子组件越界时再创建并保存当前页面的拖动控制器，避免在 Start 时创建的控制器被 TabBar 跟随滚动产生的 End 通知提前清理
    if (_dragController == null) {
      _dragStartPixels = position.pixels;
      _dragController = position.drag(DragStartDetails(kind: notification.dragDetails?.kind), _handleDragCancel) as ScrollDragController;
    }
    // 如果存在滚动数据则开始处理拖动事件
    if (notification.dragDetails != null) _dragController?.update(notification.dragDetails!);
    // 判断当前组件位置是否已到达边界
    if (position.hasPixels && position.atEdge) {
      // 处理多层嵌套，到达边界后发送通知，如果还有父组件则将后续边界滚动事件全部移交给父组件
      final parentNotification = NestedPageViewNotification(metrics: notification.metrics, context: notification.context);
      parentNotification.dispatch(context);
      _ignoreOverscroll = parentNotification.accepted;
    }
    // 消耗滚动事件
    return true;
  }

  /// 处理滚动结束事件
  bool _handleScrollEnd(ScrollEndNotification notification) {
    if (notification.dragDetails != null) {
      // 滚动结束时还有额外的滚动数据，需要继续处理，如：子组件快速滑动切换到父组件
      _dragController?.end(notification.dragDetails!);
    } else {
      // 滚动结束时没有额外的滚动数据，直接复位页面位置
      _dragController?.cancel();
    }
    // 清理页面拖动数据
    _dragController?.dispose();
    _dragController = null;
    _ignoreOverscroll = false;
    return false;
  }

  /// 处理嵌套滚动事件
  bool _handleNestedPageView(NestedPageViewNotification notification) {
    // 确认存在符合条件的父组件
    notification.accepted = true;
    // 消耗嵌套通知事件
    return true;
  }

  /// 处理反向恢复事件
  bool _handleScrollResume(NestedScrollResumeNotification notification, ScrollPosition position) {
    // 已经移交给更外层或已经移动时，保留现有交接行为
    if (_ignoreOverscroll || _dragController == null || position.pixels != _dragStartPixels) return true;
    _dragController?.cancel();
    notification.accepted = true;
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
