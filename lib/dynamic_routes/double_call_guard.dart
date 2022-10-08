import 'package:flutter/cupertino.dart';

/// All navigation methods are built around the idea that when we want to navigate
/// somewhere, it is navigate to somewhere from the current page.
///
/// Unexpected things may happen if we allow > 1 calls from any of the navigation
/// methods. For example, calling [pushNext] twice from the same page doesn't really
/// make sense. [pushNext] means push the page adjacent to the current page.
/// What does it mean to push the adjacent page twice?
///
/// This guard method is here to prevent us from going down the rabbit hole that
/// is the subjective interpretation of the aforementioned point.
///
/// We will begin by grouping our navigation methods into two groups, forward, and
/// back.
///
/// Once a method from either is invoked, nothing should happen when another method
/// from the same group is called.
///
/// Forward: [pushNext], [pushFor], [pushFirst], [pushFirstThenFor]
/// Backward: [popCurrent], [popFor]
mixin DoubleCallGuard {

  @protected
  bool isNextCalled = false;

  @protected
  bool isBackCalled = false;

  @protected
  T? invokeNext<T>(T? Function() nextCallback) {
    if (isNextCalled) {
      debugPrint("Next invoked twice on the same Navigator instance");
      return null;
    }

    isNextCalled = true;

    return nextCallback();
  }

  @protected
  void invokeBack(VoidCallback backCallback) {
    if (isBackCalled) {
      debugPrint("Back invoked twice on the same Navigator instance");
      return;
    }

    isBackCalled = true;

    backCallback();
  }

  @protected
  void resetDoubleCallGuard() {
    isBackCalled = false;
    isNextCalled = false;
  }
}
