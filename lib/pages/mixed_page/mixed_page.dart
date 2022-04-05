import 'package:dynamic_routing/pages/page_mixin.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class MixedPage extends StatefulWidget {
  const MixedPage({Key? key}) : super(key: key);

  @override
  State<MixedPage> createState() => _MixedPageState();
}

class _MixedPageState extends State<MixedPage>
    with TestPageUI, StackedRoutesParticipator, StackedRoutesInitiator {
  @override
  VoidCallback onNextPressed() {
    // TODO: implement onNextPressed
    throw UnimplementedError();
  }

  @override
  String pageTitle() {
    // TODO: implement pageTitle
    throw UnimplementedError();
  }
}
