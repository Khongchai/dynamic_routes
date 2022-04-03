import 'package:flutter/material.dart';

/// Concrete singleton implementation
///
class StackedRoutesSingleton extends _StackedRoutesNavigatorImpl {
  static final _singletonInstance = StackedRoutesSingleton._();

  StackedRoutesSingleton._();

  factory StackedRoutesSingleton() => _singletonInstance;
}

/// Initiator mixin
///
mixin StackedRoutesInitiator {
  final InitiatorNavigator stackedRoutesNavigator = _InitiatorNavigator();
}

class _InitiatorNavigator implements InitiatorNavigator {
  final StackedRoutesSingleton _stackedRoutesNavigator =
      StackedRoutesSingleton();

  @override
  loadStack(List<Widget> pages, {bool strict = true}) {
    _stackedRoutesNavigator.loadStack(pages, strict: strict);
  }

  @override
  pushFirst(BuildContext context) {
    _stackedRoutesNavigator.pushFirst(context);
  }

  @override
  List<Widget> getLoadedPages() {
    return _stackedRoutesNavigator.getLoadedPages();
  }
}

mixin StackedRoutesCleaner {
  final StackedRoutesNavigatorCleaner stackedRoutesNavigator =
      _StackedRoutesCleaner();
}

class _StackedRoutesCleaner implements StackedRoutesNavigatorCleaner {
  final StackedRoutesSingleton _stackedRoutesNavigator =
      StackedRoutesSingleton();

  @override
  void clearData() {
    _stackedRoutesNavigator.clearData();
  }
}

/// Participator mixin
mixin StackedRoutesParticipator {
  final ParticipatorNavigator stackedRoutesNavigator = _ParticipatorNavigator();
}

class _ParticipatorNavigator implements ParticipatorNavigator {
  final StackedRoutesSingleton _stackedRoutesNavigator =
      StackedRoutesSingleton();

  @override
  void clearData() {
    _stackedRoutesNavigator.clearData();
  }

  @override
  int? getCurrentWidgetHash() {
    return _stackedRoutesNavigator.getCurrentWidgetHash();
  }

  @override
  void popCurrent(BuildContext context, {required Widget currentWidget}) {
    return _stackedRoutesNavigator.popCurrent(context,
        currentWidget: currentWidget);
  }

  @override
  void pushNext(BuildContext context, {required Widget currentWidget}) {
    _stackedRoutesNavigator.pushNext(context, currentWidget: currentWidget);
  }
}

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

abstract class StackedRoutesNavigatorCleaner {
  /// reset all data
  void clearData();
}

abstract class InitiatorNavigator {
  /// Can pass as an optional parameter whether or not to be strict about pages that get loaded onto the navigation stack.
  ///
  /// If true, pages that can participate will have to use the DynamicRouteParticipator mixin.
  /// else, this restriction will be lifted (not recommended).
  void loadStack(List<Widget> pages, {bool strict = true});

  /// Push the first page in the stack
  ///
  /// This is called in the page before the first page included in the navigation stack.
  void pushFirst(BuildContext context);

  List<Widget> getLoadedPages();
}

abstract class ParticipatorNavigator implements StackedRoutesNavigatorCleaner {
  /// Returns the page widget that belongs to the current route
  int? getCurrentWidgetHash();

  /// Push the next page in the stack
  ///
  /// currentWidget is needed to obtain the correct previous and next route in the stack.
  void pushNext(BuildContext context, {required Widget currentWidget});

  /// Pop the current page from the stack
  void popCurrent(BuildContext context, {required Widget currentWidget});
}

