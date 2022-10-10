import 'package:flutter/widgets.dart';

/// 嵌套通知事件，用于判断是否有指定的父组件
class NestedScrollNotification<T> extends ScrollNotification {
  /// 期望的父组件类型
  final Type expectType;

  /// 判断有指定类型父组件后需要调用的回调
  final Function() callback;

  NestedScrollNotification({
    required super.metrics,
    required super.context,
    required this.expectType,
    required this.callback,
  });
}
