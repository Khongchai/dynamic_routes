import 'package:flutter/material.dart';

/// The doubly-linked-list-kind-of representation that is used to help ensure that the next page that is pushed is the correct one.
class PageDLLData {
  final Widget? previousPage;
  final Widget currentPage;
  final Widget? nextPage;

  const PageDLLData(
      {required this.previousPage,
      required this.currentPage,
      required this.nextPage});

  bool isFirstPage() => previousPage == null;

  bool isLastPage() => nextPage == null;
}
