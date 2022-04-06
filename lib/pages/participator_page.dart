import 'package:flutter/material.dart';

import '../stacked_routes/stacked_navigator.dart';

class ParticipatorPage extends StatefulWidget {
  final String title;

  const ParticipatorPage({required this.title, Key? key}) : super(key: key);

  @override
  State<ParticipatorPage> createState() => _ParticipatorPageState();
}

class _ParticipatorPageState extends State<ParticipatorPage>
    with StackedRoutesParticipator {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(child: Text(widget.title, style: const TextStyle(fontSize: 30))),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          key: Key(widget.title),
          onPressed: () =>
              stackedRoutesParticipator.pushNext(context, currentPage: widget),
          child: const Text("Next Page"),
        ),
      ),
    );
  }
}
