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

Replace flutter's views with the following views and use them nested.

| Flutter               | Nested                      |
| --------------------- | --------------------------- |
| PageView              | NestedPageView              |
| TabBarView            | NestedTabBarView            |
| ListView              | NestedListView              |
| GridView              | NestedGridView              |
| CustomScrollView      | NestedCustomScrollView      |
| SingleChildScrollView | NestedSingleChildScrollView |

## Attention

1. Nested non-nested views with the same scroll direction will result in weird scrolling.
2. Nested views are kept alive by default, you can set `wantKeepAlive` to false, which may lead to loss of gesture events because the page is destroyed.

## Thanks

- [flutter](https://github.com/flutter/flutter)：Flutter makes it easy and fast to build beautiful apps for mobile and beyond

- [union_tabs](https://github.com/wilin52/union_tabs)：A nested TabBarView overscroll unites outer TabBarView scroll event
- [primary_page_view](https://gist.github.com/lwlizhe/558ee91b691a7d9e6873f16d9abccf78)：FLutter Nested Primary PageView