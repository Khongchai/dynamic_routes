import 'package:dynamic_routes/dynamic_routes/double_call_guard.dart';
import 'package:dynamic_routes/dynamic_routes/navigation_logic_provider.dart';
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

class _InitiatorNavigator
    with DoubleCallGuard
    implements InitiatorNavigator, DynamicRoutesDisposer {
  final _scopedDynamicRoutesManager = ScopedDynamicRoutesManagerSingleton();

  @visibleForTesting
  DynamicRoutesNavigator? navigator;

  @visibleForTesting
  final Widget initiatorWidget;

  _InitiatorNavigator(this.initiatorWidget);

  @override
  void initializeRoutes(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback}) {
    assert(pages.isNotEmpty, "The participators page array cannot be empty");

    // //Ensure clean up of the old one, but not the cache.
    dispose(clearCache: false);

    navigator = _scopedDynamicRoutesManager.dispenseNewDynamicRoutesInstance(
        participatorWidgets: pages, initiatorWidget: initiatorWidget);

    navigator!.initializeRoutes(pages, lastPageCallback: lastPageCallback);
  }

  @override
  Future<T?> pushFirst<T>(BuildContext context) async {
    assert(navigator != null, "Did you forget to call initializeRoutes?");

    final result =
        await invokeNavigation<Future<T?>>(() => navigator!.pushFirst(context));

    resetDoubleCallGuard();

    return result;
  }

  @override
  List<Widget> getLoadedPages() {
    assert(navigator != null, "Did you forget to call initializeRoutes?");

    return navigator!.getLoadedPages();
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

  @override
  void setNavigationLogicProvider(
      NavigationLogicProvider navigationLogicProvider) {
    assert(navigator != null, "Did you forget to call initializeRoutes?");

    navigator!.setNavigationLogicProvider(navigationLogicProvider);
  }

  @override
  List<Future<T?>> pushFirstThenFor<T>(
      BuildContext context, int numberOfPagesToPush) {
    assert(navigator != null, "Did you forget to call initializeRoutes?");

    final List<Future<T?>> results = invokeNavigation(
            () => navigator!.pushFirstThenFor(context, numberOfPagesToPush)) ??
        [];

    resetDoubleCallGuard();

    return results;
  }
}
