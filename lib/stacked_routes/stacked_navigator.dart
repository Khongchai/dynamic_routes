import 'package:flutter/material.dart';

/// TODO 1. Why going in to the flow and then exiting doesn't work?
/// TODO 2. after that is resolved, I think our answer actually lies in the array of widgets and their hashes.
class _ScopedStackedRoutesManagerSingleton
    extends _ScopedStackedRoutesManagerImpl {
  static _ScopedStackedRoutesManagerSingleton singletonInstance =
      _ScopedStackedRoutesManagerSingleton._();

  _ScopedStackedRoutesManagerSingleton._();

  factory _ScopedStackedRoutesManagerSingleton() => singletonInstance;
}

class _ScopedStackedRoutesManagerImpl implements ScopedStackedRoutesManager {
  final List<StackedRoutesNavigator> _stackedRoutesInstances = [];

  @override
  StackedRoutesNavigator dispenseNewStackedRoutesInstance() {
    final newStackedRoutesInstance = _StackedRoutesNavigatorImpl();
    _stackedRoutesInstances.add(newStackedRoutesInstance);

    return newStackedRoutesInstance;
  }

  @override
  StackedRoutesNavigator dispenseLatestStackedRoutesNavigator() {
    return _stackedRoutesInstances.last;
  }

  @override
  void disposeLastStackedRoutesInstance() {
    _stackedRoutesInstances.removeLast();
  }
}

abstract class ScopedStackedRoutesManager {
  /// A static StackedRoutes manager that dispenses a scoped StackedRoutes singleton bound to
  /// the lifeCycle of the StatefulWidget page it is attached to.
  StackedRoutesNavigator dispenseNewStackedRoutesInstance();

  StackedRoutesNavigator dispenseLatestStackedRoutesNavigator();

  /// Remove reference to the instantiated object from the _stackedRoutesInstances array.
  void disposeLastStackedRoutesInstance();
}

/// Initiator mixin
///
/// The initiator page is the page directly before the flow.
///
/// We enforce both the StackedRoutesInitiator and the StackedRoutesParticipator to use StatefulWidget
/// because we need to dispose the scoped singleton in the dispose method.
mixin StackedRoutesInitiator<T extends StatefulWidget> on State<T> {
  final _InitiatorNavigator stackedRoutesInitiator = _InitiatorNavigator();
}

class _InitiatorNavigator implements InitiatorNavigator, StackedRoutesDisposer {
  final _scopedStackedRoutesManager =
      _ScopedStackedRoutesManagerSingleton().dispenseNewStackedRoutesInstance();

  @override
  loadStack(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback}) {
    _scopedStackedRoutesManager.loadStack(pages,
        lastPageCallback: lastPageCallback);
  }

  @override
  pushFirst(BuildContext context) {
    _scopedStackedRoutesManager.pushFirst(context);
  }

  @override
  List<Widget> getLoadedPages() {
    return _scopedStackedRoutesManager.getLoadedPages();
  }

  @override
  void dispose() {
    _ScopedStackedRoutesManagerSingleton().disposeLastStackedRoutesInstance();
  }
}

/// Participator mixin
///
/// Participators are the pages that are included in the loadStack method.
///
/// We enforce both the StackedRoutesInitiator and the StackedRoutesParticipator to use StatefulWidget
/// because we need to dispose the scoped singleton in the dispose method.
mixin StackedRoutesParticipator<T extends StatefulWidget> on State<T> {
  final ParticipatorNavigator stackedRoutesParticipator =
      _ParticipatorNavigator();
}

class _ParticipatorNavigator implements ParticipatorNavigator {
  final _scopedStackedRoutesManager = _ScopedStackedRoutesManagerSingleton()
      .dispenseLatestStackedRoutesNavigator();

  @override
  int? getCurrentWidgetHash() {
    return _scopedStackedRoutesManager.getCurrentWidgetHash();
  }

  @override
  void popCurrent(BuildContext context, {required Widget currentPage}) {
    return _scopedStackedRoutesManager.popCurrent(context,
        currentPage: currentPage);
  }

  @override
  void pushNext(BuildContext context, {required Widget currentPage}) {
    _scopedStackedRoutesManager.pushNext(context, currentPage: currentPage);
  }

  @override
  bool pushNextOfLastPageCalled() {
    return _scopedStackedRoutesManager.pushNextOfLastPageCalled();
  }
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
  void dispose();
}

abstract class InitiatorNavigator {
  /// Call this function to load a list of pages to be pushed on to the stack.
  ///
  /// lastPageCallback is what pushNext will do for the final page in the array,
  /// for example, show a dialog box and then push another page or go back to the main page with the Navigator.
  void loadStack(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback});

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

  bool pushNextOfLastPageCalled();
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
    implements InitiatorNavigator, ParticipatorNavigator {
  /// A map between the widget's hash and the doubly-linked list data it belongs to
  late Map<int, PageDLLData> _pageDataMap = {};

  /// Kept primarily for debugging purposes
  int? _currentPageHash;

  /// Use as a safeguard to prevent this being used before the states are loaded.
  bool _isStackLoaded = false;

  bool _isPostLastPage = false;

  Function(BuildContext context)? _lastPageCallback;
}

//TODO also added a mechanism for passing information
class _StackedRoutesNavigatorImpl extends StackedRoutesNavigator {
  @override
  List<Widget> getLoadedPages() {
    return _pageDataMap.values.map((e) => e.currentPage).toList();
  }

  @override
  int? getCurrentWidgetHash() {
    return _currentPageHash;
  }

  @override
  loadStack(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback}) {
    _lastPageCallback = lastPageCallback;
    _isStackLoaded = true;
    _pageDataMap = _generatePageStates(pages: pages);
  }

  Map<int, PageDLLData> _generatePageStates({required List<Widget> pages}) {
    final Map<int, PageDLLData> pageRoutes = {};

    _currentPageHash = pages.first.hashCode;

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
    final currentPageState = _pageDataMap[currentPage.hashCode];

    assert(currentPageState != null,
        "The widget provided was not included in the initial array when loadStack() was called.");
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(_currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    if (currentPageState!.isLastPage()) {
      _lastPageCallback?.call(context);

      _isPostLastPage = true;
    } else {
      _currentPageHash = currentPageState.nextPage.hashCode;
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => currentPageState.nextPage!));
    }
  }

  @override
  void pushFirst(BuildContext context) {
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");

    final firstPage = _pageDataMap.values.first;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => firstPage.currentPage));
  }

  @override
  void popCurrent(BuildContext context, {required Widget currentPage}) {
    final _currentPage = _pageDataMap[currentPage.hashCode];

    assert(_currentPage != null,
        "The page this method is called in was not included in the array when loadStack() was called");
    assert(_isStackLoaded,
        "the loadStack() method should be called first before this can be used.");
    assert(_currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin stacked navigation");

    _currentPageHash = _currentPage!.previousPage.hashCode;

    Navigator.pop(context);
  }

  @override
  bool pushNextOfLastPageCalled() {
    return _isPostLastPage;
  }
}
