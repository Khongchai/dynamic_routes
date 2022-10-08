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

  DynamicRoutesNavigator? _initiatorInstance;

  @visibleForTesting
  final Widget initiatorWidget;

  _InitiatorNavigator(this.initiatorWidget);

  @override
  void initializeRoutes(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback}) {
    assert(pages.isNotEmpty, "The participators page array cannot be empty");

    // //Ensure clean up of the old one, but not the cache.
    dispose(clearCache: false);

    _initiatorInstance =
        _scopedDynamicRoutesManager.dispenseNewDynamicRoutesInstance(
            participatorWidgets: pages, initiatorWidget: initiatorWidget);

    _initiatorInstance!
        .initializeRoutes(pages, lastPageCallback: lastPageCallback);
  }

  @override
  Future<T?> pushFirst<T>(BuildContext context) async {
    assert(
        _initiatorInstance != null, "Did you forget to call initializeRoutes?");

    final result = await invokeNext<Future<T?>>(
        () => _initiatorInstance!.pushFirst(context));

    resetDoubleCallGuard();

    return result;
  }

  @override
  List<Widget> getLoadedPages() {
    assert(
        _initiatorInstance != null, "Did you forget to call initializeRoutes?");

    return _initiatorInstance!.getLoadedPages();
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
    assert(
        _initiatorInstance != null, "Did you forget to call initializeRoutes?");

    _initiatorInstance!.setNavigationLogicProvider(navigationLogicProvider);
  }

  @override
  List<Future<T?>> pushFirstThenFor<T>(
      BuildContext context, int numberOfPagesToPush) {
    assert(
        _initiatorInstance != null, "Did you forget to call initializeRoutes?");

    final List<Future<T?>> results = invokeNext(() => _initiatorInstance!
            .pushFirstThenFor(context, numberOfPagesToPush)) ??
        [];

    resetDoubleCallGuard();

    return results;
  }
}
