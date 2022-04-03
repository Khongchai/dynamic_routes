import 'package:flutter/material.dart';

/// Hashes for the Widget that is bound to the routes above.
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

/// Let's say that your login flow requires the user to fill in their information and the form is split into 5 pages.
/// However, some of the information in those 5 pages can also be pre-obtained through other means, which would render
/// some of the pages in this flow unnecessary.
///
/// The solution would be to have a stacked navigator that we can just say push this set of pages in order.
///
/// Instructions:
///
/// _In pages that are marked with the DynamicRouteParticipator mixin._
///
/// Somewhere in the page right before AddressPage
///
/// ```dart
///   StackedNavigator.loadStack([AddressPage, OccupationPage, XPage, XXPage]);
///   StackedNavigator.pushFirst(context);
///```
///
/// Somewhere in AddressPage
/// ```dart
///   StackedNavigator.pushNext(context, currentWidget: widget);
/// ```
///
/// Somewhere in OccupationPage
/// ```dart
///   StackedRoutesNavigator.pushNext(context, currentWidget: widget);
///   //or
///   StackedRoutesNavigator.popCurrent(context, currentWidget: widget);
/// ```
///

//TODO also added a mechanism for passing information
// TODO detect through the passed props if we are doing things through StackedRoutesNavigator not just using Navigator directly.
class StackedRoutesNavigator {
  /// A map between the widget's hash and the doubly-linked list data it belongs to
  static Map<int, PageDLLData> _pageDataMap = {};

  /// Kept primarily for debugging purposes
  static int? _currentPageHash;

  /// Use as a safeguard to prevent this being used before the states are loaded.
  static bool _isStackLoaded = false;

  StackedRoutesNavigator._();

  static List<Widget> getLoadedPages() {
    return _pageDataMap.values.map((e) => e.currentPage).toList();
  }

  /// Returns the page widget that belongs to the current route
  static int? getCurrentWidgetHash() {
    return _currentPageHash;
  }

  static cleanUp() {
    _isStackLoaded = false;
    _pageDataMap = {};
    _currentPageHash = null;
  }

  /// Can pass as an optional parameter whether or not to be strict about pages that get loaded onto the navigation stack.
  ///
  /// If true(default value), pages that can participate will have to use the DynamicRouteParticipator mixin.
  /// else, this restriction will be lifted (not recommended).
  static loadStack(List<Widget> pages, {bool strict = true}) {
    _isStackLoaded = true;
    _pageDataMap = _generatePageStates(pages: pages, strict: strict);
  }

  static Map<int, PageDLLData> _generatePageStates(
      {required List<Widget> pages, required bool strict}) {
    final Map<int, PageDLLData> pageRoutes = {};

    _currentPageHash = pages.first.hashCode;

    for (int i = 0; i < pages.length; i++) {
      final previousPage = i - 1 < 0 ? null : pages[i - 1];
      final nextPage = i + 1 >= pages.length ? null : pages[i + 1];
      final currentPage = pages[i];

      final pageIsMarkedForDynamicRouting =
          currentPage is DynamicRouteParticipator;
      final strictModeOff = !strict;

      assert(pageIsMarkedForDynamicRouting || strictModeOff,
          "Strict mode is on, only use pages that use the DynamicRouteParticipator mixin");

      final currentPageStates = PageDLLData(
        previousPage: previousPage,
        currentPage: currentPage,
        nextPage: nextPage,
      );

      pageRoutes[currentPage.hashCode] = currentPageStates;
    }

    return pageRoutes;
  }

  /// Push the next page in the stack
  ///
  /// currentWidget is needed to obtain the correct previous and next route in the stack.
  static void pushNext(BuildContext context, {required Widget currentWidget}) {
    final currentPageState = _pageDataMap[currentWidget.hashCode];

    assert(currentPageState != null,
        "The widget provided was not included in the initial array when loadStack() was called.");
    assert(
        !currentPageState!.isLastPage(),
        "There are no more pages to push. This is the end of the flow. "
        "From this page onward, use the Navigator class instead");
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(_currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    _currentPageHash = currentPageState!.nextPage.hashCode;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => currentPageState.nextPage!));
  }

  /// Push the first page in the stack
  ///
  /// This is called in the page before the first page included in the navigation stack.
  static void pushFirst(BuildContext context) {
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");

    // TODO Might need a better way for this because .values is O(n)
    final firstPage = _pageDataMap.values.first;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => firstPage.currentPage));
  }

  /// Pop the current page from the stack
  static void popCurrent(BuildContext context,
      {required Widget currentWidget}) {
    final currentPage = _pageDataMap[currentWidget.hashCode];

    assert(currentPage != null,
        "The page this method is called in was not included in the array when loadStack() was called");
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(_currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    _currentPageHash = currentPage!.previousPage.hashCode;

    Navigator.pop(context);
  }
}

/// For pages that are to be navigated with the StackedNavigator -- pages that gets put in the array
mixin DynamicRouteParticipator {}
