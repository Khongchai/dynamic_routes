import 'package:dynamic_routing/pages/page1.dart';
import 'package:dynamic_routing/pages/page2.dart';
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
      home: MyHomePage(title: 'Stacked Routes Test'),
    );
  }
}

class MyHomePage extends StatefulWidget with StackedRoutesParticipator {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            widget.stackedRoutesNavigator
                .loadStack([Page1(), Page2(), Page4(), Page5()]);

            widget.stackedRoutesNavigator.pushFirst(context);
          },
        ),
      ),
    );
  }
}
