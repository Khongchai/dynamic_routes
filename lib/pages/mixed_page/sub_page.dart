import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class SubPage extends StatefulWidget {
  final String title;
  const SubPage({required this.title, Key? key}) : super(key: key);

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () =>
        stackedRoutesParticipator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return widget.title;
  }
}
