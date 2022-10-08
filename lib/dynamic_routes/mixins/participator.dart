import 'package:dynamic_routes/dynamic_routes/double_call_guard.dart';
import 'package:flutter/cupertino.dart';

import '../base_navigators.dart';
import '../scoped_dynamic_routes_manager.dart';

/// Participator mixin
///
/// Participators are the pages that are included in the initializeRoutes method.
///
/// We enforce both the DynamicRoutesInitiator and the DynamicRoutesParticipator
/// to use StatefulWidget because we need to dispose the scoped singleton in the
/// dispose method.
mixin DynamicRoutesParticipator<T extends StatefulWidget> on State<T> {
  late final _ParticipatorNavigator dynamicRoutesParticipator =
      _ParticipatorNavigator(widget);
}

class _ParticipatorNavigator with DoubleCallGuard {
  final _scopedDynamicRoutesManager = ScopedDynamicRoutesManagerSingleton();

  @visibleForTesting
  late final DynamicRoutesNavigator navigator;

  @visibleForTesting
  late final Widget currentWidget;

  _ParticipatorNavigator(Widget participatorWidget) {
    navigator = _scopedDynamicRoutesManager
        .dispenseNavigatorFromParticipator(participatorWidget);

    currentWidget = participatorWidget;
  }

  int getCurrentPageIndex() {
    return navigator.getCurrentPageIndex(currentWidget);
  }

  int getProgressFromCurrentPage() {
    return navigator.getProgressFromCurrentPage(currentWidget);
  }

  int? getCurrentWidgetHash() {
    return navigator.getCurrentWidgetHash();
  }

  void popCurrent<T>(BuildContext context, [T? result]) {
    invokeBack(() => navigator.popCurrent(context,
        currentPage: currentWidget, popResult: result));
  }

  Future<T?> pushNext<T>(BuildContext context) async {
    final result = await invokeNext<Future<T?>>(
        () => navigator.pushNext(context, currentPage: currentWidget));

    resetDoubleCallGuard();

    return result;
  }

  List<Future<T?>> pushFor<T>(BuildContext context, int numberOfPagesToPush) {
    final List<Future<T?>> result = invokeNext(() => navigator.pushFor(
            context, numberOfPagesToPush,
            currentPage: currentWidget)) ??
        [];

    resetDoubleCallGuard();

    return result;
  }

  dynamic getCache() {
    return _scopedDynamicRoutesManager.getCacheOfThisScope(currentWidget,
        isInitiator: false);
  }

  void setCache(dynamic cacheData) {
    _scopedDynamicRoutesManager.setCacheOfThisScope(currentWidget, cacheData,
        isInitiator: false);
  }

  void popFor(BuildContext context, int amount) {
    navigator.popFor(context, amount, currentPage: currentWidget);
  }
}
