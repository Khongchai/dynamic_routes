import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class SubPage2 extends StatefulWidget {
  const SubPage2({Key? key}) : super(key: key);

  @override
  State<SubPage2> createState() => _SubPage2State();
}

class _SubPage2State extends State<SubPage2>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () =>
        stackedRoutesParticipator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return "Sub Page 2";
  }
}
