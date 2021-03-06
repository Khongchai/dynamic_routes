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

  int? getCurrentWidgetHash() {
    return navigator.getCurrentWidgetHash();
  }

  void popCurrent(BuildContext context) {
    navigator.popCurrent(context, currentPage: currentWidget);
  }

  Future<T?> pushNext<T>(BuildContext context) {
    return navigator.pushNext(context, currentPage: currentWidget);
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
}
