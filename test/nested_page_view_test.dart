import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nested_scroll_views/material.dart';

void main() {
  for (final axis in Axis.values) {
    for (final reverse in [false, true]) {
      testWidgets('$axis reverse=$reverse lets the inner page scroll before its parent', (tester) async {
        final outer = PageController(initialPage: 1);
        final inner = PageController(initialPage: 1);
        addTearDown(outer.dispose);
        addTearDown(inner.dispose);
        const innerKey = ValueKey('inner');

        await _pumpPage(
          tester,
          NestedPageView(
            controller: outer,
            scrollDirection: axis,
            reverse: reverse,
            children: [
              const SizedBox.expand(),
              NestedPageView(
                key: innerKey,
                controller: inner,
                scrollDirection: axis,
                reverse: reverse,
                physics: const ClampingScrollPhysics(),
                children: const [SizedBox.expand(), SizedBox.expand(), SizedBox.expand()],
              ),
              const SizedBox.expand(),
            ],
          ),
        );

        final distance = reverse ? 250.0 : -250.0;
        final forward = axis == Axis.horizontal ? Offset(distance, 0.0) : Offset(0.0, distance);
        await tester.fling(find.byKey(innerKey), forward, 600.0);
        await tester.pumpAndSettle();
        expect(inner.page, closeTo(2.0, 0.001));
        expect(outer.page, closeTo(1.0, 0.001));

        inner.jumpToPage(0);
        await tester.pump();
        await tester.fling(find.byKey(innerKey), -forward * 2.0, 1000.0);
        await tester.pumpAndSettle();
        expect(inner.page, closeTo(0.0, 0.001));
        expect(outer.page, closeTo(0.0, 0.001));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets('$axis passes overscroll through three nested page views', (tester) async {
      final outer = PageController();
      final middle = PageController(initialPage: 1);
      final inner = PageController(initialPage: 1);
      addTearDown(outer.dispose);
      addTearDown(middle.dispose);
      addTearDown(inner.dispose);
      const innerKey = ValueKey('inner');

      await _pumpPage(
        tester,
        NestedPageView(
          controller: outer,
          scrollDirection: axis,
          children: [
            NestedPageView(
              controller: middle,
              scrollDirection: axis,
              physics: const ClampingScrollPhysics(),
              children: [
                const SizedBox.expand(),
                NestedPageView(
                  key: innerKey,
                  controller: inner,
                  scrollDirection: axis,
                  physics: const ClampingScrollPhysics(),
                  children: const [SizedBox.expand(), SizedBox.expand()],
                ),
              ],
            ),
            const SizedBox.expand(),
          ],
        ),
      );

      final forward = axis == Axis.horizontal ? const Offset(-500.0, 0.0) : const Offset(0.0, -500.0);
      await tester.fling(find.byKey(innerKey), forward, 1000.0);
      await tester.pumpAndSettle();
      expect(inner.page, closeTo(1.0, 0.001));
      expect(middle.page, closeTo(1.0, 0.001));
      expect(outer.page, closeTo(1.0, 0.001));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('$axis overscroll does not move a parent on the other axis', (tester) async {
      final outer = PageController();
      final inner = PageController(initialPage: 1);
      addTearDown(outer.dispose);
      addTearDown(inner.dispose);
      const innerKey = ValueKey('inner');

      await _pumpPage(
        tester,
        NestedPageView(
          controller: outer,
          scrollDirection: axis == Axis.horizontal ? Axis.vertical : Axis.horizontal,
          children: [
            NestedPageView(
              key: innerKey,
              controller: inner,
              scrollDirection: axis,
              physics: const ClampingScrollPhysics(),
              children: const [SizedBox.expand(), SizedBox.expand()],
            ),
            const SizedBox.expand(),
          ],
        ),
      );

      final forward = axis == Axis.horizontal ? const Offset(-500.0, 0.0) : const Offset(0.0, -500.0);
      await tester.fling(find.byKey(innerKey), forward, 1000.0);
      await tester.pumpAndSettle();
      expect(inner.page, closeTo(1.0, 0.001));
      expect(outer.page, closeTo(0.0, 0.001));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('a parent with disabled scrolling does not accept a handoff', (tester) async {
    final outer = PageController();
    final inner = PageController(initialPage: 1);
    addTearDown(outer.dispose);
    addTearDown(inner.dispose);
    const innerKey = ValueKey('inner');

    await _pumpPage(
      tester,
      NestedPageView(
        controller: outer,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          NestedPageView(
            key: innerKey,
            controller: inner,
            physics: const ClampingScrollPhysics(),
            children: const [SizedBox.expand(), SizedBox.expand()],
          ),
          const SizedBox.expand(),
        ],
      ),
    );

    await tester.fling(find.byKey(innerKey), const Offset(-500.0, 0.0), 1000.0);
    await tester.pumpAndSettle();
    expect(inner.page, closeTo(1.0, 0.001));
    expect(outer.page, closeTo(0.0, 0.001));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a standalone page view can scroll back after reaching its boundary', (tester) async {
    final controller = PageController(initialPage: 1);
    addTearDown(controller.dispose);
    await _pumpPage(
      tester,
      NestedPageView(
        controller: controller,
        physics: const ClampingScrollPhysics(),
        children: const [SizedBox.expand(), SizedBox.expand()],
      ),
    );

    await tester.fling(find.byType(NestedPageView), const Offset(-500.0, 0.0), 1000.0);
    await tester.pumpAndSettle();
    expect(controller.page, closeTo(1.0, 0.001));
    await tester.fling(find.byType(NestedPageView), const Offset(500.0, 0.0), 1000.0);
    await tester.pumpAndSettle();
    expect(controller.page, closeTo(0.0, 0.001));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final keepAlive in [true, false]) {
    testWidgets('wantKeepAlive=$keepAlive controls offscreen page state retention', (tester) async {
      final outer = PageController();
      final pageKey = GlobalKey<_CounterState>();
      addTearDown(outer.dispose);

      await _pumpPage(
        tester,
        NestedPageView(
          controller: outer,
          children: [
            NestedPageView(wantKeepAlive: keepAlive, children: [_Counter(key: pageKey)]),
            const SizedBox.expand(),
            const SizedBox.expand(),
          ],
        ),
      );
      final originalState = pageKey.currentState!;
      await tester.tap(find.text('count: 0'));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);

      outer.jumpToPage(2);
      await tester.pumpAndSettle();
      expect(originalState.mounted, keepAlive);
      outer.jumpToPage(0);
      await tester.pumpAndSettle();
      expect(identical(pageKey.currentState, originalState), keepAlive);
      expect(find.text('count: ${keepAlive ? 1 : 0}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final axis in Axis.values) {
    for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
      testWidgets('$axis $kind hands off one continuous drag through a single-page parent', (tester) async {
        final outer = PageController();
        final middle = PageController();
        final inner = PageController();
        final reportedPages = <int>[];
        addTearDown(outer.dispose);
        addTearDown(middle.dispose);
        addTearDown(inner.dispose);
        const innerKey = ValueKey('inner');
        final step = axis == Axis.horizontal ? const Offset(-100.0, 0.0) : const Offset(0.0, -100.0);

        await _pumpPage(
          tester,
          ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
            child: NestedPageView(
              controller: outer,
              scrollDirection: axis,
              onPageChanged: reportedPages.add,
              children: [
                NestedPageView(
                  controller: middle,
                  scrollDirection: axis,
                  children: [
                    NestedPageView(
                      key: innerKey,
                      controller: inner,
                      scrollDirection: axis,
                      physics: const ClampingScrollPhysics(),
                      children: const [SizedBox.expand(), SizedBox.expand()],
                    ),
                  ],
                ),
                const SizedBox.expand(),
              ],
            ),
          ),
        );

        final gesture = await tester.startGesture(tester.getCenter(find.byKey(innerKey)), kind: kind);
        for (var i = 0; i < 3; i++) {
          await gesture.moveBy(step);
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(inner.page, inExclusiveRange(0.0, 1.0));
        expect(outer.page, closeTo(0.0, 0.001));

        for (var i = 0; i < 7; i++) {
          await gesture.moveBy(step);
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        await tester.pumpAndSettle();
        expect(inner.page, closeTo(1.0, 0.001));
        expect(middle.page, closeTo(0.0, 0.001));
        expect(outer.page, closeTo(1.0, 0.001));
        expect(reportedPages, [1]);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('canceling a handoff lets the inner page accept the next drag', (tester) async {
    final outer = PageController();
    final inner = PageController(initialPage: 1);
    addTearDown(outer.dispose);
    addTearDown(inner.dispose);
    const innerKey = ValueKey('inner');

    await _pumpPage(
      tester,
      NestedPageView(
        controller: outer,
        children: [
          NestedPageView(
            key: innerKey,
            controller: inner,
            physics: const ClampingScrollPhysics(),
            children: const [SizedBox.expand(), SizedBox.expand()],
          ),
          const SizedBox.expand(),
        ],
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.byKey(innerKey)));
    for (var i = 0; i < 3; i++) {
      await gesture.moveBy(const Offset(-30.0, 0.0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(outer.page, inExclusiveRange(0.0, 0.5));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(outer.page, closeTo(0.0, 0.001));

    await tester.fling(find.byKey(innerKey), const Offset(300.0, 0.0), 600.0);
    await tester.pumpAndSettle();
    expect(inner.page, closeTo(0.0, 0.001));
    expect(outer.page, closeTo(0.0, 0.001));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> _pumpPage(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(home: Center(child: SizedBox.square(dimension: 400.0, child: child))));
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => setState(() => _count++), child: Text('count: $_count'));
  }
}
