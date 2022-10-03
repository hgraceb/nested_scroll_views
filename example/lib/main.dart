import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested_scroll_views/nested_scroll_views.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nested View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Nested View Home Page'),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  int _warpUnderwayCount = 0;
  late List<Widget> childrenWithKey;
  final _pageController = NestedPageController();

  Future<void> _animateToPage(int page) async {
    if (_warpUnderwayCount > 0 || _currentIndex == page) {
      return;
    }
    const duration = kTabScrollDuration;
    if ((_currentIndex - page).abs() == 1) {
      _warpUnderwayCount += 1;
      await _pageController.animateToPage(
        page,
        duration: duration,
        curve: Curves.ease,
      );
      _warpUnderwayCount -= 1;
      return Future<void>.value();
    }

    final int initialPage = page > _currentIndex ? page - 1 : page + 1;
    final List<Widget> originalChildren = childrenWithKey;
    setState(() {
      _warpUnderwayCount += 1;

      childrenWithKey = List<Widget>.of(childrenWithKey, growable: false);
      final Widget temp = childrenWithKey[initialPage];
      childrenWithKey[initialPage] = childrenWithKey[_currentIndex];
      childrenWithKey[_currentIndex] = temp;
    });
    _pageController.jumpToPage(initialPage);
    await _pageController.animateToPage(
      page,
      duration: duration,
      curve: Curves.ease,
    );
    setState(() {
      _warpUnderwayCount -= 1;
      childrenWithKey = originalChildren;
    });
  }

  @override
  void initState() {
    super.initState();
    childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(const [
      FirstPage(),
      SecondPage(),
      ThirdPage(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (page) => _animateToPage(page),
        items: const [
          BottomNavigationBarItem(
            label: '1',
            icon: Icon(Icons.mode_night),
          ),
          BottomNavigationBarItem(
            label: '2',
            icon: Icon(Icons.cloud),
          ),
          BottomNavigationBarItem(
            label: '3',
            icon: Icon(Icons.light_mode),
          ),
        ],
      ),
      body: NestedPageView(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: childrenWithKey,
      ),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<StatefulWidget> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final _tabs = ['Tab 1.1', 'Tab 1.2', 'Tab 1.3', 'Tab 1.4', 'Tab 1.5'];
  final _items = List<String>.generate(100, (i) => 'Item $i');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('First Page'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: NestedTabBarView(
          children: _tabs.map((tab) {
            return ListView.builder(
              itemCount: _items.length,
              prototypeItem: ListTile(
                title: Text(_items.first),
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<StatefulWidget> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final _firstPageController = NestedPageController();
  final _secondPageController = NestedPageController();
  final _thirdPageController = NestedPageController();
  final _fourthPageController = NestedPageController();

  @override
  void dispose() {
    _firstPageController.dispose();
    _secondPageController.dispose();
    _thirdPageController.dispose();
    _fourthPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: NestedPageView(
        controller: _firstPageController,
        children: [
          Container(
            width: size.width,
            height: size.height,
            color: Colors.red.shade200,
            alignment: Alignment.center,
            child: const Text("Page 2.1"),
          ),
          Column(
            children: [
              Expanded(
                child: NestedPageView(
                  controller: _secondPageController,
                  children: [
                    Container(
                      color: Colors.orange.shade200,
                      alignment: Alignment.center,
                      child: const Text("Page 2.2.1"),
                    ),
                    NestedPageView(
                      controller: _thirdPageController,
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: NestedPageView(
                                controller: _fourthPageController,
                                children: [
                                  Container(
                                    color: Colors.yellow.shade200,
                                    alignment: Alignment.center,
                                    child: const Text("Page 2.2.2.1"),
                                  ),
                                  Container(
                                    color: Colors.green.shade200,
                                    alignment: Alignment.center,
                                    child: const Text("Page 2.2.2.2"),
                                  ),
                                  Container(
                                    color: Colors.cyan.shade200,
                                    alignment: Alignment.center,
                                    child: const Text("Page 2.2.2.3"),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: size.width,
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Text("Page 2.2.2"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      color: Colors.blue.shade200,
                      alignment: Alignment.center,
                      child: const Text("Page 2.2.3"),
                    ),
                  ],
                ),
              ),
              Container(
                width: size.width,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Text("Page 2.2"),
                ),
              ),
            ],
          ),
          Container(
            width: size.width,
            height: size.height,
            color: Colors.purple.shade200,
            alignment: Alignment.center,
            child: const Text("Page 2.3"),
          ),
        ],
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<StatefulWidget> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final _pageController = NestedPageController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width / 3.5;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Page'),
      ),
      body: NestedPageView(
        controller: _pageController,
        children: [
          NestedSingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Stack(
              children: [
                Container(
                  width: width + 1,
                  height: size.height,
                  color: Colors.red.shade300,
                  margin: EdgeInsets.fromLTRB(width * 0, 0, 0, 0),
                ),
                Container(
                  width: width + 1,
                  height: size.height,
                  color: Colors.orange.shade300,
                  margin: EdgeInsets.fromLTRB(width * 1, 0, 0, 0),
                ),
                Container(
                  width: width + 1,
                  height: size.height,
                  color: Colors.yellow.shade300,
                  margin: EdgeInsets.fromLTRB(width * 2, 0, 0, 0),
                ),
                Container(
                  width: width + 1,
                  height: size.height,
                  color: Colors.green.shade300,
                  margin: EdgeInsets.fromLTRB(width * 3, 0, 0, 0),
                ),
                Container(
                  width: width + 1,
                  height: size.height,
                  color: Colors.cyan.shade300,
                  margin: EdgeInsets.fromLTRB(width * 4, 0, 0, 0),
                ),
                Container(
                  width: width + 1,
                  height: size.height,
                  color: Colors.blue.shade300,
                  margin: EdgeInsets.fromLTRB(width * 5, 0, 0, 0),
                ),
                Container(
                  width: width,
                  height: size.height,
                  color: Colors.purple.shade300,
                  margin: EdgeInsets.fromLTRB(width * 6, 0, 0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
