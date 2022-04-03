import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

class Page5 extends DynamicRouteParticipatingStatefulWidget {
  Page5({Key? key}) : super(key: key);

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> with TestPage {
  @override
  String pageTitle() {
    return "Page 5";
  }
}
