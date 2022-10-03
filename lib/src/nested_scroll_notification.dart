import 'package:flutter/widgets.dart';

/// 嵌套回调滚动事件通知，由子嵌套组件发送，父嵌套组件通过调用不同回调以控制子嵌套组件的具体处理逻辑
class NestedCallbackNotification extends ScrollNotification {
  /// 是否忽略边界滚动事件的回调
  final Function(bool ignoreOverscroll) ignoreOverscroll;

  NestedCallbackNotification({
    required super.metrics,
    required super.context,
    required this.ignoreOverscroll,
  });
}
