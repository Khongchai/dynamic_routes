import 'package:dynamic_routes/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routes/dynamic_routes/mixins/participator.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

// Testing the pages here can be done either with the keys or accessing their states
// directly.

class HomePage extends StatefulWidget {
  final Key pushInitiatorWidgetKey;
  final Widget initiatorPage;

  const HomePage(
      {required this.initiatorPage,
        required this.pushInitiatorWidgetKey,
        Key? key})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Builder(builder: (context) {
      return TextButton(
        child: const Text("Push Initiator Widget"),
        key: widget.pushInitiatorWidgetKey,
        onPressed: () {
          // Call this one first to make sure that the navigation page's context
          // can be used with a navigator.
          Navigator.of(context).push(MaterialPageRoute(
            // Won't be using the participatorPages array passed here.
              builder: (context) => widget.initiatorPage));
        },
      );
    }));
  }
}

const valueForPreviousPage = "Mock Value";

const currentPageIndexText = "Current Page Index: ";

class MockBuildContext extends Mock implements BuildContext {}

/// For testing the internal states of the navigator
class InitiatorWidget extends StatefulWidget {
  final Key? pushFirstButtonKey;
  final Key? backButtonKey;
  final Key? pushFirstWithForKey;

  /// Provide this if you wanna test the widget by tapping on the page's button.
  ///
  /// If testing the state, just give empty array.
  final List<Widget> participatorPages;

  final int pushForCount;

  const InitiatorWidget({
    this.pushFirstButtonKey,
    this.backButtonKey,
    this.pushFirstWithForKey,
    this.pushForCount = 0,
    Key? key,
    required this.participatorPages,
  }) : super(key: key);

  @override
  State<InitiatorWidget> createState() => InitiatorWidgetState();
}

class InitiatorWidgetState extends State<InitiatorWidget>
    with DynamicRoutesInitiator {
  bool isLastPageCallbackCalled = false;

  late int pushForCount = widget.pushForCount;
  List<Future> pushFirstThenForFutures = [];

  @override
  void dispose() {
    dynamicRoutesInitiator.dispose();

    super.dispose();
  }

  @override
  Widget build(_) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Column(
          children: [
            const Text(currentPageIndexText + "-1"),
            TextButton(
                key: widget.pushFirstButtonKey,
                onPressed: () {
                  dynamicRoutesInitiator.initializeRoutes(
                      widget.participatorPages, lastPageCallback: (_) {
                    isLastPageCallbackCalled = true;
                  });
                  dynamicRoutesInitiator.pushFirst(context);
                },
                child: const Text("Push First")),
            TextButton(
                key: widget.pushFirstWithForKey,
                onPressed: () {
                  dynamicRoutesInitiator.initializeRoutes(
                      widget.participatorPages, lastPageCallback: (_) {
                    isLastPageCallbackCalled = true;
                  });
                  pushFirstThenForFutures = dynamicRoutesInitiator
                      .pushFirstThenFor(context, pushForCount);
                },
                child: const Text("Push First")),
            TextButton(
                key: widget.backButtonKey,
                onPressed: Navigator.of(context).pop,
                child: const Text("Pop")),
          ],
        ),
      ),
    );
  }
}

class MixedWidget extends StatefulWidget {
  final int? pageIndex;
  final Key? branchOffButton;
  final Key? continueFlowButton;
  final List<ParticipatorWidget> subPages;
  final Function(BuildContext context)? lastPageCallback;

  const MixedWidget(
      {required this.subPages,
      this.pageIndex,
      this.branchOffButton,
      this.continueFlowButton,
      this.lastPageCallback,
      Key? key})
      : super(key: key);

  @override
  State<MixedWidget> createState() => MixedWidgetState();
}

class MixedWidgetState extends State<MixedWidget>
    with DynamicRoutesInitiator, DynamicRoutesParticipator {
  late final int? pageIndex = widget.pageIndex;

  @override
  void dispose() {
    dynamicRoutesInitiator.dispose();

    super.dispose();
  }

  late Function(BuildContext context)? lastPageCallback =
      widget.lastPageCallback;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (pageIndex != null) Text(currentPageIndexText + "$pageIndex"),
      TextButton(
          onPressed: () {
            dynamicRoutesInitiator.initializeRoutes(widget.subPages,
                lastPageCallback: lastPageCallback);
            dynamicRoutesInitiator.pushFirst(context);
          },
          key: widget.branchOffButton,
          child: const Text("Branch Off")),
      TextButton(
          key: widget.continueFlowButton,
          onPressed: () {
            dynamicRoutesParticipator.pushNext(context);
          },
          child: const Text("Continue Flow")),
    ]);
  }
}

class ParticipatorWidget extends StatefulWidget {
  final Key? pushNextButtonKey;
  final Key? backButtonKey;
  final Key? backButtonWithValueKey;
  final int? pageIndex;
  final String? extraIdentifier;

  const ParticipatorWidget(
      {this.pushNextButtonKey,
      this.backButtonKey,
      this.backButtonWithValueKey,
      this.pageIndex,
      this.extraIdentifier,
      Key? key})
      : super(key: key);

  @override
  State<ParticipatorWidget> createState() => ParticipatorWidgetState();
}

class ParticipatorWidgetState extends State<ParticipatorWidget>
    with DynamicRoutesParticipator {
  String? valueFromPoppedPage;
  late final int? pageIndex = widget.pageIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.extraIdentifier != null) Text(widget.extraIdentifier!),
        if (pageIndex != null) Text(currentPageIndexText + "$pageIndex"),
        if (valueFromPoppedPage != null) Text(valueFromPoppedPage!),
        TextButton(
            key: widget.pushNextButtonKey,
            onPressed: () async {
              final value = await dynamicRoutesParticipator.pushNext(context);
              valueFromPoppedPage = value;
              setState(() {});
            },
            child: const Text("Push First")),
        TextButton(
            key: widget.backButtonKey,
            onPressed: () => dynamicRoutesParticipator.popCurrent(context),
            child: const Text("Pop")),
        TextButton(
            key: widget.backButtonWithValueKey,
            onPressed: () => dynamicRoutesParticipator.popCurrent(
                context, valueForPreviousPage),
            child: const Text("Pop with value to previous page")),
      ],
    );
  }
}
