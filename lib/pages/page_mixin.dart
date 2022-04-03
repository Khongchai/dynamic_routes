import 'package:flutter/material.dart';

import '../stacked_routes/stacked_navigator.dart';

/// This abstract class is just a combination of StatefulWidget and DynamicRouteParticipator.
///
/// If a mixin is not being used, abstract classes like this one might not be necessary and DynamicRouteParticipator
/// can just be used directly.
abstract class DynamicRouteParticipatingStatefulWidget extends StatefulWidget
    with StackedRoutesParticipator {
  DynamicRouteParticipatingStatefulWidget({Key? key}) : super(key: key);
}

mixin TestPage<T extends DynamicRouteParticipatingStatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(pageTitle(), style: const TextStyle(fontSize: 30)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: () => widget.stackedRoutesNavigator
              .pushNext(context, currentWidget: widget),
          child: const Text("Next Page"),
        ),
      ),
    );
  }

  String pageTitle();
}
