part of 'package:nested_scroll_views/src/assembly/widgets/single_child_scroll_view.dart';

class NestedSingleChildScrollView extends SingleChildScrollView {
  const NestedSingleChildScrollView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.padding,
    super.primary,
    super.physics,
    super.controller,
    super.child,
    super.dragStartBehavior,
    super.clipBehavior,
    super.hitTestBehavior,
    super.restorationId,
    super.keyboardDismissBehavior,
    this.wantKeepAlive = true,
  });

  /// 是否缓存可滚动页面，不缓存可能导致页面在嵌套滚动时被销毁导致手势事件丢失
  final bool wantKeepAlive;

  @override
  Widget build(BuildContext context) =>
      WrapperKeepAlive(wantKeepAlive: wantKeepAlive, child: OverscrollScrollable.replace(super.build(context)));
}
