import 'package:flutter/widgets.dart';

/// 向祖先查询是否有符合条件的嵌套滚动接收端
class NestedScrollNotification extends ScrollNotification {
  NestedScrollNotification({required super.metrics, required super.context, required this.expectType});

  /// 期望的父组件类型
  final Type expectType;

  /// 由符合条件的祖先确认，发送方在 dispatch 返回后读取
  bool accepted = false;
}
