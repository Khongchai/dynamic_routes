import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

class Page4 extends DynamicRouteParticipatingStatefulWidget {
  Page4({Key? key}) : super(key: key);

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> with TestPage {
  @override
  String pageTitle() {
    return "Page 4";
  }
}
