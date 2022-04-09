import 'package:dynamic_routing/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routing/dynamic_routes/mixins/participator.dart';
import 'package:flutter/material.dart';

class MixedPage extends StatefulWidget {
  /// We'll just change the title if is sub sub flow.
  final bool isSubSubFlow;

  final List<Widget> subFlowSet1;
  final Function(BuildContext context) subFlowSet1Callback;
  final List<Widget> subFlowSet2;
  final Function(BuildContext context) subFlowSet2Callback;
  const MixedPage(
      {required this.isSubSubFlow,
      required this.subFlowSet1,
      required this.subFlowSet2,
      required this.subFlowSet1Callback,
      required this.subFlowSet2Callback,
      Key? key})
      : super(key: key);

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
                dynamicRoutesInitiator.initializeRoutes(widget.subFlowSet1,
                    lastPageCallback: widget.subFlowSet1Callback);
                dynamicRoutesInitiator.pushFirst(context);
              },
              child: Text(widget.isSubSubFlow
                  ? "Begin sub sub flow 1"
                  : "Begin sub flow 1")),
          TextButton(
              onPressed: () {
                dynamicRoutesInitiator.initializeRoutes(widget.subFlowSet2,
                    lastPageCallback: widget.subFlowSet2Callback);
                dynamicRoutesInitiator.pushFirst(context);
              },
              child: Text(widget.isSubSubFlow
                  ? "Begin sub sub flow 2"
                  : "Begin sub flow 2")),
        ]),
      ),
    );
  }
}
