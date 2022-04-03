import 'package:dynamic_routing/pages/page6.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class Page5 extends StatefulWidget with StackedRoutesParticipator {
  Page5({Key? key}) : super(key: key);

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          const Text("Final page in the route", style: TextStyle(fontSize: 30)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: () => Navigator.of(context)
              // We push next but won't be cleaning up here.
              .push(MaterialPageRoute(builder: (_) => Page6())),
          child: const Text("Push Next"),
        ),
      ),
    );
  }
}
