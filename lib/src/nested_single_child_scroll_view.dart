import 'package:flutter/widgets.dart';

import 'flutter/widgets/single_child_scroll_view.dart';
import 'overscroll_scrollable.dart';
import 'overscroll_state_provider.dart';

/// 可以直接继承自 [SingleChildScrollView]，但是为了 Flutter 版本更新后能比较版本改动内容，
/// 快速进行适配，所以继承自 [FlutterSingleChildScrollView]
class NestedSingleChildScrollView extends FlutterSingleChildScrollView {
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
    super.restorationId,
    super.keyboardDismissBehavior,
  });

  @override
  Widget build(BuildContext context) {
    final parent = super.build(context);
    final Widget child;
    if (parent is NotificationListener<ScrollUpdateNotification>) {
      child = NotificationListener<ScrollUpdateNotification>(
        onNotification: parent.onNotification,
        child: OverscrollScrollable.from(parent.child as Scrollable),
      );
    } else if (parent is PrimaryScrollController) {
      child = PrimaryScrollController.none(
        child: OverscrollScrollable.from(parent.child as Scrollable),
      );
    } else {
      child = OverscrollScrollable.from(parent as Scrollable);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // 如果当前组件与边界滚动事件的滚动方向一致
        if (scrollDirection == notification.metrics.axis) {
          // 根据滚动通知更新边界滚动状态
          OverscrollStateProvider.updateState(notification);
        }
        return false;
      },
      child: child,
    );
  }
}
