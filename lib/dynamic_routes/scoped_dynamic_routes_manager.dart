import 'package:flutter/material.dart';

import 'base_navigators.dart';

class ScopedDynamicRoutesManagerSingleton
    extends _ScopedDynamicRoutesManagerImpl {
  static ScopedDynamicRoutesManagerSingleton singletonInstance =
      ScopedDynamicRoutesManagerSingleton._();

  ScopedDynamicRoutesManagerSingleton._();

  factory ScopedDynamicRoutesManagerSingleton() => singletonInstance;
}

class _ScopedDynamicRoutesManagerImpl
    implements ScopedDynamicRoutesManager, ScopedCacheManager {
  /// The map is a map of all hashCode of the widgets in a array.
  final Map<int, DynamicRoutesNavigator?> _dynamicRoutesInstances = {};

  /// Get participators from initiator widget hashcode
  final Map<int, List<Widget>?> _initiatorAndParticipatorsMap = {};

  /// Get initiator from participator widget hashcode
  final Map<int, Widget?> _participatorAndInitiatorMap = {};

  /// Get cache from initiator widget hashCode
  final Map<int, dynamic> _initiatorCacheMap = {};

  @override
  DynamicRoutesNavigator dispenseNewDynamicRoutesInstance({
    required List<Widget> participatorWidgets,
    required Widget initiatorWidget,
  }) {
    final newDynamicRoutesInstance = DynamicRoutesNavigatorImpl();

    // Bind all widgets in the array to this newDynamicRoutesInstance
    for (final widget in participatorWidgets) {
      assert(
          _dynamicRoutesInstances[widget.hashCode] == null,
          "The participator instance ${widget.hashCode} is already bound to a "
          "navigation scope. instances and cannot be assigned again until "
          "the current instances are disposed.");
      _dynamicRoutesInstances[widget.hashCode] = newDynamicRoutesInstance;

      _participatorAndInitiatorMap[widget.hashCode] = initiatorWidget;
    }

    // Save reference for the disposition of all references to widgets in the
    // array from this manager
    _initiatorAndParticipatorsMap[initiatorWidget.hashCode] =
        participatorWidgets;

    return newDynamicRoutesInstance;
  }

  @override
  DynamicRoutesNavigator dispenseNavigatorFromParticipator(
      Widget participator) {
    final queriedInstance = _dynamicRoutesInstances[participator.hashCode];
    assert(queriedInstance != null,
        "The widget provided is not tied to any _dynamicRoutesInstances.");

    return queriedInstance!;
  }

  @override
  DynamicRoutesNavigator dispenseParticipatorFromInitiator(
      Widget initiatorWidget) {
    final queriedInitiator =
        _initiatorAndParticipatorsMap[initiatorWidget.hashCode];
    assert(
        queriedInitiator != null,
        "The widget provided is not tied to any _dynamicRoutesInstances."
        " Did you forget to call initializeRoutes()?");

    final queriedParticipator =
        _dynamicRoutesInstances[queriedInitiator!.first.hashCode];

    return queriedParticipator!;
  }

  @override
  void setCacheOfThisScope(Widget widget, dynamic newCacheValue,
      {required bool isInitiator}) {
    if (isInitiator) {
      _initiatorCacheMap[widget.hashCode] = newCacheValue;
    } else {
      final initiator = _participatorAndInitiatorMap[widget.hashCode];
      _initiatorCacheMap[initiator.hashCode] = newCacheValue;
    }
  }

  @override
  dynamic getCacheOfThisScope(Widget widget, {required bool isInitiator}) {
    if (isInitiator) {
      return _initiatorCacheMap[widget.hashCode];
    }

    final initiator = _participatorAndInitiatorMap[widget.hashCode];

    return _initiatorCacheMap[initiator.hashCode];
  }

  @override
  void disposeDynamicRoutesInstance(Widget initiatorWidget,
      {required bool clearCacheRelatedData}) {
    final participators =
        _initiatorAndParticipatorsMap[initiatorWidget.hashCode] ?? [];

    for (final p in participators) {
      _dynamicRoutesInstances[p.hashCode] = null;
      if (clearCacheRelatedData) {
        _participatorAndInitiatorMap[p.hashCode] = null;
      }
    }

    _initiatorAndParticipatorsMap[initiatorWidget.hashCode] = null;
    if (clearCacheRelatedData) {
      _initiatorCacheMap[initiatorWidget.hashCode] = null;
    }
  }
}

abstract class ScopedDynamicRoutesManager {
  /// A static DynamicRoutes manager that dispenses a scoped DynamicRoutes
  /// singleton bound to the lifeCycle of the StatefulWidget page it is attached to.
  DynamicRoutesNavigator dispenseNewDynamicRoutesInstance({
    required List<Widget> participatorWidgets,
    required Widget initiatorWidget,
  });

  DynamicRoutesNavigator dispenseNavigatorFromParticipator(Widget widget);

  DynamicRoutesNavigator dispenseParticipatorFromInitiator(Widget initiator);

  /// Remove reference to all instantiated objects from the_dynamicRoutesInstances
  /// array.
  void disposeDynamicRoutesInstance(Widget widget,
      {required bool clearCacheRelatedData});
}

abstract class ScopedCacheManager {
  getCacheOfThisScope(Widget initiator, {required bool isInitiator});

  setCacheOfThisScope(Widget initiator, dynamic newCacheValue,
      {required bool isInitiator});
}
