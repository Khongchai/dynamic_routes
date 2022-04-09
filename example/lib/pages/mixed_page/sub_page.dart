import 'package:dynamic_routes/dynamic_routes/mixins/participator.dart';
import "package:flutter/material.dart";

import '../page_mixin.dart';

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

  @override
  Widget? floatingActionButton() {
    int value = dynamicRoutesParticipator.getCache();
    return FloatingActionButton(
        child: Text("Increment Cached Value: $value"),
        onPressed: () {
          dynamicRoutesParticipator.setCache(value + 1);
          setState(() {});
        });
  }
}
