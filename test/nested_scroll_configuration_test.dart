import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nested_scroll_views/material_ui.dart';
import 'package:nested_scroll_views/src/assembly/widgets/scrollable.dart' show OverscrollScrollable;

class _DismissOnDragBehavior extends MaterialScrollBehavior {
  const _DismissOnDragBehavior();

  @override
  ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(BuildContext context) => ScrollViewKeyboardDismissBehavior.onDrag;
}

void main() {
  final primaryViews = <String, Widget Function()>{
    'list': () => NestedListView(
      primary: true,
      hitTestBehavior: HitTestBehavior.translucent,
      children: const [SizedBox(height: 1600.0)],
    ),
    'grid': () => NestedGridView.count(
      primary: true,
      hitTestBehavior: HitTestBehavior.translucent,
      crossAxisCount: 1,
      children: const [SizedBox(), SizedBox(), SizedBox()],
    ),
    'custom': () => const NestedCustomScrollView(
      primary: true,
      hitTestBehavior: HitTestBehavior.translucent,
      slivers: [SliverToBoxAdapter(child: SizedBox(height: 1600.0))],
    ),
    'single child': () => const NestedSingleChildScrollView(
      primary: true,
      hitTestBehavior: HitTestBehavior.translucent,
      child: SizedBox(height: 1600.0, width: double.infinity),
    ),
  };

  for (final entry in primaryViews.entries) {
    testWidgets('${entry.key} preserves primary controller, hit testing, and inherited drag dismissal', (tester) async {
      final controller = ScrollController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: PrimaryScrollController(
            controller: controller,
            child: ScrollConfiguration(
              behavior: const _DismissOnDragBehavior(),
              child: Material(
                child: Column(
                  children: [
                    TextField(focusNode: focus),
                    Expanded(child: entry.value()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(controller.hasClients, isTrue);
      expect(tester.widget<OverscrollScrollable>(find.byType(OverscrollScrollable)).hitTestBehavior, HitTestBehavior.translucent);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.drag(find.byType(OverscrollScrollable), const Offset(0.0, -150.0));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
      expect(controller.offset, greaterThan(0.0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  final grids = <String, Widget Function(Axis)>{
    'count': (axis) => NestedGridView.count(
      scrollDirection: axis,
      crossAxisCount: 2,
      childAspectRatio: 4.0,
      mainAxisExtent: 75.0,
      children: const [SizedBox(key: ValueKey('grid cell'))],
    ),
    'extent': (axis) => NestedGridView.extent(
      scrollDirection: axis,
      maxCrossAxisExtent: 200.0,
      childAspectRatio: 4.0,
      mainAxisExtent: 75.0,
      children: const [SizedBox(key: ValueKey('grid cell'))],
    ),
  };
  for (final entry in grids.entries) {
    for (final axis in Axis.values) {
      testWidgets('grid ${entry.key} $axis uses mainAxisExtent instead of childAspectRatio', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(child: SizedBox.square(dimension: 400.0, child: entry.value(axis))),
          ),
        );
        final size = tester.getSize(find.byKey(const ValueKey('grid cell')));
        expect(size, axis == Axis.vertical ? const Size(200.0, 75.0) : const Size(75.0, 200.0));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  final pageViews = <String, Widget Function(IndexedWidgetBuilder)>{
    'default': (builder) => NestedPageView(
      allowImplicitScrolling: true,
      scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
      children: List.generate(5, (index) => Builder(builder: (context) => builder(context, index))),
    ),
    'builder': (builder) => NestedPageView.builder(
      allowImplicitScrolling: true,
      scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
      itemCount: 5,
      itemBuilder: builder,
    ),
    'custom': (builder) => NestedPageView.custom(
      allowImplicitScrolling: true,
      scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
      childrenDelegate: SliverChildBuilderDelegate(builder, childCount: 5),
    ),
  };
  for (final entry in pageViews.entries) {
    testWidgets('page ${entry.key} caches two offscreen pages', (tester) async {
      final built = <int>{};
      await tester.pumpWidget(
        MaterialApp(
          home: entry.value((context, index) {
            built.add(index);
            return Text('page $index');
          }),
        ),
      );
      expect(built, {0, 1, 2});
      expect(find.text('page 0').hitTestable(), findsOneWidget);
      expect(find.text('page 2').hitTestable(), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('separated list retains item state when findItemIndexCallback reorders items', (tester) async {
    var items = ['a', 'b', 'c'];
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return NestedListView.separated(
              itemCount: items.length,
              findItemIndexCallback: (key) => items.indexOf((key as ValueKey<String>).value),
              itemBuilder: (context, index) => _Counter(key: ValueKey(items[index])),
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
            );
          },
        ),
      ),
    );
    final item = find.byKey(const ValueKey('a'));
    final originalState = tester.state(item);
    await tester.tap(find.descendant(of: item, matching: find.byType(TextButton)));
    await tester.pump();
    rebuild(() => items = ['c', 'b', 'a']);
    await tester.pump();
    expect(tester.state(item), same(originalState));
    expect(find.descendant(of: item, matching: find.text('count: 1')), findsOneWidget);
    expect(tester.getTopLeft(item).dy, greaterThan(tester.getTopLeft(find.byKey(const ValueKey('c'))).dy));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var count = 0;

  @override
  Widget build(BuildContext context) => TextButton(onPressed: () => setState(() => count++), child: Text('count: $count'));
}
