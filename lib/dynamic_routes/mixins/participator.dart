import 'package:dynamic_routing/dynamic_routes/dynamic_navigator.dart';
import 'package:flutter/cupertino.dart';

import '../scoped_dynamic_routes_manager.dart';

/// Participator mixin
///
/// Participators are the pages that are included in the initializeRoutes method.
///
/// We enforce both the DynamicRoutesInitiator and the DynamicRoutesParticipator to use StatefulWidget
/// because we need to dispose the scoped singleton in the dispose method.
mixin DynamicRoutesParticipator<T extends StatefulWidget> on State<T> {
  late final _ParticipatorNavigator dynamicRoutesParticipator =
      _ParticipatorNavigator(widget);
}

class _ParticipatorNavigator {
  late final DynamicRoutesNavigator _navigator;
  late final Widget _currentWidget;

  _ParticipatorNavigator(Widget participatorWidget) {
    final _scopedDynamicRoutesManager = ScopedDynamicRoutesManagerSingleton();
    _navigator = _scopedDynamicRoutesManager
        .dispenseNavigatorFromParticipator(participatorWidget);
    _currentWidget = participatorWidget;
  }

  int? getCurrentWidgetHash() {
    return _navigator.getCurrentWidgetHash();
  }

  void popCurrent(BuildContext context) {
    _navigator.popCurrent(context, currentPage: _currentWidget);
  }

  void pushNext(BuildContext context) {
    _navigator.pushNext(context, currentPage: _currentWidget);
  }

  bool pushNextOfLastPageCalled() {
    return _navigator.pushNextOfLastPageCalled();
  }
}
