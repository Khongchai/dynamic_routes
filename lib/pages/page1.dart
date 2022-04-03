import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

class Page1 extends DynamicRouteParticipatingStatefulWidget {
  Page1({Key? key}) : super(key: key);

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> with TestPage {
  @override
  String pageTitle() {
    return "Page 1";
  }
}
