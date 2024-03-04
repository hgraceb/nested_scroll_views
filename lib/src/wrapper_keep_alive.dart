import 'package:flutter/widgets.dart';

class WrapperKeepAlive extends StatefulWidget {
  final Widget child;
  final bool wantKeepAlive;

  const WrapperKeepAlive({
    super.key,
    required this.child,
    required this.wantKeepAlive,
  });

  @override
  State<WrapperKeepAlive> createState() => _WrapperKeepAliveState();
}

class _WrapperKeepAliveState extends State<WrapperKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant WrapperKeepAlive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wantKeepAlive != widget.wantKeepAlive) {
      updateKeepAlive();
    }
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}
