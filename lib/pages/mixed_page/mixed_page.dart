import 'package:flutter/material.dart';

import '../../dynamic_routes/mixins/initiator.dart';
import '../../dynamic_routes/mixins/participator.dart';
import '../participator_page.dart';

class MixedPage extends StatefulWidget {
  const MixedPage({Key? key}) : super(key: key);

  @override
  State<MixedPage> createState() => _MixedPageState();
}

/// A fork where the user can either begin a new flow or continue with the old flow.
class _MixedPageState extends State<MixedPage>
    with DynamicRoutesParticipator, DynamicRoutesInitiator {
  @override
  void dispose() {
    dynamicRoutesInitiator.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
              onPressed: () => dynamicRoutesParticipator.pushNext(
                    context,
                  ),
              child: const Text("Continue this flow")),
          TextButton(
              onPressed: () {
                dynamicRoutesInitiator.initializeRoutes(const [
                  ParticipatorPage(title: "SubFlow 1 Sub page 1"),
                  ParticipatorPage(title: "SubFlow 1 Sub page 2"),
                  ParticipatorPage(title: "SubFlow 1 Sub page 3"),
                ], lastPageCallback: (context) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
                dynamicRoutesInitiator.pushFirst(context);
              },
              child: const Text("Begin sub flow 1")),
          TextButton(
              onPressed: () {
                dynamicRoutesInitiator.initializeRoutes(const [
                  ParticipatorPage(title: "SubFlow 2 Sub page 1"),
                  ParticipatorPage(title: "SubFlow 2 Sub page 2"),
                  ParticipatorPage(title: "SubFlow 2 Sub page 3"),
                ], lastPageCallback: (context) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
                dynamicRoutesInitiator.pushFirst(context);
              },
              child: const Text("Begin sub flow 2")),
        ]),
      ),
    );
  }
}
