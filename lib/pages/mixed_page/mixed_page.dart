import 'package:dynamic_routing/pages/participator_page.dart';
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
              onPressed: () => stackedRoutesParticipator.pushNext(context,
                  currentPage: widget),
              child: const Text("Continue this flow")),
          TextButton(
              onPressed: () {
                stackedRoutesInitiator.initializeNewStack(const [
                  ParticipatorPage(title: "SubFlow 1 Sub page 1"),
                  ParticipatorPage(title: "SubFlow 1 Sub page 2"),
                  ParticipatorPage(title: "SubFlow 1 Sub page 3"),
                ], lastPageCallback: (context) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
                stackedRoutesInitiator.pushFirst(context);
              },
              child: const Text("Begin sub flow 1")),
          TextButton(
              onPressed: () {
                stackedRoutesInitiator.initializeNewStack(const [
                  ParticipatorPage(title: "SubFlow 2 Sub page 1"),
                  ParticipatorPage(title: "SubFlow 2 Sub page 2"),
                  ParticipatorPage(title: "SubFlow 2 Sub page 3"),
                ], lastPageCallback: (context) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
                stackedRoutesInitiator.pushFirst(context);
              },
              child: const Text("Begin sub flow 2")),
        ]),
      ),
    );
  }
}
