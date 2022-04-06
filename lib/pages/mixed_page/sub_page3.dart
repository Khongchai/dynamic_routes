import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class SubPage3 extends StatefulWidget {
  const SubPage3({Key? key}) : super(key: key);

  @override
  State<SubPage3> createState() => _SubPage3State();
}

class _SubPage3State extends State<SubPage3>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () =>
        stackedRoutesParticipator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return "Sub Page 3";
  }
}
