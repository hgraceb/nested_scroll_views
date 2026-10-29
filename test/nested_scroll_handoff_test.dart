import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nested_scroll_views/material.dart';
import 'package:nested_scroll_views/src/assembly/widgets/scroll_view.dart' as copied;

void main() {
  final scrollViews = <String, Widget Function(Axis, ScrollController)>{
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 100.0),
          itemCount: 40,
          itemBuilder: (context, index) => const SizedBox.expand(),
        ),
    'custom': (axis, controller) => NestedCustomScrollView(
          scrollDirection: axis,
          controller: controller,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFixedExtentList(
              itemExtent: 100.0,
              delegate: SliverChildBuilderDelegate((context, index) => const SizedBox.expand(), childCount: 20),
            ),
          ],
        ),
    'single child': (axis, controller) => NestedSingleChildScrollView(
          scrollDirection: axis,
          controller: controller,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(width: axis == Axis.horizontal ? 2000.0 : null, height: axis == Axis.vertical ? 2000.0 : null),
        ),
  };

  for (final entry in scrollViews.entries) {
    for (final axis in Axis.values) {
      testWidgets('${entry.key} $axis scrolls internally and hands off at both edges', (tester) async {
        final outer = PageController(initialPage: 1);
        final inner = ScrollController(initialScrollOffset: 400.0);
        addTearDown(outer.dispose);
        addTearDown(inner.dispose);
        const innerKey = ValueKey('inner');
        final forward = axis == Axis.horizontal ? const Offset(-500.0, 0.0) : const Offset(0.0, -500.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox.square(
                dimension: 400.0,
                child: NestedPageView(
                  controller: outer,
                  scrollDirection: axis,
                  children: [
                    const SizedBox.expand(),
                    SizedBox.expand(key: innerKey, child: entry.value(axis, inner)),
                    const SizedBox.expand(),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.drag(find.byKey(innerKey), forward / 5.0);
        await tester.pumpAndSettle();
        expect(inner.offset, greaterThan(400.0));
        expect(outer.page, closeTo(1.0, 0.001));

        inner.jumpTo(inner.position.maxScrollExtent);
        await tester.pump();
        await tester.fling(find.byKey(innerKey), forward, 1000.0);
        await tester.pumpAndSettle();
        expect(inner.offset, closeTo(inner.position.maxScrollExtent, 0.001));
        expect(outer.page, closeTo(2.0, 0.001));

        outer.jumpToPage(1);
        await tester.pumpAndSettle();
        inner.jumpTo(0.0);
        await tester.pump();
        await tester.fling(find.byKey(innerKey), -forward, 1000.0);
        await tester.pumpAndSettle();
        expect(inner.offset, closeTo(0.0, 0.001));
        expect(outer.page, closeTo(0.0, 0.001));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  for (final singleChild in [false, true]) {
    for (final (primary, dismissOnDrag) in [(true, false), (false, true), (true, true)]) {
      testWidgets('${singleChild ? 'single child' : 'list'} primary=$primary dismissOnDrag=$dismissOnDrag', (tester) async {
        final controller = ScrollController();
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        const scrollKey = ValueKey('scroll view');
        final content = Column(children: [TextField(focusNode: focus), const SizedBox(height: 2000.0)]);
        final Widget scrollView;
        if (singleChild) {
          final mode = dismissOnDrag ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual;
          scrollView = NestedSingleChildScrollView(
            key: scrollKey,
            primary: primary,
            controller: primary ? null : controller,
            keyboardDismissBehavior: mode,
            child: content,
          );
        } else {
          final mode = dismissOnDrag ? copied.ScrollViewKeyboardDismissBehavior.onDrag : copied.ScrollViewKeyboardDismissBehavior.manual;
          scrollView = NestedListView(
            key: scrollKey,
            primary: primary,
            controller: primary ? null : controller,
            keyboardDismissBehavior: mode,
            children: [content],
          );
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox.square(
                  dimension: 400.0,
                  child: PrimaryScrollController(controller: controller, child: scrollView),
                ),
              ),
            ),
          ),
        );

        expect(controller.hasClients, isTrue);
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        expect(focus.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        await tester.drag(find.byKey(scrollKey), const Offset(0.0, -150.0));
        await tester.pumpAndSettle();
        expect(controller.offset, greaterThan(0.0));
        final keyboardStaysOpen = !dismissOnDrag;
        expect(focus.hasFocus, keyboardStaysOpen);
        expect(tester.testTextInput.isVisible, keyboardStaysOpen);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
