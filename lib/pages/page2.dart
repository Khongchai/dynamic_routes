import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

class Page2 extends DynamicRouteParticipatingStatefulWidget {
  Page2({Key? key}) : super(key: key);

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> with TestPage {
  @override
  String pageTitle() {
    return "Page 2";
  }
}
