part of 'package:nested_scroll_views/src/assembly/widgets/page_view.dart';

class NestedPageView extends PageView {
  /// 是否缓存可滚动页面，不缓存可能导致页面在嵌套滚动时被销毁导致手势事件丢失
  final bool wantKeepAlive;

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
    super.restorationId,
    super.clipBehavior,
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
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    super.dragStartBehavior,
    super.allowImplicitScrolling,
    super.restorationId,
    super.clipBehavior,
    super.scrollBehavior,
    super.padEnds,
    this.wantKeepAlive = true,
  }) : super.builder(
          itemBuilder: itemBuilder,
          findChildIndexCallback: findChildIndexCallback,
          itemCount: itemCount,
        );

  NestedPageView.custom({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.physics,
    super.pageSnapping,
    super.onPageChanged,
    required SliverChildDelegate childrenDelegate,
    super.dragStartBehavior,
    super.allowImplicitScrolling,
    super.restorationId,
    super.clipBehavior,
    super.scrollBehavior,
    super.padEnds,
    this.wantKeepAlive = true,
  }) : super.custom(childrenDelegate: childrenDelegate);

  @override
  State<PageView> createState() => _NestedPageViewState();
}

class _NestedPageViewState extends _PageViewState {
  bool? _ignoreOverscroll;
  ScrollDragController? _dragController;

  /// 处理滚动事件通知
  bool _handleNotification(
    BuildContext context,
    ScrollNotification notification,
  ) {
    // 不处理默认滚动事件
    if (notification.depth == 0) {
      return false;
    }

    // 获取可滚动组件当前位置信息
    final position = (widget as NestedPageView).controller.position;

    // 当前不允许滚动
    if (!position.physics.shouldAcceptUserOffset(position)) {
      return false;
    }

    // 如果当前组件与边界滚动事件的滚动方向不一致
    if (position.axis != notification.metrics.axis) {
      return false;
    }

    // 处理边界滚动事件
    if (notification is OverscrollNotification) {
      // 如果被父组件通知需要忽略边界滚动事件
      if (_ignoreOverscroll == true) {
        return false;
      }
      // 拖动被取消的回调，不需要调用 dispose 方法，不然会死循环
      void dragCancelCallback() => _dragController = null;
      // 滚动位置超出可滚动范围，自定义拖动事件控制器并保存，不要使用 ScrollStartNotification 携带的 DragStartDetails 数据作为参数
      // 如从可滚动 TabBar 的第三项开始滚动到第一项并结束滚动，依次接收到的滚动事件的序列可能如下： Start, End, Start, End
      _dragController ??= position.drag(DragStartDetails(), dragCancelCallback)
          as ScrollDragController;
      // 如果存在滚动数据
      if (notification.dragDetails != null) {
        // 开始处理拖动事件
        _dragController?.update(notification.dragDetails!);
      }
      // 判断当前组件位置是否已到达边界
      if (position.hasPixels && position.atEdge) {
        // 处理多层嵌套，到达边界后发送通知，如果还有父组件则将后续边界滚动事件全部移交给父组件
        NestedScrollNotification(
          metrics: notification.metrics,
          context: notification.context,
          expectType: runtimeType,
          callback: () => _ignoreOverscroll = true,
        ).dispatch(context);
      }
      // 消耗滚动事件
      return true;
    }

    // 处理滚动结束事件
    if (notification is ScrollEndNotification) {
      if (notification.dragDetails != null) {
        // 滚动结束时还有额外的滚动数据，需要继续处理，如：子组件快速滑动切换到父组件
        _dragController?.end(notification.dragDetails!);
      } else {
        // 滚动结束时没有额外的滚动数据，直接复位页面位置
        _dragController?.cancel();
      }
      // 清理页面拖动数据
      _dragController?.dispose();
      _dragController = _ignoreOverscroll = null;
      return false;
    }

    // 处理嵌套滚动事件
    if (notification is NestedScrollNotification) {
      if (runtimeType == notification.expectType) {
        // 通知子组件忽略边界滚动事件
        notification.callback();
        // 消耗嵌套通知事件
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _dragController?.dispose();
    _dragController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationListener =
        super.build(context) as NotificationListener<ScrollNotification>;
    final scrollable = notificationListener.child as Scrollable;
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        return notificationListener.onNotification!(notification) ||
            _handleNotification(context, notification);
      },
      child: WrapperKeepAlive(
        child: OverscrollScrollable.from(scrollable),
        wantKeepAlive: (widget as NestedPageView).wantKeepAlive,
      ),
    );
  }
}
