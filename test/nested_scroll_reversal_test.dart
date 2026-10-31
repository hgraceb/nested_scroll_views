import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nested_scroll_views/material_ui.dart';

void main() {
  for (final axis in Axis.values) {
    for (final reverse in [false, true]) {
      for (final atEnd in [false, true]) {
        for (final fast in [false, true]) {
          testWidgets('$axis reverse=$reverse atEnd=$atEnd fast=$fast returns a blocked handoff to the list', (tester) async {
            final initialPage = atEnd ? 1 : 0;
            final outer = PageController(initialPage: initialPage);
            final inner = ScrollController();
            addTearDown(outer.dispose);
            addTearDown(inner.dispose);
            final list = NestedListView.builder(
              controller: inner,
              scrollDirection: axis,
              reverse: reverse,
              padding: EdgeInsets.zero,
              itemExtent: 100,
              // Leave room for the fast release to settle before the other edge.
              itemCount: fast ? 80 : 8,
              itemBuilder: (_, _) => const SizedBox.expand(),
            );
            await _pumpViews(
              tester,
              NestedPageView(
                controller: outer,
                scrollDirection: axis,
                reverse: reverse,
                children: [if (atEnd) const SizedBox.expand(), list, if (!atEnd) const SizedBox.expand()],
              ),
            );
            final boundary = atEnd ? inner.position.maxScrollExtent : inner.position.minScrollExtent;
            inner.jumpTo(boundary + (atEnd ? -50 : 50));
            await tester.pump();

            final outward = (atEnd ? -30.0 : 30.0) * (reverse ? -1 : 1);
            final interval = Duration(milliseconds: fast ? 10 : 150);
            final gesture = await tester.startGesture(const Offset(400, 300));
            for (var i = 1; i <= 5; i++) {
              await gesture.moveBy(_offset(axis, outward), timeStamp: interval * i);
              await tester.pump(interval);
            }
            expect(inner.offset, closeTo(boundary, 0.001));
            expect(outer.page, initialPage);

            for (var i = 6; i <= 10; i++) {
              await gesture.moveBy(_offset(axis, -outward * (fast ? 2 : 1)), timeStamp: interval * i);
              await tester.pump(interval);
            }
            expect(inner.offset, inExclusiveRange(inner.position.minScrollExtent, inner.position.maxScrollExtent));
            expect(outer.page, initialPage);
            final offsetBeforeRelease = inner.offset;
            await gesture.up(timeStamp: interval * 10 + const Duration(milliseconds: 1));
            if (fast) expect(inner.position.isScrollingNotifier.value, isTrue);
            await tester.pumpAndSettle();
            expect(inner.offset, inExclusiveRange(inner.position.minScrollExtent, inner.position.maxScrollExtent));
            expect(outer.page, initialPage);
            expect(inner.position.isScrollingNotifier.value, isFalse);
            expect(outer.position.isScrollingNotifier.value, isFalse);
            if (fast) {
              expect(inner.offset, atEnd ? lessThan(offsetBeforeRelease) : greaterThan(offsetBeforeRelease));
            }

            final settledOffset = inner.offset;
            await tester.pump(const Duration(milliseconds: 500));
            expect(inner.offset, settledOffset);
            expect(outer.page, initialPage);

            await tester.timedDrag(find.byType(NestedListView), _offset(axis, outward * 2), const Duration(milliseconds: 600));
            await tester.pumpAndSettle();
            expect(inner.offset, atEnd ? greaterThan(settledOffset) : lessThan(settledOffset));
            expect(inner.offset, inExclusiveRange(inner.position.minScrollExtent, inner.position.maxScrollExtent));
            expect(outer.page, initialPage);
            expect(inner.position.isScrollingNotifier.value, isFalse);
            expect(outer.position.isScrollingNotifier.value, isFalse);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          });
        }
      }
    }

    testWidgets('$axis keeps a handoff with a parent that has already moved', (tester) async {
      final outer = PageController(initialPage: 1);
      final inner = ScrollController();
      addTearDown(outer.dispose);
      addTearDown(inner.dispose);
      await _pumpViews(
        tester,
        NestedPageView(
          controller: outer,
          scrollDirection: axis,
          children: [
            const SizedBox.expand(),
            NestedListView.builder(
              controller: inner,
              scrollDirection: axis,
              padding: EdgeInsets.zero,
              itemExtent: 100,
              itemCount: 8,
              itemBuilder: (_, _) => const SizedBox.expand(),
            ),
            const SizedBox.expand(),
          ],
        ),
      );
      inner.jumpTo(inner.position.maxScrollExtent);
      await tester.pump();
      final gesture = await tester.startGesture(const Offset(400, 300));
      const interval = Duration(milliseconds: 150);
      for (var i = 1; i <= 6; i++) {
        await gesture.moveBy(_offset(axis, -20), timeStamp: interval * i);
        await tester.pump(interval);
      }
      final pageBeforeReverse = outer.page!;
      expect(pageBeforeReverse, inExclusiveRange(1.0, 1.5));
      for (var i = 7; i <= 9; i++) {
        await gesture.moveBy(_offset(axis, 20), timeStamp: interval * i);
        await tester.pump(interval);
      }
      expect(outer.page, inExclusiveRange(1.0, pageBeforeReverse));
      expect(inner.offset, inner.position.maxScrollExtent);
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(outer.page, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

Offset _offset(Axis axis, double distance) => axis == Axis.horizontal ? Offset(distance, 0) : Offset(0, distance);

Future<void> _pumpViews(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Center(child: SizedBox.square(dimension: 400, child: child)),
    ),
  );
}
