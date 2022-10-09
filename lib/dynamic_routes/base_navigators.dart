import 'dart:math';

import 'package:dynamic_routes/dynamic_routes/navigation_logic_provider.dart';
import 'package:dynamic_routes/dynamic_routes/page_dll_data.dart';
import 'package:flutter/material.dart';

abstract class DynamicRoutesDisposer {
  /// This is the only method that is allowed to be called repeatedly, even when
  /// it does nothing.
  ///
  /// Reason being, sometimes, you might want to both dispose the references when
  /// the Initiator widget's state is disposed and when the callback is called,
  /// but you are not sure which one should happen first. The fix is to just call
  /// the dispose method in both places (or more).
  void dispose({bool clearCache = true});
}

abstract class InitiatorNavigator {
  /// Call this function to load a list of pages to be pushed on to the array.
  ///
  /// lastPageCallback is what pushNext will do for the final page in the array,
  /// for example, show a dialog box and then push another page or go back to the
  /// main page with the Navigator.
  void initializeRoutes(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback});

  /// Push the first page in the array
  ///
  /// This is called in the page before the first page included in the navigation
  /// array.
  Future<T?> pushFirst<T>(BuildContext context);

  /// This is similar to [pushFor], but is called from the initiator. Internally,
  /// we just call [pushFirst] first, then call [pushFor]. All methods of awaiting
  /// the results mentioned above apply here as well.
  ///
  /// ```dart
  /// dynamicRoutesInitiator.initializeRoutes(...);
  ///  This will push the first page, then push 3 more pages. We are basically pushing a total of 4 pages.
  /// final results = await Future.wait(dynamicRoutesInitiator.pushFirstThenFor(context, 3));
  ///
  /// print(results)  //[resultFromFirst, resultFromSecond, resultFromThird, resultFromFourth]
  /// ```
  List<Future<T?>> pushFirstThenFor<T>(
      BuildContext context, int numberOfPagesToPush);

  /// Pops the pages until the current navigator. Use this in the lastPageCallback
  /// to pop until the initiator page.
  void popUntilInitiatorPage<T>(BuildContext context, {T? popResult});

  List<Widget> getLoadedPages();

  /// Override the current navigation logic.
  ///
  /// Note that this override only what happens when [next] is called. This does
  /// not override the internal state checks.
  void setNavigationLogicProvider(
      NavigationLogicProvider navigationLogicProvider);
}

abstract class ParticipatorNavigator {
  /// Returns the index of the current page. The index corresponds to its position
  /// in the pages array passed to the [initializeRoutes] method of the initiator.
  ///
  /// The index starts from 0.
  ///
  /// This is added to provide more info about the current position of the page
  /// in the participator array.
  ///
  /// This value is obtain by traversing the doubly-linked list data of all pages
  /// in the left direction until we reach the first element. This value is not
  /// cached as a static index value as we'd introduce the overhead of making sure
  /// that the index is always accurate. For example, if you use [Navigator.pop]
  /// instead of [dynamicRoutesParticipator.popCurrent], the static number will
  /// not be accurate.
  int getCurrentPageIndex(Widget currentPage);

  /// Returns how many pages are left until the last page.
  /// 0 means it's the last page.
  ///
  /// getProgressFromCurrentPage() + 1 means push until the last page and then
  /// invoke [lastPageCallback].
  int getProgressFromCurrentPage(Widget currentPage);

  /// Returns the page widget that belongs to the current route
  int? getCurrentWidgetHash();

  /// Push the next page in the array
  ///
  /// currentPage is needed to obtain the correct previous and next route in the
  /// array.
  ///
  /// ex. pushNext(context currentPage: widget);
  Future<T?> pushNext<T>(BuildContext context, {required Widget currentPage});

  /// Pop the current page and all of its sub-routes.
  ///
  /// Prefer this over Navigator.of(context).pop for all participators widget.
  void popCurrent<T>(BuildContext context,
      {required Widget currentPage, T? popResult});

  /// You can reset the flow, eg. go back to the first Participator page, or the Initiator page
  /// with _popFor_.
  ///
  /// _popFor_ guarantees that you will never pop beyond the Initiator page.
  ///
  /// ```dart
  /// // Pop just 2 pages while returning true as the result to those two pages.
  /// dynamicRoutesNavigator.popFor(context, 2, true);
  ///
  /// // This pops until the first participator page.
  /// final currentPageIndex = dynamicRoutesNavigator.getCurrentPageIndex();
  /// dynamicRoutesNavigator.popFor(context, currentPageIndex);
  ///
  /// // Add + 1 to currentPageIndex or just use double.infinity to pop to the Initiator page.
  /// dynamicRoutesNavigator.popFor(context, currentPageIndex);
  /// dynamicRoutesNavigator.popFor(context, double.infinity);
  /// ```
  void popFor<T>(BuildContext context, int numberOfPagesToPop,
      {required Widget currentPage, T? popResult});

