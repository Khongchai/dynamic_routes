import 'package:dynamic_routing/pages/mixed_page/mixed_page.dart';
import 'package:dynamic_routing/pages/participator_page.dart';
import 'package:flutter/material.dart';

import 'dynamic_routes/mixins/initiator.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Stacked Routes Test', pageWidgets: [
        ParticipatorPage(title: "Page 1"),
        ParticipatorPage(title: "Page 2"),
        MixedPage(),
        ParticipatorPage(title: "Page 4"),
        ParticipatorPage(title: "Page 5"),
        ParticipatorPage(title: "Page 6"),
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
