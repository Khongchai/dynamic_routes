import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

import '../main.dart';

class Page6 extends StatefulWidget with StackedRoutesCleaner {
  Page6({Key? key}) : super(key: key);

  @override
  State<Page6> createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text("A page not included in the route",
          style: TextStyle(fontSize: 30)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          // Imagine for whatever reason this page is opted out of the stacked and we need to do something here
          // before we clear out the navigation stack.
          // Now, once that action is complete, we can clear the previous stack by calling cleanUp()
          onPressed: () {
            widget.stackedRoutesNavigator.clearData();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MyApp()));
          },
          child: const Text("Clean up and go back to main"),
        ),
      ),
    );
  }
}
