import 'package:flutter/widgets.dart';

/// 嵌套滚动通知，用于判断是否有同方向的 OverscrollScrollable 父组件
class NestedScrollableNotification extends ScrollNotification {
  NestedScrollableNotification.dispatch({required super.metrics, required super.context}) {
    dispatch(context);
  }

  /// 是否已找到符合条件的父组件
  bool accepted = false;
}

/// 嵌套分页通知，用于判断是否有同方向且允许滚动的 NestedPageView 父组件
class NestedPageViewNotification extends ScrollNotification {
  NestedPageViewNotification.dispatch({required super.metrics, required super.context}) {
    dispatch(context);
  }

  /// 是否已找到符合条件的父组件
  bool accepted = false;
}

/// 反向拖动时，询问父级是否可以将未发生位移的滚动交回子级
class NestedScrollResumeNotification extends ScrollNotification {
  NestedScrollResumeNotification.dispatch({required super.metrics, required super.context}) {
    dispatch(context);
  }

  /// 父级是否已释放拖动
  bool accepted = false;
}
