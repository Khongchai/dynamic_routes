import 'package:flutter/material.dart';

class _TestWidget extends StatefulWidget {
  final String pageTitle;
  final VoidCallback onNextPressed;
  final Widget? floatingActionButton;

  const _TestWidget(
      {required this.pageTitle,
      required this.floatingActionButton,
      required this.onNextPressed,
      Key? key})
      : super(key: key);

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(widget.pageTitle, style: const TextStyle(fontSize: 30)),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          key: Key(widget.pageTitle),
          onPressed: () {
            widget.onNextPressed();
          },
          child: const Text("Next Page"),
        ),
      ),
    );
  }
}

mixin TestPageUI<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    return _TestWidget(
      floatingActionButton: floatingActionButton(),
      onNextPressed: onNextPressed(),
      pageTitle: pageTitle(),
    );
  }

  Widget? floatingActionButton();

  VoidCallback onNextPressed();

  String pageTitle();
}
