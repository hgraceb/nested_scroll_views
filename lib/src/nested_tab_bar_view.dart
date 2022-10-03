import 'package:flutter/material.dart';

import 'flutter/material/tabs.dart';
import 'flutter/widgets/page_view.dart';
import 'nested_page_view.dart';

class NestedTabBarView extends FlutterTabBarView {
  const NestedTabBarView({
    super.key,
    required super.children,
    super.controller,
    super.physics,
    super.dragStartBehavior,
    super.viewportFraction,
    super.clipBehavior,
  });

  @override
  State<FlutterTabBarView> createState() => _NestedTabBarViewState();
}

class _NestedTabBarViewState extends FlutterTabBarViewState {
  @override
  Widget build(BuildContext context) {
    final notificationListener =
        super.build(context) as NotificationListener<ScrollNotification>;
    final flutterPageView = notificationListener.child as FlutterPageView;
    return NotificationListener<ScrollNotification>(
      onNotification: notificationListener.onNotification,
      child: NestedPageView.custom(
        dragStartBehavior: flutterPageView.dragStartBehavior,
        clipBehavior: flutterPageView.clipBehavior,
        controller: flutterPageView.controller,
        physics: flutterPageView.physics,
        childrenDelegate: flutterPageView.childrenDelegate,
      ),
    );
  }
}
