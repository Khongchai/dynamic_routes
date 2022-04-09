import 'package:dynamic_routing/dynamic_routes/mixins/initiator.dart';
import 'package:example/pages/mixed_page/mixed_page.dart';
import 'package:example/pages/participator_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stacked Routes Test',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // One might argue: "What's new with this? We can already do this using
      // the normal Navigator class".
      //
      // Well, that's right, but what you can't do is that do exactly this, but
      // deciding which page to be shown
      //
      // or which place to be swapped at runtime, all from just one place without
      // the pages even knowing where they are going,
      // the only thing they do is pushing the next thing in the array.
      home: MyHomePage(title: 'Stacked Routes Test', pageWidgets: [
        const ParticipatorPage(title: "Page 1"),
        const ParticipatorPage(title: "Page 2"),
        // A page that can both continue the flow and branch off into a new flow.
        // In real applications, you'd of course use route predicates to pop back
        // to something.
        //
        // For simplicity's sake, we'll just do pop multiple times for this example.
        MixedPage(
          // This isSubSubFlow has nothing to do with the library, it's just that
          // I'm too lazy to change the title of subsubflow pages.
          isSubSubFlow: false,
          subFlowSet1: const [
            ParticipatorPage(title: "SubFlow 1 Sub page 1"),
            ParticipatorPage(title: "SubFlow 1 Sub page 2"),
            ParticipatorPage(title: "SubFlow 1 Sub page 3"),
          ],
          subFlowSet1Callback: (context) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          subFlowSet2: [
            const ParticipatorPage(title: "SubFlow 1 Sub page 1"),
            const ParticipatorPage(title: "SubFlow 1 Sub page 2"),
            const ParticipatorPage(title: "SubFlow 1 Sub page 3"),
            // A sub flow within sub flow....sub-ception!
            MixedPage(
                // This isSubSubFlow has nothing to do with the library, it's
                // just that I'm too lazy to change the title of subsubflow pages.
                isSubSubFlow: true,
                subFlowSet1: const [
                  ParticipatorPage(title: "SubSubflow 1 Sub Page 1"),
                  ParticipatorPage(title: "SubSubflow 1 Sub Page 2"),
                ],
                subFlowSet1Callback: (context) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                subFlowSet2: const [
                  ParticipatorPage(title: "SubSubflow 2 Sub page 1"),
                  ParticipatorPage(title: "SubSubflow 2 Sub page 2"),
                ],
                subFlowSet2Callback: (context) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }),
            const ParticipatorPage(title: "SubFlow 1 Sub page 5"),
          ],
          subFlowSet2Callback: (context) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        const ParticipatorPage(title: "Page 4"),
        const ParticipatorPage(title: "Page 5"),
        const ParticipatorPage(title: "Page 6"),
      ]),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<Widget> pageWidgets;
  const MyHomePage({
    Key? key,
    required this.title,
    required this.pageWidgets,
  }) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with DynamicRoutesInitiator {
  late List<Widget> _widgets = widget.pageWidgets;

  @override
  void dispose() {
    dynamicRoutesInitiator.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: TextButton(
        child: const Text("Shuffle page order"),
        onPressed: () {
          final newWidgets = [..._widgets]..shuffle();
          _widgets = newWidgets;
        },
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(child: Text("Stacked Routes test")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          child: const Text("Enter flow"),
          onPressed: () {
            dynamicRoutesInitiator.initializeRoutes(_widgets,
                lastPageCallback: (newContext) {
              Navigator.popUntil(newContext, (route) => route.isFirst);
            });

            dynamicRoutesInitiator.pushFirst(context);
          },
        ),
      ),
    );
  }
}
