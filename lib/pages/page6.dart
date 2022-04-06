import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class Page6 extends StatefulWidget {
  const Page6({Key? key}) : super(key: key);

  @override
  State<Page6> createState() => _Page6State();
}

class _Page6State extends State<Page6>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () =>
        stackedRoutesParticipator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return "Page 6";
  }
}
