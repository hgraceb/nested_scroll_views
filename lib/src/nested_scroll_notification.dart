import 'package:flutter/widgets.dart';

/// 嵌套滚动通知，用于判断是否有同方向的 OverscrollScrollable 父组件
class NestedScrollableNotification extends ScrollNotification {
  NestedScrollableNotification({required super.metrics, required super.context});

  /// 是否已找到符合条件的父组件
  bool accepted = false;
}

/// 嵌套分页通知，用于判断是否有同方向且允许滚动的 NestedPageView 父组件
class NestedPageViewNotification extends ScrollNotification {
  NestedPageViewNotification({required super.metrics, required super.context});

  /// 是否已找到符合条件的父组件
  bool accepted = false;
}
