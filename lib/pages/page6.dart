import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

import '../main.dart';

class Page6 extends StatefulWidget {
  const Page6({Key? key}) : super(key: key);

  @override
  State<Page6> createState() => _Page6State();
}

class _Page6State extends State<Page6> with TestPageUI {
  @override
  VoidCallback onNextPressed() {
    return () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MyApp()), (route) => false);
  }

  @override
  String pageTitle() {
    return "The flow is over, this page is not a part of the flow";
  }
}
