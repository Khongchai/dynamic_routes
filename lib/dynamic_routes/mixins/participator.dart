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

class _ParticipatorNavigator {
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
    navigator.popCurrent(context,
        currentPage: currentWidget, popResult: result);
  }

  Future<T?> pushNext<T>(BuildContext context) {
    return navigator.pushNext(context, currentPage: currentWidget);
  }

  List<Future<T?>> pushFor<T>(BuildContext context, int numberOfPagesToPush) {
    return navigator.pushFor(context, numberOfPagesToPush,
        currentPage: currentWidget);
  }

  bool pushNextOfLastPageCalled() {
    return navigator.pushNextOfLastPageCalled();
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
