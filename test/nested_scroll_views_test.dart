import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
          children: const [Center(child: Text('first')), Center(child: Text('second')), Center(child: Text('third'))],
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
                TabBar(tabs: [Tab(text: 'Tab one'), Tab(text: 'Tab two')]),
                Expanded(child: NestedTabBarView(children: [Center(child: Text('First panel')), Center(child: Text('Second panel'))])),
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

  for (final forward in [false, true]) {
    testWidgets('nested tab view hands off at the ${forward ? 'last' : 'first'} tab', (tester) async {
      final outer = TabController(length: 3, initialIndex: 1, vsync: const TestVSync());
      final inner = TabController(length: 2, initialIndex: forward ? 1 : 0, vsync: const TestVSync());
      addTearDown(outer.dispose);
      addTearDown(inner.dispose);
      const innerKey = ValueKey('inner tabs');

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.square(
              dimension: 400.0,
              child: NestedTabBarView(
                controller: outer,
                children: [
                  const Center(child: Text('outer first')),
                  NestedTabBarView(
                    key: innerKey,
                    controller: inner,
                    physics: const ClampingScrollPhysics(),
                    children: const [Center(child: Text('inner first')), Center(child: Text('inner last'))],
                  ),
                  const Center(child: Text('outer last')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.fling(find.byKey(innerKey), Offset(forward ? -500.0 : 500.0, 0.0), 1000.0);
      await tester.pumpAndSettle();
      expect(inner.index, forward ? 1 : 0);
      expect(outer.index, forward ? 2 : 0);
      expect(find.text(forward ? 'outer last' : 'outer first').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('mixed page and default tab views keep vertical scrolling independent and hand off horizontally', (tester) async {
    final outer = PageController();
    final list = ScrollController();
    late TabController middle;
    late TabController inner;
    addTearDown(outer.dispose);
    addTearDown(list.dispose);
    const listKey = ValueKey('inner list');

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Center(
            child: SizedBox.square(
              dimension: 400.0,
              child: NestedPageView(
                controller: outer,
                physics: const BouncingScrollPhysics(),
                children: [
                  DefaultTabController(
                    length: 2,
                    initialIndex: 1,
                    child: Builder(builder: (context) {
                      middle = DefaultTabController.of(context);
                      return Column(
                        children: [
                          const TabBar(tabs: [Tab(text: 'middle first'), Tab(text: 'middle last')]),
                          Expanded(
                            child: NestedTabBarView(
                              physics: const ClampingScrollPhysics(),
                              children: [
                                const SizedBox.expand(),
                                DefaultTabController(
                                  length: 2,
                                  child: Builder(builder: (context) {
                                    inner = DefaultTabController.of(context);
                                    return Column(
                                      children: [
                                        const TabBar(tabs: [Tab(text: 'inner first'), Tab(text: 'inner last')]),
                                        Expanded(
                                          child: NestedTabBarView(
                                            physics: const ClampingScrollPhysics(),
                                            children: [
                                              const SizedBox.expand(),
                                              ListView.builder(
                                                key: listKey,
                                                controller: list,
                                                itemExtent: 100.0,
                                                itemCount: 20,
                                                itemBuilder: (context, index) => Text('row $index'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const Center(child: Text('outer last')),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(inner, isNot(same(middle)));
    await tester.tap(find.text('inner last'));
    await tester.pumpAndSettle();
    expect(inner.index, 1);
    expect(middle.index, 1);
    expect(outer.page, closeTo(0.0, 0.001));

    await tester.drag(find.byKey(listKey), const Offset(0.0, -150.0));
    await tester.pumpAndSettle();
    expect(list.offset, greaterThan(0.0));
    expect(inner.index, 1);
    expect(middle.index, 1);
    expect(outer.page, closeTo(0.0, 0.001));

    await tester.fling(find.byKey(listKey), const Offset(-500.0, 0.0), 1000.0);
    await tester.pumpAndSettle();
    expect(inner.index, 1);
    expect(middle.index, 1);
    expect(outer.page, closeTo(1.0, 0.001));
    expect(find.text('outer last').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
