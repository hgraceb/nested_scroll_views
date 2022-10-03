import 'package:flutter/widgets.dart';

/// 边界滚动状态
class OverscrollChangeNotifier with ChangeNotifier {
  bool _state = false;

  /// 是否滚动到了边界
  get state => _state;

  set state(value) {
    _state = value;
    notifyListeners();
  }
}

/// 边界滚动状态管理
class OverscrollStateProvider extends StatefulWidget {
  final WidgetBuilder builder;

  const OverscrollStateProvider({super.key, required this.builder});

  @override
  State<OverscrollStateProvider> createState() =>
      _OverscrollStateProviderState();

  static OverscrollChangeNotifier of(BuildContext context) {
    final inherited = context
        .getElementForInheritedWidgetOfExactType<_OverscrollStateInherited>()!
        .widget as _OverscrollStateInherited;
    return inherited.overScroll;
  }

  /// 根据滚动通知设置边界滚动状态
  static void updateState(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      of(notification.context!).state = true;
    } else if (notification is ScrollEndNotification) {
      of(notification.context!).state = false;
    }
  }
}

class _OverscrollStateProviderState extends State<OverscrollStateProvider> {
  final OverscrollChangeNotifier _overScroll = OverscrollChangeNotifier();

  @override
  Widget build(BuildContext context) {
    return _OverscrollStateInherited(
      overScroll: _overScroll,
      child: widget.builder(context),
    );
  }

  @override
  void dispose() {
    _overScroll.dispose();
    super.dispose();
  }
}

/// 共享边界滚动状态
class _OverscrollStateInherited extends InheritedWidget {
  final OverscrollChangeNotifier overScroll;

  const _OverscrollStateInherited({
    required this.overScroll,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedWidget _) => false;
}
