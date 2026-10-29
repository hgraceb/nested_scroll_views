## Unreleased

- Sync the required widget source blocks with Flutter stable 3.47.8
  (`737ba8f885dc`), while supporting Flutter 3.47.0 and later.
- Migrate Material imports and tab controllers to `material_ui` 1.8.0, and sync
  the tab view source blocks from that package. Applications should import
  `package:material_ui/material_ui.dart` for Material widgets and controllers.
- Reuse Flutter's public keyboard-dismiss and scroll-increment types, and remove
  unused two-dimensional scrolling and keyboard-action copies.
- Expose `scrollCacheExtent`, `paintOrder`, and `findItemIndexCallback`.
- Preserve hit testing, primary controllers, and inherited keyboard dismissal
  when replacing scrollables.
- `NestedPageView.custom` is no longer const, matching Flutter's `PageView.custom`.

## 0.0.12

- Adapt for Flutter 3.24.0 and Dart 3.5.0.

## 0.0.11

- Adapt for Flutter 3.22.0 and Dart 3.4.0.

## 0.0.10

- Adapt for Flutter 3.19.2 and Dart 3.3.0.

## 0.0.9

- Adapt for Flutter 3.16.0 and Dart 3.2.0.

## 0.0.8

- Adapt for Flutter 3.13.0 and Dart 3.1.0.

## 0.0.7

- Refactor project import and export.
- Replace the redundant NestedPageController with PageController.

## 0.0.6

- Add support for NeverScrollableScrollPhysics.

## 0.0.5

- Fix the error of scrolling the outermost view.

## 0.0.4

- Add wantKeepAlive argument.
- Add NestedListView, NestedGridView, NestedCustomScrollView.

## 0.0.3

- Add thanks.

## 0.0.2

- Update screenshots.

## 0.0.1

- Initial version.
