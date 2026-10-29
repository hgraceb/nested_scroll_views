import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nested_scroll_views/material.dart';

void main() {
  for (final axis in Axis.values) {
    for (final reverse in [false, true]) {
      testWidgets('$axis reverse=$reverse passes overscroll to the outer page', (tester) async {
        final outer = PageController();
        final inner = PageController(initialPage: 1);
        addTearDown(outer.dispose);
        addTearDown(inner.dispose);
        const innerKey = ValueKey('inner');

        await tester.pumpWidget(
          MaterialApp(
            home: NestedPageView(
              controller: outer,
              scrollDirection: axis,
              reverse: reverse,
              children: [
                NestedPageView(
                  key: innerKey,
                  controller: inner,
                  scrollDirection: axis,
                  reverse: reverse,
                  physics: const ClampingScrollPhysics(),
                  children: const [SizedBox.expand(), SizedBox.expand()],
                ),
                const SizedBox.expand(),
              ],
            ),
          ),
        );
        final distance = reverse ? 500.0 : -500.0;
        final offset = axis == Axis.horizontal ? Offset(distance, 0.0) : Offset(0.0, distance);
        await tester.fling(find.byKey(innerKey), offset, 1000.0);
        await tester.pumpAndSettle();

        expect(inner.page, closeTo(1.0, 0.001));
        expect(outer.page, closeTo(1.0, 0.001));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('tab view follows controller changes and drag gestures', (tester) async {
    final controller = TabController(length: 3, vsync: const TestVSync());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: NestedTabBarView(
          controller: controller,
          children: const [
            Center(child: Text('first')),
            Center(child: Text('second')),
            Center(child: Text('third')),
          ],
        ),
      ),
    );

    controller.animateTo(2);
    await tester.pumpAndSettle();
    expect(find.text('third').hitTestable(), findsOneWidget);
    await tester.fling(find.byType(NestedTabBarView), const Offset(500.0, 0.0), 1000.0);
    await tester.pumpAndSettle();
    expect(controller.index, 1);
    expect(find.text('second').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tab view shares the default controller with TabBar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Material(
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Tab one'),
                    Tab(text: 'Tab two'),
                  ],
                ),
                Expanded(
                  child: NestedTabBarView(
                    children: [
                      Center(child: Text('First panel')),
                      Center(child: Text('Second panel')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tab two'));
    await tester.pumpAndSettle();
    expect(find.text('Second panel').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
