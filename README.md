# Nested Scrolling Views

Flutter nested scrolling views.

<table>
    <tbody>
    <tr>
        <td><img src="https://raw.githubusercontent.com/hgraceb/nested_scroll_views/0.0.3/media/NestedTabBarView.gif" alt="NestedTabBarView.gif"/></td>
        <td><img src="https://raw.githubusercontent.com/hgraceb/nested_scroll_views/0.0.3/media/NestedPageView.gif" alt="NestedPageView.gif"/></td>
        <td><img src="https://raw.githubusercontent.com/hgraceb/nested_scroll_views/0.0.3/media/NestedSingleChildScrollView.gif" alt="NestedSingleChildScrollView.gif"/></td>
    </tr>
    </tbody>
</table>

## Usage

Requires Flutter 3.47.0+ and Dart 3.13.0+.

Add `material_ui: ^1.8.0` for Material widgets and tab controllers:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:nested_scroll_views/material.dart';
```

Replace Flutter's scroll views with their nested versions:

| Flutter               | Nested                      |
| --------------------- | --------------------------- |
| PageView              | NestedPageView              |
| TabBarView            | NestedTabBarView            |
| ListView              | NestedListView              |
| GridView              | NestedGridView              |
| CustomScrollView      | NestedCustomScrollView      |
| SingleChildScrollView | NestedSingleChildScrollView |

## Attention

1. Use nested views consistently when nesting scroll views along the same axis.
2. Views are kept alive by default. Setting `wantKeepAlive: false` can interrupt gestures when pages are disposed.

## Thanks

- [Flutter](https://github.com/flutter/flutter)：Flutter makes it easy and fast to build beautiful apps for mobile and beyond

- [union_tabs](https://github.com/wilin52/union_tabs)：A nested TabBarView overscroll unites outer TabBarView scroll event
- [primary_page_view](https://gist.github.com/lwlizhe/558ee91b691a7d9e6873f16d9abccf78)：Flutter Nested Primary PageView
