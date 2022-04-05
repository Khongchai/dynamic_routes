import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class Page4 extends StatefulWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () =>
        stackedRoutesParticipator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return "Page 4";
  }
}
