import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () =>
        stackedRoutesParticipator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return "Page 3";
  }
}
