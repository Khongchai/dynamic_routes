import 'package:flutter/cupertino.dart';

import '../scoped_stacked_routes_manager.dart';
import '../stacked_navigator.dart';

/// Initiator mixin
///
/// The initiator page is the page directly before the flow.
///
/// We enforce both the StackedRoutesInitiator and the StackedRoutesParticipator to use StatefulWidget
/// because we need to dispose the scoped singleton in the dispose method.
mixin StackedRoutesInitiator<T extends StatefulWidget> on State<T> {
  late final _InitiatorNavigator stackedRoutesInitiator =
      _InitiatorNavigator(widget);
}

class _InitiatorNavigator implements InitiatorNavigator, StackedRoutesDisposer {
  final _scopedStackedRoutesManager = ScopedStackedRoutesManagerSingleton();
  final Widget _initiatorWidget;

  _InitiatorNavigator(this._initiatorWidget);

  @override
  initializeNewStack(List<Widget> pages,
      {Function(BuildContext context)? lastPageCallback}) {
    assert(pages.isNotEmpty, "The participators page array cannot be empty");

    // //Ensure clean up of the old one.
    dispose();

    final newInstance =
        _scopedStackedRoutesManager.dispenseNewStackedRoutesInstance(
            participatorWidgets: pages, initiatorWidget: _initiatorWidget);

    newInstance.initializeNewStack(pages, lastPageCallback: lastPageCallback);
  }

  @override
  pushFirst(BuildContext context) {
    final instance = _scopedStackedRoutesManager
        .dispenseParticipatorFromInitiator(_initiatorWidget);
    instance.pushFirst(context);
  }

  @override
  List<Widget> getLoadedPages() {
    final instance = _scopedStackedRoutesManager
        .dispenseParticipatorFromInitiator(_initiatorWidget);

    return instance.getLoadedPages();
  }

  @override
  void dispose() {
    _scopedStackedRoutesManager.disposeStackedRoutesInstance(_initiatorWidget);
  }
}
