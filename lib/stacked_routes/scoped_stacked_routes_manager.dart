import 'package:flutter/material.dart';

import 'stacked_navigator.dart';

class ScopedStackedRoutesManagerSingleton
    extends _ScopedStackedRoutesManagerImpl {
  static ScopedStackedRoutesManagerSingleton singletonInstance =
      ScopedStackedRoutesManagerSingleton._();

  ScopedStackedRoutesManagerSingleton._();

  factory ScopedStackedRoutesManagerSingleton() => singletonInstance;
}

class _ScopedStackedRoutesManagerImpl implements ScopedStackedRoutesManager {
  /// The map is a map of all hashCode of the widgets in a stack.
  final Map<int, StackedRoutesNavigator?> _stackedRoutesInstances = {};

  /// This map is for disposing all participator when the initiator is disposed.
  final Map<int, List<Widget>?> _initiatorAndParticipatorsMap = {};

  @override
  StackedRoutesNavigator dispenseNewStackedRoutesInstance({
    required List<Widget> participatorWidgets,
    required Widget initiatorWidget,
  }) {
    final newStackedRoutesInstance = StackedRoutesNavigatorImpl();

    // Bind all widgets in the stack to this newStackedRoutesInstance
    for (final widget in participatorWidgets) {
      assert(
          _stackedRoutesInstances[widget.hashCode] == null,
          "The participator instance ${widget.hashCode} is already bound to a navigation scope."
          "instances and cannot be assigned again until the current instances are disposed.");
      _stackedRoutesInstances[widget.hashCode] = newStackedRoutesInstance;
    }

    // Save reference for the disposition of all references to widgets in the stack from this manager
    _initiatorAndParticipatorsMap[initiatorWidget.hashCode] =
        participatorWidgets;

    return newStackedRoutesInstance;
  }

  @override
  StackedRoutesNavigator dispenseNavigatorFromParticipator(
      Widget participator) {
    final queriedInstance = _stackedRoutesInstances[participator.hashCode];
    assert(queriedInstance != null,
        "The widget provided is not tied to any stackedRoutesInstance");

    return queriedInstance!;
  }

  @override
  StackedRoutesNavigator dispenseParticipatorFromInitiator(
      Widget initiatorWidget) {
    final queriedInitiator =
        _initiatorAndParticipatorsMap[initiatorWidget.hashCode];
    assert(queriedInitiator != null,
        "The widget provided is not tied to any stackedRoutesInstance. Did you forget to call initializeNewStack()?");

    final queriedParticipator =
        _stackedRoutesInstances[queriedInitiator!.first.hashCode];

    return queriedParticipator!;
  }

  @override
  void disposeStackedRoutesInstance(Widget initiatorWidget) {
    final participators =
        _initiatorAndParticipatorsMap[initiatorWidget.hashCode] ?? [];

    for (final p in participators) {
      _stackedRoutesInstances[p.hashCode] = null;
    }

    _initiatorAndParticipatorsMap[initiatorWidget.hashCode] = null;
  }
}

abstract class ScopedStackedRoutesManager {
  /// A static StackedRoutes manager that dispenses a scoped StackedRoutes singleton bound to
  /// the lifeCycle of the StatefulWidget page it is attached to.
  StackedRoutesNavigator dispenseNewStackedRoutesInstance({
    required List<Widget> participatorWidgets,
    required Widget initiatorWidget,
  });

  StackedRoutesNavigator dispenseNavigatorFromParticipator(Widget widget);
  StackedRoutesNavigator dispenseParticipatorFromInitiator(Widget widget);

  /// Remove reference to all instantiated objects from the _stackedRoutesInstances array.
  ///
  void disposeStackedRoutesInstance(Widget widget);
}
