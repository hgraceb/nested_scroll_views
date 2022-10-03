# Nested Scrolling Views

Flutter nested scrolling views.

<table>
    <tbody>
    <tr>
        <td><img src="https://raw.githubusercontent.com/hgraceb/nested_scroll_views/0.0.2/media/NestedTabBarView.gif" alt="NestedTabBarView.gif"/></td>
        <td><img src="https://raw.githubusercontent.com/hgraceb/nested_scroll_views/0.0.2/media/NestedPageView.gif" alt="NestedPageView.gif"/></td>
        <td><img src="https://raw.githubusercontent.com/hgraceb/nested_scroll_views/0.0.2/media/NestedSingleChildScrollView.gif" alt="NestedSingleChildScrollView.gif"/></td>
    </tr>
    </tbody>
</table>

## Usage

Replace flutter's views with the following views and use them nested.

| View                        | Controller           | Flutter               |
| --------------------------- | -------------------- | --------------------- |
| NestedPageView              | NestedPageController | PageView              |
| NestedTabBarView            | TabController        | TabBarView            |
| NestedSingleChildScrollView | ScrollController     | SingleChildScrollView |

## Gotchas

1. Nested views always stay alive.
2. NeverScrollableScrollPhysics invalid.
3. Nested non-nested views with the same scroll direction will result in weird scrolling.

## Thanks

- [flutter](https://github.com/flutter/flutter)：Flutter makes it easy and fast to build beautiful apps for mobile and beyond

- [union_tabs](https://github.com/wilin52/union_tabs)：A nested TabBarView overscroll unites outer TabBarView scroll event
- [primary_page_view](https://gist.github.com/lwlizhe/558ee91b691a7d9e6873f16d9abccf78)：FLutter Nested Primary PageView