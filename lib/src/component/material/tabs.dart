part of 'package:nested_scroll_views/src/assembly/material/tabs.dart';

class NestedTabBarView extends TabBarView {
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

  /// 是否缓存可滚动页面，不缓存可能导致页面在嵌套滚动时被销毁导致手势事件丢失
  final bool wantKeepAlive;

  @override
  State<TabBarView> createState() => _NestedTabBarViewState();
}

class _NestedTabBarViewState extends _TabBarViewState {
  @override
  void _updateChildren() {
    // Assign stable keys before adding semantics so reordered panels retain state.
    _childrenWithKey = [
      for (final child in KeyedSubtree.ensureUniqueKeysForList(widget.children)) ...[
        Semantics(key: child.key, role: SemanticsRole.tabPanel, child: child),
      ],
    ];
  }

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