/// Let's say that your login flow requires the user to fill in their information and the form is split into 5 pages.
/// However, some of the information in those 5 pages can also be pre-obtained through other means, which would render
/// some of the pages in this flow unnecessary.
///
/// The solution would be to have a stacked navigator that we can just say push this set of pages in order.
///
/// ## Instructions:
///
/// First, we'd need to mark the participating page with the DynamicRouteParticipator mixin.
/// This would give that component access to the stackedRoutesNavigator singleton.
///
/// For the page directly before the flow, we'll have to mark it with the StackedRoutesInitiator.
///
/// ```dart
/// class SomeWidget extends StatefulWidget with StackedRouteInitiator{
///  //...some code
/// }
///
/// class _SomeWidgetState extends State<Page4> {
///   void onButtonPressed() => widget.stackedRoutesNavigator.pushNext(context, currentWidget: widget);
///   //...some code
/// }
/// ```
///
/// And then in the pages that will be included within the stack
///
/// ```dart
/// class SomeWidget extends StatefulWidget with StackedRoutesParticipator{
///   //...some code
/// }
///
/// class _SomeWidgetState extends State<Page4> {
///   void onButtonPressed() => widget.stackedRoutesNavigator.pushNext(context, currentWidget: widget);
///    //...build methods and whatever
/// }
///```
///
/// Don't forget to reset the data with the clearData method at the last page in the flow.
///
/// ```dart
/// class SomeLastWidget extends StatefulWidget with StackedRoutesParticipator{
/// }
/// class _SomeLastWidgetState extends State<Page4> {
///   void onButtonPressed() {
///     widget.stackedRoutesNavigator.clearData();
///
///     // No more pages to push so here, so from this page forward, we'll go back to using Navigator.
///     Navigator.of(context).pushNamed(...);
///   };
/// }
///```
///
/// Or if the last page of this flow is not really the last page in a bigger flow, eg. even after the last page in the stack
/// there exist still a possibility for the user to return to this page, then you can opt out of cleaning up the data and do that later.
/// By implementing the StackedRoutesNavigatorCleaner mixin, the class will have access to the clearData() method which can be use to reset the
/// stack's singleton data to the default values.
///
/// Navigator.of(context).pushAndRemoveUntil is a good example of why you might need the clearData() method to help you clear out all data from ram.
/// When all routes are removed, indeed routes are popped from the Navigator stack, but the StackedRoutesNavigator mirrors that relationship with an abstraction
/// that lives in the ram. Flutter doesn't know that this singleton needs to be garbage-collected, so we will have to do that by hand.
///
/// This is, however, entirely optional as the next time the StackedRoutesNavigator singleton instance is used, all values will be rewritten anyway.
///
///
abstract class StackedRoutesNavigator
    implements
        InitiatorNavigator,
        ParticipatorNavigator,
        StackedRoutesNavigatorCleaner {
  /// A map between the widget's hash and the doubly-linked list data it belongs to
  @protected
  late Map<int, PageDLLData> pageDataMap = {};

  /// Kept primarily for debugging purposes
  @protected
  int? currentPageHash;

  /// Use as a safeguard to prevent this being used before the states are loaded.
  @protected
  bool isStackLoaded = false;
}

//TODO also added a mechanism for passing information
class _StackedRoutesNavigatorImpl extends StackedRoutesNavigator {
  @override
  List<Widget> getLoadedPages() {
    return pageDataMap.values.map((e) => e.currentPage).toList();
  }

  @override
  int? getCurrentWidgetHash() {
    return currentPageHash;
  }

  @override
  clearData() {
    isStackLoaded = false;
    pageDataMap = {};
    currentPageHash = null;
  }

  @override
  loadStack(List<Widget> pages, {bool strict = true}) {
    isStackLoaded = true;
    pageDataMap = _generatePageStates(pages: pages, strict: strict);
  }

  Map<int, PageDLLData> _generatePageStates(
      {required List<Widget> pages, required bool strict}) {
    final Map<int, PageDLLData> pageRoutes = {};

    currentPageHash = pages.first.hashCode;

    for (int i = 0; i < pages.length; i++) {
      final previousPage = i - 1 < 0 ? null : pages[i - 1];
      final nextPage = i + 1 >= pages.length ? null : pages[i + 1];
      final currentPage = pages[i];

      final pageIsMarkedForDynamicRouting =
          currentPage is StackedRoutesParticipator;
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

  @override
  void pushNext(BuildContext context, {required Widget currentWidget}) {
    final currentPageState = pageDataMap[currentWidget.hashCode];

    assert(currentPageState != null,
        "The widget provided was not included in the initial array when loadStack() was called.");
    assert(
        !currentPageState!.isLastPage(),
        "There are no more pages to push. This is the end of the flow. "
        "From this page onward, use the Navigator class instead");
    assert(isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    currentPageHash = currentPageState!.nextPage.hashCode;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => currentPageState.nextPage!));
  }

  @override
  void pushFirst(BuildContext context) {
    assert(isStackLoaded,
        "the loadStack() method should be called first before this can be used.");

    final firstPage = pageDataMap.values.first;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => firstPage.currentPage));
  }

  @override
  void popCurrent(BuildContext context, {required Widget currentWidget}) {
    final currentPage = pageDataMap[currentWidget.hashCode];

    assert(currentPage != null,
        "The page this method is called in was not included in the array when loadStack() was called");
    assert(isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    currentPageHash = currentPage!.previousPage.hashCode;

    Navigator.pop(context);
  }
}
