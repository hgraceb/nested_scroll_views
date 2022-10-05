import 'package:flutter/widgets.dart';

import 'flutter/widgets/single_child_scroll_view.dart';
import 'overscroll_scrollable.dart';

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
    final widget = super.build(context);
    if (widget is NotificationListener<ScrollUpdateNotification>) {
      return NotificationListener<ScrollUpdateNotification>(
        onNotification: widget.onNotification,
        child: OverscrollScrollable.from(widget.child as Scrollable),
      );
    }
    if (widget is PrimaryScrollController) {
      return PrimaryScrollController.none(
        child: OverscrollScrollable.from(widget.child as Scrollable),
      );
    }
    return OverscrollScrollable.from(widget as Scrollable);
  }
}
