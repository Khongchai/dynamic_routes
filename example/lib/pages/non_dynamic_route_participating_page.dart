import "package:flutter/material.dart";

class NonStackedRouteParticipatingPage extends StatefulWidget {
  const NonStackedRouteParticipatingPage({Key? key}) : super(key: key);

  @override
  State<NonStackedRouteParticipatingPage> createState() =>
      _NonStackedRouteParticipatingPageState();
}

class _NonStackedRouteParticipatingPageState
    extends State<NonStackedRouteParticipatingPage> {
  @override
  Widget build(BuildContext context) {
    return const Text(
        "This page does not participate in the stacked routes navigation");
  }
}
