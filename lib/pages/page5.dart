import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class Page5 extends StatefulWidget {
  const Page5({Key? key}) : super(key: key);

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5>
    with TestPageUI, StackedRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () => stackedRoutesNavigator.pushNext(context, currentPage: widget);
  }

  @override
  String pageTitle() {
    return "Page 5";
  }
}
