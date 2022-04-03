import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

class Page3 extends DynamicRouteParticipatingStatefulWidget {
  Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> with TestPage {
  @override
  String pageTitle() {
    return "Page 3";
  }
}
