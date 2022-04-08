import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import 'package:flutter/cupertino.dart';

import '../scoped_stacked_routes_manager.dart';

/// Participator mixin
///
/// Participators are the pages that are included in the loadStack method.
///
/// We enforce both the StackedRoutesInitiator and the StackedRoutesParticipator to use StatefulWidget
/// because we need to dispose the scoped singleton in the dispose method.
mixin StackedRoutesParticipator<T extends StatefulWidget> on State<T> {
  late final _ParticipatorNavigator stackedRoutesParticipator =
      _ParticipatorNavigator(widget);
}

class _ParticipatorNavigator {
  late final StackedRoutesNavigator _navigator;
  late final Widget _currentWidget;

  _ParticipatorNavigator(Widget participatorWidget) {
    final _scopedStackedRoutesManager = ScopedStackedRoutesManagerSingleton();
    _navigator = _scopedStackedRoutesManager
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
