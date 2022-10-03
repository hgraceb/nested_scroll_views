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