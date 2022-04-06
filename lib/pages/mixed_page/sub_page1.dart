import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class SubPage1 extends StatefulWidget {
  const SubPage1({Key? key}) : super(key: key);

  @override
  State<SubPage1> createState() => _SubPage1State();
}

class _SubPage1State extends State<SubPage1>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () =>
        stackedRoutesParticipator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return "Sub Page 1";
  }
}
