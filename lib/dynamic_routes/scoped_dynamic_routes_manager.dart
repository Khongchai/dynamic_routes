import 'package:flutter/material.dart';

import 'base_navigators.dart';

class ScopedDynamicRoutesManagerSingleton
    extends _ScopedDynamicRoutesManagerImpl {
  static ScopedDynamicRoutesManagerSingleton singletonInstance =
      ScopedDynamicRoutesManagerSingleton._();

  ScopedDynamicRoutesManagerSingleton._();

  factory ScopedDynamicRoutesManagerSingleton() => singletonInstance;
}

class _ScopedDynamicRoutesManagerImpl implements ScopedStackedRoutesManager {
  /// The map is a map of all hashCode of the widgets in a stack.
  final Map<int, DynamicRoutesNavigator?> _dynamicRoutesInstances = {};

  /// This map is for disposing all participator when the initiator is disposed.
  final Map<int, List<Widget>?> _initiatorAndParticipatorsMap = {};

  @override
  DynamicRoutesNavigator dispenseNewDynamicRoutesInstance({
    required List<Widget> participatorWidgets,
    required Widget initiatorWidget,
  }) {
    final newDynamicRoutesInstance = DynamicRoutesNavigatorImpl();

    // Bind all widgets in the stack to this newDynamicRoutesInstance
    for (final widget in participatorWidgets) {
      assert(
          _dynamicRoutesInstances[widget.hashCode] == null,
          "The participator instance ${widget.hashCode} is already bound to a navigation scope."
          "instances and cannot be assigned again until the current instances are disposed.");
      _dynamicRoutesInstances[widget.hashCode] = newDynamicRoutesInstance;
    }

    // Save reference for the disposition of all references to widgets in the stack from this manager
    _initiatorAndParticipatorsMap[initiatorWidget.hashCode] =
        participatorWidgets;

    return newDynamicRoutesInstance;
  }

  @override
  DynamicRoutesNavigator dispenseNavigatorFromParticipator(
      Widget participator) {
    final queriedInstance = _dynamicRoutesInstances[participator.hashCode];
    assert(queriedInstance != null,
        "The widget provided is not tied to any stackedRoutesInstance");

    return queriedInstance!;
  }

  @override
  DynamicRoutesNavigator dispenseParticipatorFromInitiator(
      Widget initiatorWidget) {
    final queriedInitiator =
        _initiatorAndParticipatorsMap[initiatorWidget.hashCode];
    assert(queriedInitiator != null,
        "The widget provided is not tied to any stackedRoutesInstance. Did you forget to call initializeNewStack()?");

    final queriedParticipator =
        _dynamicRoutesInstances[queriedInitiator!.first.hashCode];

    return queriedParticipator!;
  }

  @override
  void disposeStackedRoutesInstance(Widget initiatorWidget) {
    final participators =
        _initiatorAndParticipatorsMap[initiatorWidget.hashCode] ?? [];

    for (final p in participators) {
      _dynamicRoutesInstances[p.hashCode] = null;
    }

    _initiatorAndParticipatorsMap[initiatorWidget.hashCode] = null;
  }
}

abstract class ScopedStackedRoutesManager {
  /// A static StackedRoutes manager that dispenses a scoped StackedRoutes singleton bound to
  /// the lifeCycle of the StatefulWidget page it is attached to.
  DynamicRoutesNavigator dispenseNewDynamicRoutesInstance({
    required List<Widget> participatorWidgets,
    required Widget initiatorWidget,
  });

  DynamicRoutesNavigator dispenseNavigatorFromParticipator(Widget widget);
  DynamicRoutesNavigator dispenseParticipatorFromInitiator(Widget widget);

  /// Remove reference to all instantiated objects from the _stackedRoutesInstances array.
  ///
  void disposeStackedRoutesInstance(Widget widget);
}