  /// You can push multiple pages at once with _pushFor_.
  ///
  /// This method guarantees that you will never push beyond the last Participator page.
  ///
  /// ```dart
  /// // Pushes 4 pages.
  ///
  /// dynamicRoutesParticipator.pushFor(context, 4);
  ///
  /// // Pushes to the last participator page.
  /// dynamicRoutesParticipator.pushFor(context, dynamicRoutesParticipator..getProgressFromCurrentPage());
  ///
  ///
  /// // Pushes to the last participator page + invoke [lastPageCallback].
  /// dynamicRoutesParticipator.pushFor(context, dynamicRoutesParticipator..getProgressFromCurrentPage() + 1);
  /// ```
  List<Future<T?>> pushFor<T>(BuildContext context, int numberOfPagesToPush,
      {required Widget currentPage});
}

/// Let's say that your login flow requires the user to fill in their information
/// and the form is split into 5 pages. However, some of the information in those
/// 5 pages can also be pre-obtained through other means, which would render
/// some of the pages in this flow unnecessary.
///
/// The solution would be to have some sort of navigator that we can just say push
/// conditionally push some of these set of pages in some specific order.
///
///
/// We can begin by marking the participating page with the _DynamicRoutesParticipator_
/// mixin. This would give that component access to the dynamicRoutesParticipator
/// instance that is tied to the /// scope of the initiator page that we'll mark
/// with the _DynamicRoutesInitiator_.
///
/// For the page directly before the flow:
///
/// ```dart
/// class SomeWidget extends StatefulWidget with DynamicRoutesInitiator {
///   //...some code
/// }
///
/// class _SomeWidgetState extends State<SomeWidget> {
///
///   //...some code
///
///   void onButtonPressed() {
///     const isPage4Required = calculateIfPage4IsRequired();
///
///     dynamicRoutesInitiator.initializeRoutes(
///         [
///           Page1(),
///           Page2(),
///           Page3(),
///           if (isPage4Required) Page4(),
///           Page5(),
///         ],
///         lastPageCallback: (context) {
///           // Do something; maybe return to homepage.
///         }
///     );
///   }
///
/// //...some code
///
/// }
/// ```
///
/// And then, in the pages that are included in the array (the "participating" pages).
///
/// ```dart
/// class SomeWidget extends StatefulWidget with DynamicRoutesParticipator{
///   //...some code
/// }
///
/// class _SomeWidgetState extends State<SomeWidget> {
///   void onButtonPressed() => widget.dynamicRoutesParticipator.pushNext(context);
/// //...build methods and whatever
/// }
/// ```
///
/// We can dispose the _DynamicRoutesInitiator_ instance along with the page itself
/// by calling the initiator's _dispose_ method in the state's _dispose_ method.
/// This will also dispose all _DynamicRoutesParticipator_ instances.
///
/// ```dart
///
/// @override
/// void dispose() {
///   dynamicRoutesInitiator.dispose();
///
///   super.dispose();
/// }
///
/// ```
abstract class DynamicRoutesNavigator
    implements InitiatorNavigator, ParticipatorNavigator {
  /// A map between the widget's hash and the doubly-linked list data it belongs to
  late Map<int, PageDLLData> _pageDataMap = {};

  /// Current page widget.
  Widget? _widget;

  /// Use as a safeguard to prevent this being used before the states are loaded.
  bool _isStackLoaded = false;

  Function(BuildContext context)? _lastPageCallback;

  late NavigationLogicProvider _navigationLogicProvider;
}

class DynamicRoutesNavigatorImpl extends DynamicRoutesNavigator {
  DynamicRoutesNavigatorImpl() {
    _navigationLogicProvider = const NavigationLogicProviderImpl();
  }

  @override
  List<Widget> getLoadedPages() {
    return _pageDataMap.values.map((e) => e.widget).toList();
  }

  @override
  int getCurrentPageIndex(Widget currentPage) {
    return _getCurrentPageDLLData(currentPage)
        .getTraversalSteps(PageDLLTraversalDirection.left);
  }

  @override
  int getProgressFromCurrentPage(Widget currentPage) {
    return _getCurrentPageDLLData(currentPage)
        .getTraversalSteps(PageDLLTraversalDirection.right);
  }

  @override
  int? getCurrentWidgetHash() {
    return _widget.hashCode;
  }

