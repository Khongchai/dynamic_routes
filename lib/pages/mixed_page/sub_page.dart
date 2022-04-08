import 'package:dynamic_routing/pages/page_mixin.dart';
import "package:flutter/material.dart";

import '../../dynamic_routes/mixins/participator.dart';

class SubPage extends StatefulWidget {
  final String title;
  const SubPage({required this.title, Key? key}) : super(key: key);

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage>
    with TestPageUI, DynamicRoutesParticipator {
  @override
  VoidCallback onNextPressed() {
    return () => dynamicRoutesParticipator.pushNext(context);
  }

  @override
  String pageTitle() {
    return widget.title;
  }
}
