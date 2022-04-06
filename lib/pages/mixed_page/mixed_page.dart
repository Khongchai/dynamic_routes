import 'package:dynamic_routing/pages/mixed_page/sub_page1.dart';
import 'package:dynamic_routing/pages/mixed_page/sub_page2.dart';
import 'package:dynamic_routing/pages/mixed_page/sub_page3.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import "package:flutter/material.dart";

class MixedPage extends StatefulWidget {
  const MixedPage({Key? key}) : super(key: key);

  @override
  State<MixedPage> createState() => _MixedPageState();
}

/// A fork where the user can either begin a new flow or continue with the old flow.
class _MixedPageState extends State<MixedPage>
    with StackedRoutesParticipator, StackedRoutesInitiator {
  @override
  void dispose() {
    stackedRoutesInitiator.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
          alignment: Alignment.center,
          child: Column(children: [
            TextButton(
                onPressed: () => stackedRoutesParticipator.pushNext(context,
                    currentPage: widget),
                child: const Text("Continue this flow")),
            TextButton(
                onPressed: () {
                  stackedRoutesInitiator.loadStack(const [
                    SubPage1(),
                    SubPage2(),
                    SubPage3(),
                  ], lastPageCallback: (context) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  });
                  stackedRoutesInitiator.pushFirst(context);
                },
                child: const Text("Begin a new flow")),
          ])),
    );
  }
}
