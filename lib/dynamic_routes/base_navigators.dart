import 'dart:math';

import 'package:dynamic_routes/dynamic_routes/page_dll_data.dart';
import 'package:flutter/material.dart';

abstract class DynamicRoutesDisposer {
  /// This is the only method that is allowed to be called repeatedly, even when
  /// it does nothing.
  ///
  /// Reason being, sometimes, you might want to both dispose the references when
  /// the Initiator widget's state /// is disposed and when the callback is called,
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

  List<Widget> getLoadedPages();
}

abstract class ParticipatorNavigator {
  /// Returns the index of the current page. The index corresponds to its position
  /// in the pages array passed to the [initializeRoutes] method of the initiator.
  ///
  /// The index starts from 0.
  int? getCurrentPageIndex();

  /// Returns the page widget that belongs to the current route
  int? getCurrentWidgetHash();

  /// Push the next page in the array
  ///
  /// currentPage is needed to obtain the correct previous and next route in the
  /// array.
  ///
  /// ex. pushNext(context currentPage: widget);
  Future<T?> pushNext<T>(BuildContext context, {required Widget currentPage});

  /// Pop the current page from the array
  ///
  /// Prefer this over Navigator.of(context).pop for all participators widget.
  void popCurrent<T>(BuildContext context,
      {required Widget currentPage, T? popResult});

  /// Pop for a specified number of pages. Regardless of the provided number,
  /// it will only pop until the initiator page.
  ///
  /// If you wanna pop until the navigator page, you can just do
  ///
  /// ```dart
  ///   popFor(double.infinity)
  /// ```
  ///
  /// or
  ///
  /// ```dart
  ///   popFor(dynamicRoutesParticipator.getCurrentPageIndex() + 1)
  /// ```
  void popFor<T>(BuildContext context, int numberOfPagesToPop,
      {required Widget currentPage, T? popResult});

  /// For verifying the progress of the flow. If this is true, the flow has ended.
  bool pushNextOfLastPageCalled();
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

  /// Kept primarily for debugging purposes
  int? _currentPageHash;

  /// Use as a safeguard to prevent this being used before the states are loaded.
  bool _isStackLoaded = false;

  bool _isPostLastPage = false;

  /// This is added to provide more info about the current position of the page
  /// in the participator array.
  ///
  /// If you use [Navigator.pop] instead of [dynamicRoutesParticipator.popCurrent],
  /// this number might not be accurate.
  int? _currentPageIndex;

  Function(BuildContext context)? _lastPageCallback;
}

class DynamicRoutesNavigatorImpl extends DynamicRoutesNavigator {
  @override
  List<Widget> getLoadedPages() {
    return _pageDataMap.values.map((e) => e.currentPage).toList();
  }

  @override
  int? getCurrentPageIndex() {
    return _currentPageIndex;
  }

  @override
  int? getCurrentWidgetHash() {
    return _currentPageHash;
  }

  @override
  void initializeRoutes(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback, dynamic scopedCache}) {
    _lastPageCallback = lastPageCallback;
    _isStackLoaded = true;
    _pageDataMap = _generatePageStates(pages: pages);
  }

  Map<int, PageDLLData> _generatePageStates({required List<Widget> pages}) {
    final Map<int, PageDLLData> pageRoutes = {};

    _currentPageHash = pages.first.hashCode;
    _currentPageIndex = 0;

    for (int i = 0; i < pages.length; i++) {
      final previousPage = i - 1 < 0 ? null : pages[i - 1];
      final nextPage = i + 1 >= pages.length ? null : pages[i + 1];
      final currentPage = pages[i];

      final currentPageStates = PageDLLData(
        previousPage: previousPage,
        currentPage: currentPage,
        nextPage: nextPage,
        index: i,
      );

      pageRoutes[currentPage.hashCode] = currentPageStates;
    }

    return pageRoutes;
  }

  @override
  Future<T?> pushNext<T>(BuildContext context, {required Widget currentPage}) {
    assert(
        _currentPageIndex != null && _currentPageHash != null,
        "pushFirst() "
        "of the dynamicRoutesInitiator instance should be called before calling "
        "this method on a participator");

    final currentPageState = _getCurrentPageDLLData(currentPage);

    if (currentPageState.isLastPage()) {
      _lastPageCallback?.call(context);

      _isPostLastPage = true;

      return Future.value(null);
    } else {
      _currentPageHash = currentPageState.nextPage.hashCode;
      _currentPageIndex = _currentPageIndex! + 1;
      return Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => currentPageState.nextPage!));
    }
  }

  @override
  Future<T?> pushFirst<T>(BuildContext context) {
    assert(
        _isStackLoaded,
        "the iniitalizeRoutes() method should be called first before this can "
        "be used.");

    final firstPage = _pageDataMap.values.first;
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => firstPage.currentPage));
  }

  @override
  void popCurrent<T>(BuildContext context,
      {required Widget currentPage, T? popResult}) async {
    assert(
        _currentPageIndex != null && _currentPageHash != null,
        "pushFirst() "
        "of the dynamicRoutesInitiator instance should be called before calling "
        "this method on a participator");

    final _currentPage = _getCurrentPageDLLData(currentPage);

    _currentPageHash = _currentPage.previousPage.hashCode;
    _currentPageIndex = _currentPageIndex! - 1;

    return Navigator.of(context).pop(popResult);
  }

  @override
  void popFor<T>(BuildContext context, int numberOfPagesToPop,
      {required Widget currentPage, T? popResult}) async {
    final _currentPage = _getCurrentPageDLLData(currentPage);

    // + 1 because we allow the first participator page to be popped as well.
    final poppablePages = _currentPage.index + 1;
    final loopCount = min(numberOfPagesToPop, poppablePages);
    for (int i = 0; i < loopCount; i++) {
      Navigator.of(context).pop(popResult);
    }
  }

  @override
  bool pushNextOfLastPageCalled() {
    return _isPostLastPage;
  }

  PageDLLData _getCurrentPageDLLData(Widget currentPage) {
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
        _currentPageHash != null,
        "Call pushFirst(context) before the first page of this flow to begin "
        "dynamic navigation");

    return _currentPage!;
  }
}
