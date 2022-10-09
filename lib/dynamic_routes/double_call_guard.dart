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
/// If either of these methods below are called, the call guard will lock the
/// navigation from happening from the same instance [resetDoubleCallGuard] is
/// called.
///
/// Forward: [pushNext], [pushFor], [pushFirst], [pushFirstThenFor]
/// Backward: [popCurrent], [popFor]
///
/// The guard will reset when the future from [next] completes.
///
/// [initializeRoutes] does not count as a navigation method and is not guarded.
mixin DoubleCallGuard {
  @protected
  bool isNavigated = false;

  @protected
  T? invokeNavigation<T>(T? Function() nextCallback) {
    if (isNavigated) {
      debugPrint(
          "⚠️A navigation method invoked more than once on the same Navigator "
          "instance the widget can navigate.  ⚠️");
      debugPrint("⚠️We are letting only the first invocation through.  ⚠️");
      return null;
    }

    isNavigated = true;

    return nextCallback();
  }

  @protected
  void resetDoubleCallGuard() {
    isNavigated = false;
  }
}