  @override
  void initializeRoutes(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback}) {
    _lastPageCallback = lastPageCallback;
    _pageDataMap = _generatePageStates(pages: pages);
    _isStackLoaded = true;
  }

  Map<int, PageDLLData> _generatePageStates({required List<Widget> pages}) {
    final Map<int, PageDLLData> pageAndDLLDataMap = {};

    // If there exist a previous page, add yourself as its nextPage, and add the
    // previous page as your previousPage.
    for (int i = 0; i < pages.length; i++) {
      final Widget currentPage = pages[i];

      final currentPageData = PageDLLData(
        widget: currentPage,
      );

      final PageDLLData? previousPage =
          i - 1 < 0 ? null : pageAndDLLDataMap[pages[i - 1].hashCode];
      if (previousPage != null) {
        previousPage.setAsNext(currentPageData);
      }

      pageAndDLLDataMap[currentPage.hashCode] = currentPageData;
    }

    return pageAndDLLDataMap;
  }

  @override
  Future<T?> pushNext<T>(BuildContext context, {required Widget currentPage}) {
    assert(
        _widget != null,
        "pushFirst() "
        "of the dynamicRoutesInitiator instance should be called before calling "
        "this method on a participator");

    final currentPageState = _getCurrentPageDLLData(currentPage);

    if (currentPageState.isLastPage()) {
      _lastPageCallback?.call(context);

      return Future.value(null);
    } else {
      _widget = currentPageState.nextPage!.widget;

      return _navigationLogicProvider
          .next(NextArguments(context: context, nextPage: _widget!));
    }
  }

  @override
  Future<T?> pushFirst<T>(BuildContext context) {
    assert(
        _isStackLoaded,
        "the initializeRoutes() method should be called first before this can "
        "be used.");

    final firstPage = _pageDataMap.values.first;

    _widget = firstPage.widget;

    return _navigationLogicProvider
        .next(NextArguments(context: context, nextPage: _widget!));
  }

  @override
  List<Future<T?>> pushFirstThenFor<T>(
      BuildContext context, int numberOfPagesToPush) {
    final firstResult = pushFirst<T>(context);

    final moreResults =
        pushFor<T>(context, numberOfPagesToPush, currentPage: _widget!);

    return [firstResult, ...moreResults];
  }

  @override
  void popCurrent<T>(BuildContext context,
      {required Widget currentPage, T? popResult}) async {
    assert(
        _widget != null,
        "pushFirst() "
        "of the dynamicRoutesInitiator instance should be called before calling "
        "this method on a participator");

    final pageData = _getCurrentPageDLLData(currentPage);

    // If the right-side expression is null, then this is the first page and
    // popping this should destroy the whole navigation state.
    _widget = pageData.previousPage?.widget;

    return _navigationLogicProvider.back(BackArguments(
        context: context,
        currentPage: pageData.widget,
        result: popResult,
        previousPage: _widget));
  }

  @override
  void popUntilInitiatorPage<T>(BuildContext context, {T? popResult}) async {
    assert(
        _isStackLoaded,
        "the initializeRoutes() method should be called first before this can "
        "be used.");

    final bool canPop = _widget != null;
    if (!canPop) {
      debugPrint(
          "There is nothing to pop; pushFirst() has not yet been called");
      return;
    }

    final _currentPage = _getCurrentPageDLLData(_widget);
    final pagesLeftUntilFirstPage =
        _currentPage.getTraversalSteps(PageDLLTraversalDirection.left);

    popFor(context, pagesLeftUntilFirstPage + 1,
        currentPage: _currentPage.widget, popResult: popResult);
  }

  @override
  List<Future<T?>> pushFor<T>(BuildContext context, int numberOfPagesToPush,
      {required Widget currentPage}) {
    assert(
        _widget != null,
        "pushFirst() "
        "of the dynamicRoutesInitiator instance should be called before calling "
        "this method on a participator");

    if (numberOfPagesToPush == 0) return [];

    final _currentPage = _getCurrentPageDLLData(currentPage);

    final pagesLeft =
        _currentPage.getTraversalSteps(PageDLLTraversalDirection.right);
    // + 1 because all pages length + lastPageCallback.
    final pushablePages = pagesLeft + 1;
    final loopCount = min(numberOfPagesToPush, pushablePages);

    final List<Future<T?>> results = [];
    for (int i = 0; i < loopCount; i++) {
      results.add(pushNext<T>(context, currentPage: _widget!));
    }

    return results;
  }

  @override
  void popFor<T>(BuildContext context, int numberOfPagesToPop,
      {required Widget currentPage, T? popResult}) async {
    if (numberOfPagesToPop == 0) return;

    assert(
        _widget != null,
        "pushFirst() "
        "of the dynamicRoutesInitiator instance should be called before calling "
        "this method on a participator");

    final _currentPage = _getCurrentPageDLLData(currentPage);

    final currentPageIndex =
        _currentPage.getTraversalSteps(PageDLLTraversalDirection.left);
    // + 1 because we allow the first participator page to be popped as well.
    final poppablePages = currentPageIndex + 1;
    final loopCount = min(numberOfPagesToPop, poppablePages);
    for (int i = 0; i < loopCount; i++) {
      popCurrent(context, currentPage: _widget!, popResult: popResult);
    }
  }

  PageDLLData _getCurrentPageDLLData(Widget? currentPage) {
    final _currentPage = _pageDataMap[currentPage.hashCode];

    assert(
        _currentPage != null,
        "The page this method is called in was not included in the array when "
        "iniitalizeRoutes() was called");
    assert(
        _isStackLoaded,
        "the iniitalizeRoutes() method should be called first before this can be "
        "used.");
    assert(
        _widget != null,
        "Call pushFirst(context) before the first page of this flow to begin "
        "dynamic navigation");

    return _currentPage!;
  }

  @override
  void setNavigationLogicProvider(
      NavigationLogicProvider navigationLogicProvider) {
    _navigationLogicProvider = navigationLogicProvider;
  }
}
