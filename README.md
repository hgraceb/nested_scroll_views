# Nested Scrolling Views

Flutter nested scrolling views.

<table>
    <tbody>
    <tr>
        <td><img src="media/NestedTabBarView.gif" alt="NestedTabBarView.gif"/></td>
        <td><img src="media/NestedPageView.gif" alt="NestedPageView.gif"/></td>
        <td><img src="media/NestedSingleChildScrollView.gif" alt="NestedSingleChildScrollView.gif"/></td>
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