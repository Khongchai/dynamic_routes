import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

class NonDynamicRouteParticipatingPage extends StatefulWidget {
  const NonDynamicRouteParticipatingPage({Key? key}) : super(key: key);

  @override
  State<NonDynamicRouteParticipatingPage> createState() =>
      _NonDynamicRouteParticipatingPageState();
}

class _NonDynamicRouteParticipatingPageState
    extends State<NonDynamicRouteParticipatingPage> with TestPage {
  @override
  String pageTitle() {
    return "Not a dynamic route participator";
  }
}
