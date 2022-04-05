import 'package:flutter/material.dart';

//TODO make scoped singleton => this means that the singleton will have to be a manager of some sort instead of the stackedRoutes

/// Concrete singleton implementation
///
class StackedRoutesSingleton extends _StackedRoutesNavigatorImpl {
  static final _singletonInstance = StackedRoutesSingleton._();

  StackedRoutesSingleton._();

  factory StackedRoutesSingleton() => _singletonInstance;
}

/// Initiator mixin
///
/// The initiator page is the page directly before the flow.
///
/// We enforce both the StackedRoutesInitiator and the StackedRoutesParticipator to use StatefulWidget
/// because we need to dispose the scoped singleton in the dispose method.
mixin StackedRoutesInitiator<T extends StatefulWidget> on State<T> {
  final InitiatorNavigator stackedRoutesNavigator = _InitiatorNavigator();
}

class _InitiatorNavigator implements InitiatorNavigator {
  final StackedRoutesSingleton _stackedRoutesNavigator =
      StackedRoutesSingleton();

  @override
  loadStack(List<Widget> pages, VoidCallback lastPageCallback) {
    _stackedRoutesNavigator.loadStack(pages, lastPageCallback);
  }

  @override
  pushFirst(BuildContext context) {
    _stackedRoutesNavigator.pushFirst(context);
  }

  @override
  List<Widget> getLoadedPages() {
    return _stackedRoutesNavigator.getLoadedPages();
  }

  @override
  dispose() {
    _stackedRoutesNavigator.dispose();
  }
}

/// Participator mixin
///
/// Participators are the pages that are included in the loadStack method.
///
/// We enforce both the StackedRoutesInitiator and the StackedRoutesParticipator to use StatefulWidget
/// because we need to dispose the scoped singleton in the dispose method.
mixin StackedRoutesParticipator<T extends StatefulWidget> on State<T> {
  final ParticipatorNavigator stackedRoutesNavigator = _ParticipatorNavigator();
}

class _ParticipatorNavigator implements ParticipatorNavigator {
  final StackedRoutesSingleton _stackedRoutesNavigator =
      StackedRoutesSingleton();

  @override
  int? getCurrentWidgetHash() {
    return _stackedRoutesNavigator.getCurrentWidgetHash();
  }

  @override
  void popCurrent(BuildContext context, {required Widget currentPage}) {
    return _stackedRoutesNavigator.popCurrent(context,
        currentPage: currentPage);
  }

  @override
  void pushNext(BuildContext context, {required Widget currentPage}) {
    _stackedRoutesNavigator.pushNext(context, currentPage: currentPage);
  }

  @override
  bool get isPostLastPage => _stackedRoutesNavigator.isPostLastPage;
}

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

abstract class StackedRoutesDisposer {
  /// TODO actually dispose a singleton rather than just resetting the data.
  void dispose();
}

abstract class InitiatorNavigator implements StackedRoutesDisposer {
  /// Call this function to load a list of pages to be pushed on to the stack.
  ///
  /// lastPageCallback is what pushNext will do for the final page in the array,
  /// for example, show a dialog box and then push another page or go back to the main page with the Navigator.
  void loadStack(List<Widget> pages, VoidCallback lastPageCallback);

  /// Push the first page in the stack
  ///
  /// This is called in the page before the first page included in the navigation stack.
  void pushFirst(BuildContext context);

  List<Widget> getLoadedPages();
}

abstract class ParticipatorNavigator {
  /// Returns the page widget that belongs to the current route
  int? getCurrentWidgetHash();

  /// Push the next page in the stack
  ///
  /// currentPage is needed to obtain the correct previous and next route in the stack.
  ///
  /// ex. pushNext(context, currentPage: widget);
  void pushNext(BuildContext context, {required Widget currentPage});

  /// Pop the current page from the stack
  void popCurrent(BuildContext context, {required Widget currentPage});

  bool get isPostLastPage;
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
///   void onButtonPressed() => widget.stackedRoutesNavigator.pushNext(context, currentPage: widget);
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
///   void onButtonPressed() => widget.stackedRoutesNavigator.pushNext(context, currentPage: widget);
///    //...build methods and whatever
/// }
///```
///
/// We can garbage collect the scoped-singleton instance by calling the navigator's dispose method in the
/// initiator page's dispose method.
///
/// ```dart
/// @override
/// dispose(){
///   stackedRoutesNavigator.dispose();
///
///   super.dispose();
/// }
/// ```
abstract class StackedRoutesNavigator
    implements
        InitiatorNavigator,
        ParticipatorNavigator,
        StackedRoutesDisposer {
  /// A map between the widget's hash and the doubly-linked list data it belongs to
  @protected
  late Map<int, PageDLLData> pageDataMap = {};

  /// Kept primarily for debugging purposes
  @protected
  int? currentPageHash;

  /// Use as a safeguard to prevent this being used before the states are loaded.
  @protected
  bool isStackLoaded = false;

  /// Is set to true when pushNext of the last page has been called.
  @protected
  bool isPostLastPage = false;

  @protected
  VoidCallback lastPageCallback = () {};
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
  dispose() {
    isStackLoaded = false;
    pageDataMap = {};
    currentPageHash = null;
    lastPageCallback = () {};
    isPostLastPage = false;
  }

  @override
  loadStack(List<Widget> pages, VoidCallback lastPageCallback) {
    this.lastPageCallback = lastPageCallback;
    isStackLoaded = true;
    pageDataMap = _generatePageStates(pages: pages);
  }

  Map<int, PageDLLData> _generatePageStates({required List<Widget> pages}) {
    final Map<int, PageDLLData> pageRoutes = {};

    currentPageHash = pages.first.hashCode;

    for (int i = 0; i < pages.length; i++) {
      final previousPage = i - 1 < 0 ? null : pages[i - 1];
      final nextPage = i + 1 >= pages.length ? null : pages[i + 1];
      final currentPage = pages[i];

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
  void pushNext(BuildContext context, {required Widget currentPage}) {
    final currentPageState = pageDataMap[currentPage.hashCode];

    assert(currentPageState != null,
        "The widget provided was not included in the initial array when loadStack() was called.");
    assert(isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    if (currentPageState!.isLastPage()) {
      lastPageCallback();

      isPostLastPage = true;
    } else {
      currentPageHash = currentPageState.nextPage.hashCode;
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => currentPageState.nextPage!));
    }
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
  void popCurrent(BuildContext context, {required Widget currentPage}) {
    final _currentPage = pageDataMap[currentPage.hashCode];

    assert(_currentPage != null,
        "The page this method is called in was not included in the array when loadStack() was called");
    assert(isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    currentPageHash = _currentPage!.previousPage.hashCode;

    Navigator.pop(context);
  }
}
