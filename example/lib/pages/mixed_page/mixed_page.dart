import 'package:dynamic_routes/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routes/dynamic_routes/mixins/participator.dart';
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
  void initState() {
    super.initState();
    dynamicRoutesInitiator.setCache(0);
  }

  @override
  Widget build(BuildContext context) {
    final value = dynamicRoutesParticipator.getCache();
    final subFlowValue = dynamicRoutesInitiator.getCache();

    return Scaffold(
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              child:
                  Text("Increment Cached Value of the Sub Flow: $subFlowValue"),
              onPressed: () {
                dynamicRoutesInitiator.setCache(subFlowValue + 1);
                setState(() {});
              }),
          ElevatedButton(
              child: Text("Increment Cached Value of This Flow: $value"),
              onPressed: () {
                dynamicRoutesParticipator.setCache(value + 1);
                setState(() {});
              }),
        ],
      ),
      body: Align(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
              onPressed: () => dynamicRoutesParticipator
                      .pushNext(
                    context,
                  )
                      .then((value) {
                    setState(() {});
                  }),
              child: const Text("Continue this flow")),
          TextButton(
              onPressed: () {
                dynamicRoutesInitiator.initializeRoutes(widget.subFlowSet1,
                    lastPageCallback: widget.subFlowSet1Callback);
                dynamicRoutesInitiator.pushFirst(context).then((_) {
                  setState(() {});
                });
              },
              child: Text(widget.isSubSubFlow
                  ? "Begin sub sub flow 1"
                  : "Begin sub flow 1")),
          TextButton(
              onPressed: () {
                dynamicRoutesInitiator.initializeRoutes(widget.subFlowSet2,
                    lastPageCallback: widget.subFlowSet2Callback);
                dynamicRoutesInitiator.pushFirst(context).then((_) {
                  setState(() {});
                });
              },
              child: Text(widget.isSubSubFlow
                  ? "Begin sub sub flow 2"
                  : "Begin sub flow 2")),
        ]),
      ),
    );
  }
}
