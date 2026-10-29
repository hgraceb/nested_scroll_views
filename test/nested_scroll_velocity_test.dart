import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nested_scroll_views/material.dart';

void main() {
  final views = <String, Widget Function(Axis, ScrollController)>{
    'list': (axis, controller) => NestedListView.builder(
      scrollDirection: axis,
      controller: controller,
      physics: const ClampingScrollPhysics(),
      itemExtent: 100.0,
      itemCount: 20,
      itemBuilder: (context, index) => const SizedBox.expand(),
    ),
    'grid': (axis, controller) => NestedGridView.builder(
      scrollDirection: axis,
      controller: controller,
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: 40,
      itemBuilder: (context, index) => const SizedBox.expand(),
    ),
    'custom': (axis, controller) => NestedCustomScrollView(
      scrollDirection: axis,
      controller: controller,
      physics: const ClampingScrollPhysics(),
      slivers: const [SliverToBoxAdapter(child: SizedBox(width: 2000.0, height: 2000.0))],
    ),
    'single child': (axis, controller) => NestedSingleChildScrollView(
      scrollDirection: axis,
      controller: controller,
      physics: const ClampingScrollPhysics(),
      child: const SizedBox(width: 2000.0, height: 2000.0),
    ),
  };

  for (final entry in views.entries) {
    for (final axis in Axis.values) {
      for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
        for (final forward in [false, true]) {
          for (final fast in [false, true]) {
            testWidgets('${entry.key} $axis $kind forward=$forward fast=$fast settles a short handoff', (tester) async {
              final outer = PageController(initialPage: 1);
              final inner = ScrollController();
              final changedPages = <int>[];
              addTearDown(outer.dispose);
              addTearDown(inner.dispose);
              const innerKey = ValueKey('inner');

              await _pumpViews(tester, outer, axis, changedPages, SizedBox.expand(key: innerKey, child: entry.value(axis, inner)));
              final boundary = forward ? inner.position.maxScrollExtent : inner.position.minScrollExtent;
              inner.jumpTo(boundary);
              await tester.pump();

              final step = _offset(axis, forward ? -20.0 : 20.0);
              final interval = Duration(milliseconds: fast ? 10 : 500);
              final gesture = await tester.startGesture(tester.getCenter(find.byKey(innerKey)), kind: kind);
              for (var i = 1; i <= 6; i++) {
                await gesture.moveBy(step, timeStamp: interval * i);
                await tester.pump(interval);
              }
              expect((outer.page! - 1.0).abs(), inExclusiveRange(0.05, 0.45));
              expect(changedPages, isEmpty);
              await gesture.up(timeStamp: interval * 6 + const Duration(milliseconds: 1));
              await tester.pumpAndSettle();

              final expectedPage = fast ? (forward ? 2 : 0) : 1;
              expect(outer.page, closeTo(expectedPage.toDouble(), 0.001));
              expect(changedPages, fast ? [expectedPage] : isEmpty);
              expect(inner.offset, closeTo(boundary, 0.001));
              if (!fast) {
                await _slowLongDrag(tester, find.byKey(innerKey), step, kind);
                expect(outer.page, closeTo(forward ? 2.0 : 0.0, 0.001));
                expect(changedPages, [forward ? 2 : 0]);
              }
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox());
            });
          }
        }
      }

      testWidgets('${entry.key} $axis crosses its boundary during one slow drag and accepts the next drag', (tester) async {
        final outer = PageController(initialPage: 1);
        final inner = ScrollController();
        addTearDown(outer.dispose);
        addTearDown(inner.dispose);
        const innerKey = ValueKey('inner');
        await _pumpViews(tester, outer, axis, [], SizedBox.expand(key: innerKey, child: entry.value(axis, inner)));
        final boundary = inner.position.maxScrollExtent;
        inner.jumpTo(boundary - 60.0);
        await tester.pump();

        final step = _offset(axis, -20.0);
        const interval = Duration(milliseconds: 500);
        final gesture = await tester.startGesture(tester.getCenter(find.byKey(innerKey)));
        for (var i = 1; i <= 6; i++) {
          await gesture.moveBy(step, timeStamp: interval * i);
          await tester.pump(interval);
          if (i == 2) {
            expect(inner.offset, inExclusiveRange(boundary - 60.0, boundary));
            expect(outer.page, closeTo(1.0, 0.001));
          }
        }
        expect(inner.offset, closeTo(boundary, 0.001));
        expect(outer.page, inExclusiveRange(1.0, 1.5));
        await gesture.up(timeStamp: interval * 6 + const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        expect(outer.page, closeTo(1.0, 0.001));

        await tester.drag(find.byKey(innerKey), _offset(axis, 80.0));
        await tester.pumpAndSettle();
        expect(inner.offset, lessThan(boundary));
        expect(outer.page, closeTo(1.0, 0.001));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  for (final tabs in [false, true]) {
    for (final axis in Axis.values) {
      if (tabs && axis == Axis.vertical) {
        continue;
      }
      for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
        for (final forward in [false, true]) {
          for (final fast in [false, true]) {
            testWidgets('${tabs ? 'tabs' : 'pages'} $axis $kind forward=$forward fast=$fast settles a short handoff', (tester) async {
              final outer = PageController(initialPage: 1);
              final changedPages = <int>[];
              addTearDown(outer.dispose);
              const innerKey = ValueKey('inner');
              final Widget inner;
              final int Function() innerIndex;
              final initialIndex = forward ? 1 : 0;
              if (tabs) {
                final controller = TabController(length: 2, initialIndex: initialIndex, vsync: const TestVSync());
                addTearDown(controller.dispose);
                inner = NestedTabBarView(
                  key: innerKey,
                  controller: controller,
                  physics: const ClampingScrollPhysics(),
                  children: const [SizedBox.expand(), SizedBox.expand()],
                );
                innerIndex = () => controller.index;
              } else {
                final controller = PageController(initialPage: initialIndex);
                addTearDown(controller.dispose);
                inner = NestedPageView(
                  key: innerKey,
                  controller: controller,
                  scrollDirection: axis,
                  physics: const ClampingScrollPhysics(),
                  children: const [SizedBox.expand(), SizedBox.expand()],
                );
                innerIndex = () => controller.page!.round();
              }
              await _pumpViews(tester, outer, axis, changedPages, inner);

              final step = _offset(axis, forward ? -20.0 : 20.0);
              final interval = Duration(milliseconds: fast ? 10 : 500);
              final gesture = await tester.startGesture(tester.getCenter(find.byKey(innerKey)), kind: kind);
              for (var i = 1; i <= 6; i++) {
                await gesture.moveBy(step, timeStamp: interval * i);
                await tester.pump(interval);
              }
              expect((outer.page! - 1.0).abs(), inExclusiveRange(0.05, 0.45));
              expect(changedPages, isEmpty);
              await gesture.up(timeStamp: interval * 6 + const Duration(milliseconds: 1));
              await tester.pumpAndSettle();
              final expectedPage = fast ? (forward ? 2 : 0) : 1;
              expect(outer.page, closeTo(expectedPage.toDouble(), 0.001));
              expect(changedPages, fast ? [expectedPage] : isEmpty);
              expect(innerIndex(), initialIndex);
              if (!fast) {
                await _slowLongDrag(tester, find.byKey(innerKey), step, kind);
                expect(outer.page, closeTo(forward ? 2.0 : 0.0, 0.001));
                expect(changedPages, [forward ? 2 : 0]);
              }
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox());
            });
          }
        }
      }
    }
  }
}

Offset _offset(Axis axis, double distance) => axis == Axis.horizontal ? Offset(distance, 0.0) : Offset(0.0, distance);

Future<void> _slowLongDrag(WidgetTester tester, Finder finder, Offset step, PointerDeviceKind kind) async {
  const interval = Duration(milliseconds: 500);
  final gesture = await tester.startGesture(tester.getCenter(finder), kind: kind);
  for (var i = 1; i <= 14; i++) {
    await gesture.moveBy(step, timeStamp: interval * i);
    await tester.pump(interval);
  }
  await gesture.up(timeStamp: interval * 14 + const Duration(milliseconds: 1));
  await tester.pumpAndSettle();
}

Future<void> _pumpViews(WidgetTester tester, PageController outer, Axis axis, List<int> changedPages, Widget inner) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: TargetPlatform.windows),
      home: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: Center(
          child: SizedBox.square(
            dimension: 400.0,
            child: NestedPageView(
              controller: outer,
              scrollDirection: axis,
              onPageChanged: changedPages.add,
              children: [const SizedBox.expand(), inner, const SizedBox.expand()],
            ),
          ),
        ),
      ),
    ),
  );
}
