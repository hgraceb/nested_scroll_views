import 'package:flutter/widgets.dart';

/// 嵌套滚动通知，用于判断是否有同方向的 Scrollable 父组件
class NestedScrollableNotification extends ScrollNotification {
  NestedScrollableNotification({required super.metrics, required super.context});

  /// 是否已由指定类型的父组件确认
  bool accepted = false;
}

/// 嵌套分页通知，用于判断是否有同方向且允许滚动的 PageView 父组件
class NestedPageViewNotification extends ScrollNotification {
  NestedPageViewNotification({required super.metrics, required super.context});

  /// 是否已由指定类型的父组件确认
  bool accepted = false;
}
