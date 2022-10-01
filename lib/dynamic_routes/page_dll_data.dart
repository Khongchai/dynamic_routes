import 'package:flutter/material.dart';

enum PageDLLTraversalDirection {
  left,
  right,
}

/// A not-really-doubly-linked-list-kind-of representation that is used to help
/// ensure that the next page that is pushed is the correct one.
class PageDLLData {
  PageDLLData? previousPage;

  /// The page tied to this DLL.
  final Widget widget;
  PageDLLData? nextPage;

  PageDLLData({
    this.previousPage,
    required this.widget,
    this.nextPage,
  });

  int getTraversalSteps(PageDLLTraversalDirection direction,
      [PageDLLData? pageDLLData, i = 0]) {
    final page = pageDLLData ?? this;

    if (direction == PageDLLTraversalDirection.left) {
      if (page.isFirstPage()) return i;
      return getTraversalSteps(direction, page.previousPage, i + 1);
    } else {
      if (page.isLastPage()) return i;
      return getTraversalSteps(direction, page.nextPage, i + 1);
    }
  }

  void setAsNext(PageDLLData nextPage) {
    this.nextPage = nextPage;
    nextPage.previousPage = this;
  }

  void setAsPrevious(PageDLLData previousPage) {
    this.previousPage = previousPage;
    previousPage.nextPage = this;
  }

  bool isFirstPage() => previousPage == null;

  bool isLastPage() => nextPage == null;
}
