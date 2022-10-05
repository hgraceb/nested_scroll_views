import 'package:flutter/widgets.dart';

import 'flutter/widgets/single_child_scroll_view.dart';
import 'overscroll_scrollable.dart';

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
    if (parent is NotificationListener<ScrollUpdateNotification>) {
      return NotificationListener<ScrollUpdateNotification>(
        onNotification: parent.onNotification,
        child: OverscrollScrollable.from(parent.child as Scrollable),
      );
    } else if (parent is PrimaryScrollController) {
      return PrimaryScrollController.none(
        child: OverscrollScrollable.from(parent.child as Scrollable),
      );
    } else {
      return OverscrollScrollable.from(parent as Scrollable);
    }
  }
}
