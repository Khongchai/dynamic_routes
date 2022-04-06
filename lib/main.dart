import 'package:dynamic_routing/pages/mixed_page/mixed_page.dart';
import 'package:dynamic_routing/pages/page1.dart';
import 'package:dynamic_routing/pages/page2.dart';
import 'package:dynamic_routing/pages/page3.dart';
import 'package:dynamic_routing/pages/page4.dart';
import 'package:dynamic_routing/pages/page5.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Stacked Routes Test', pageWidgets: [
        Page1(),
        Page2(),
        MixedPage(),
        Page4(),
        Page5(),
        Page3(),
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

class _MyHomePageState extends State<MyHomePage> with StackedRoutesInitiator {
  @override
  void dispose() {
    stackedRoutesInitiator.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(child: Text("Stacked Routes test")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          child: const Text("Enter flow"),
          onPressed: () {
            stackedRoutesInitiator.initializeNewStack(
              widget.pageWidgets,
              lastPageCallback: (newContext) =>
                  Navigator.popUntil(newContext, (route) => route.isFirst),
            );

            stackedRoutesInitiator.pushFirst(context);
          },
        ),
      ),
    );
  }
}
