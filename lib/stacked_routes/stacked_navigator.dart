import 'package:flutter/material.dart';

/// The states of the current routes
class PageRouteStates {
  final Route? previousRoute;
  final Route currentRoute;
  final Route? nextRoute;

  /// Hashes for the Widget that is bound to the routes above.
  final int? previousHash;
  final int currentHash;
  final int? nextHash;

  const PageRouteStates(
      {required this.previousRoute,
      required this.currentRoute,
      required this.nextRoute,
      required this.previousHash,
      required this.currentHash,
      required this.nextHash});

  bool isFirstPage() => previousRoute == null;

  bool isLastPage() => nextRoute == null;
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
///   StackedNavigator.pushNext(context);
/// ```
///
/// Somewhere in OccupationPage
/// ```dart
///   StackedRoutesNavigator.pushNext(context);
///   //or
///   StackedRoutesNavigator.popCurrent(context);
/// ```
///

//TODO also added a mechanism for passing information
// TODO detect through the passed props if we are doing things through StackedRoutesNavigator not just using Navigator directly.

// current page can be obtained through this.widget
class StackedRoutesNavigator {
  /// A map between the widget's hash and the route it belongs too.
  ///
  /// This could have been Map<Widget, PageRouteStates>
  static Map<int, PageRouteStates> _pageRoutes = {};

  /// Kept primarily for debugging purposes
  static int? _currentPageHash;

  /// Use as a safeguard to prevent this being used before the states are loaded.
  static bool _isStackLoaded = false;

  StackedRoutesNavigator._();

  static List<Route> getCurrentRouteStack() {
    return _pageRoutes.values.map((e) => e.currentRoute).toList();
  }

  /// Returns the page widget that belongs to the current route
  static int? getCurrentWidgetHash() {
    return _currentPageHash;
  }

  static clearStack() {
    _isStackLoaded = false;
    _pageRoutes = {};
    _currentPageHash = null;
  }

  /// Can pass as an optional parameter whether or not to be strict about pages that get loaded onto the navigation stack.
  ///
  /// If true(default value), pages that can participate will have to use the DynamicRouteParticipator mixin.
  /// else, this restriction will be lifted (not recommended).
  static loadStack(List<Widget> pages, {bool strict = true}) {
    _isStackLoaded = true;
    _pageRoutes = _generatePageStates(pages: pages, strict: strict);
  }

  static Map<int, PageRouteStates> _generatePageStates(
      {required List<Widget> pages, required bool strict}) {
    final Map<int, PageRouteStates> pageRoutes = {};

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

      final currentPageStates = PageRouteStates(
        previousRoute: _generateRoute(previousPage),
        currentRoute: _generateRoute(currentPage)!,
        nextRoute: _generateRoute(nextPage),
        previousHash: previousPage?.hashCode,
        currentHash: currentPage.hashCode,
        nextHash: nextPage?.hashCode,
      );

      pageRoutes[currentPage.hashCode] = currentPageStates;
    }

    return pageRoutes;
  }

  static Route? _generateRoute(Widget? page) {
    if (page == null) return null;

    return MaterialPageRoute(builder: (context) => page);
  }

  /// Push the next page in the stack
  ///
  /// currentWidget is needed to obtain the correct previous and next route in the stack.
  static void pushNext(BuildContext context, {required Widget currentWidget}) {
    final currentPage = _pageRoutes[currentWidget.hashCode];

    assert(currentPage != null,
        "The widget provided was not included in the initial array when loadStack() was called.");
    assert(
        !currentPage!.isLastPage(),
        "There are no more pages to push. This is the end of the flow. "
        "From this page onward, use the Navigator class instead");
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(_currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    _currentPageHash = currentPage!.nextHash;
    Navigator.of(context).push(currentPage.nextRoute!);
  }

  /// Push the first page in the stack
  ///
  /// This is called in the page before the first page included in the navigation stack.
  static void pushFirst(BuildContext context) {
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");

    // TODO Might need a better way for this because .values is O(n)
    final firstPage = _pageRoutes.values.first;
    Navigator.of(context).push(firstPage.currentRoute);
  }

  /// Pop the current page from the stack
  static void popCurrent(BuildContext context,
      {required Widget currentWidget}) {
    final currentPage = _pageRoutes[currentWidget.hashCode];

    assert(currentPage != null,
        "The page this method is called in was not included in the array when loadStack() was called");
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(_currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    _currentPageHash = currentPage!.previousHash;

    Navigator.pop(context);
  }
}

/// For pages that are to be navigated with the StackedNavigator -- pages that gets put in the array
mixin DynamicRouteParticipator {}
