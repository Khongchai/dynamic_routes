import 'package:flutter/material.dart';

/// The doubly-linked-list-kind-of representation that is used to help ensure
/// that the next page that is pushed is the correct one.
class PageDLLData {
  final Widget? previousPage;
  final Widget currentPage;
  final Widget? nextPage;
  final int index;

  const PageDLLData({
    required this.previousPage,
    required this.currentPage,
    required this.nextPage,
    required this.index,
  });

  bool isFirstPage() {
    final isFirstPage = previousPage == null;
    if (isFirstPage) {
      assert(index == 0);
    }

    return isFirstPage;
  }

  bool isLastPage() => nextPage == null;
}
