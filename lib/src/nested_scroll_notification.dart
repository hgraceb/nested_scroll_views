import 'package:flutter/widgets.dart';

/// 嵌套通知事件，用于判断是否有指定的父组件
class NestedScrollNotification extends ScrollNotification {
  NestedScrollNotification({required super.metrics, required super.context, required this.expectType});

  /// 期望的父组件类型
  final Type expectType;

  /// 是否已由指定类型的父组件确认
  bool accepted = false;
}
