import 'package:flutter/material.dart';

import '../stacked_routes/stacked_navigator.dart';

mixin TestPage<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(pageTitle(), style: const TextStyle(fontSize: 30)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: () => StackedRoutesNavigator.pushNext(context),
          child: const Text("Next Page"),
        ),
      ),
    );
  }

  String pageTitle();

}
