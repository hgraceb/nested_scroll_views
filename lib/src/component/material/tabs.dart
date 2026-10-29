part of 'package:nested_scroll_views/src/assembly/material/tabs.dart';

class NestedTabBarView extends TabBarView {
  /// 是否缓存可滚动页面，不缓存可能导致页面在嵌套滚动时被销毁导致手势事件丢失
  final bool wantKeepAlive;

  const NestedTabBarView({
    super.key,
    required super.children,
    super.controller,
    super.physics,
    super.dragStartBehavior,
    super.viewportFraction,
    super.clipBehavior,
    this.wantKeepAlive = true,
  });

  @override
  State<TabBarView> createState() => _NestedTabBarViewState();
}

class _NestedTabBarViewState extends _TabBarViewState {
  @override
  Widget build(BuildContext context) {
    final notificationListener = super.build(context) as NotificationListener<ScrollNotification>;
    final flutterPageView = notificationListener.child as PageView;
    return NotificationListener<ScrollNotification>(
      onNotification: notificationListener.onNotification,
      child: NestedPageView.custom(
        dragStartBehavior: flutterPageView.dragStartBehavior,
        clipBehavior: flutterPageView.clipBehavior,
        controller: flutterPageView.controller,
        physics: flutterPageView.physics,
        childrenDelegate: flutterPageView.childrenDelegate,
        wantKeepAlive: (widget as NestedTabBarView).wantKeepAlive,
      ),
    );
  }
}
