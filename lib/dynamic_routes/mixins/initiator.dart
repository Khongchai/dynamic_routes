import 'package:flutter/cupertino.dart';

import '../base_navigators.dart';
import '../scoped_dynamic_routes_manager.dart';

/// Initiator mixin
///
/// The initiator page is the page directly before the flow.
///
/// We enforce both the DynamicRoutesInitiator and the DynamicRoutesParticipator
/// to use StatefulWidget because we need to dispose the scoped singleton in the
/// dispose method.
mixin DynamicRoutesInitiator<T extends StatefulWidget> on State<T> {
  late final _InitiatorNavigator dynamicRoutesInitiator =
      _InitiatorNavigator(widget);
}

class _InitiatorNavigator implements InitiatorNavigator, DynamicRoutesDisposer {
  final _scopedDynamicRoutesManager = ScopedDynamicRoutesManagerSingleton();

  @visibleForTesting
  final Widget initiatorWidget;

  _InitiatorNavigator(this.initiatorWidget);

  @override
  initializeRoutes(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback}) {
    assert(pages.isNotEmpty, "The participators page array cannot be empty");

    // //Ensure clean up of the old one, but not the cache.
    dispose(clearCache: false);

    final newInstance =
        _scopedDynamicRoutesManager.dispenseNewDynamicRoutesInstance(
            participatorWidgets: pages, initiatorWidget: initiatorWidget);

    newInstance.initializeRoutes(pages, lastPageCallback: lastPageCallback);
  }

  @override
  Future<T?> pushFirst<T>(BuildContext context) {
    final instance = _scopedDynamicRoutesManager
        .dispenseParticipatorFromInitiator(initiatorWidget);
    return instance.pushFirst(context);
  }

  @override
  List<Widget> getLoadedPages() {
    final instance = _scopedDynamicRoutesManager
        .dispenseParticipatorFromInitiator(initiatorWidget);

    return instance.getLoadedPages();
  }

  @override
  void dispose({bool clearCache = true}) {
    _scopedDynamicRoutesManager.disposeDynamicRoutesInstance(initiatorWidget,
        clearCacheRelatedData: clearCache);
  }

  dynamic getCache() {
    return _scopedDynamicRoutesManager.getCacheOfThisScope(initiatorWidget,
        isInitiator: true);
  }

  void setCache(dynamic cacheData) {
    _scopedDynamicRoutesManager.setCacheOfThisScope(initiatorWidget, cacheData,
        isInitiator: true);
  }
}
