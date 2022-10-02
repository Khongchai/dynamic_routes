import 'package:dynamic_routes/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routes/dynamic_routes/mixins/participator.dart';
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import 'package:mockito/mockito.dart';

import 'testing_utils.dart';

const valueForPreviousPage = "Mock Value";

const currentPageIndexText = "Current Page Index: ";

class MockBuildContext extends Mock implements BuildContext {}

/// For testing the internal states of the navigator
class InitiatorWidget extends StatefulWidget {
  final Key? pushFirstButtonKey;
  final Key? backButtonKey;

  /// Provide this if you wanna test the widget by tapping on the page's button.
  ///
  /// If testing the state, just give empty array.
  final List<Widget> participatorPages;

  const InitiatorWidget({
    this.pushFirstButtonKey,
    this.backButtonKey,
    Key? key,
    required this.participatorPages,
  }) : super(key: key);

  @override
  State<InitiatorWidget> createState() => InitiatorWidgetState();
}

class InitiatorWidgetState extends State<InitiatorWidget>
    with DynamicRoutesInitiator {
  bool isLastPageCallbackCalled = false;

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
                key: widget.backButtonKey,
                onPressed: Navigator.of(context).pop,
                child: const Text("Pop")),
          ],
        ),
      ),
    );
  }
}

class ParticipatorWidget extends StatefulWidget {
  final Key? pushNextButtonKey;
  final Key? backButtonKey;
  final Key? backButtonWithValueKey;
  final int? pageIndex;

  const ParticipatorWidget(
      {this.pushNextButtonKey,
      this.backButtonKey,
      this.backButtonWithValueKey,
      this.pageIndex,
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

void main() {
  final MockBuildContext context = MockBuildContext();

  group("Internal test", () {
    testWidgets(
        "Test initializing a new stack and the initial binding between a widget and the initiator",
        (WidgetTester tester) async {
      final participators = TestingUtils.generateParticipatorWidget(9);

      const initiatorPushFirstKey = Key("pushKey");
      await tester.pumpWidget(InitiatorWidget(
        participatorPages: participators,
        pushFirstButtonKey: initiatorPushFirstKey,
      ));

      await tester.tap(find.byKey(initiatorPushFirstKey));

      final InitiatorWidgetState initiatorWidgetState =
          tester.state(find.byType(InitiatorWidget));

      expect(
          initiatorWidgetState.dynamicRoutesInitiator.getLoadedPages().length,
          participators.length);
    });

    group("Before initialization", () {
      testWidgets(
          "Calling pushFirst without calling initializeRoutes should "
          "throw an assertion error", (WidgetTester tester) async {
        await tester.pumpWidget(const InitiatorWidget(participatorPages: []));

        final InitiatorWidgetState initiatorWidgetState =
            tester.state(find.byType(InitiatorWidget));

        expect(
            () =>
                initiatorWidgetState.dynamicRoutesInitiator.pushFirst(context),
            throwsAssertionError);
      });
    });

    group("After initiation", () {
      testWidgets(
          "when disposed, reassignment from the same instance should be possible.",
          (WidgetTester tester) async {
        const participatorWidget = ParticipatorWidget();
        await tester.pumpWidget(const InitiatorWidget(participatorPages: []));

        final InitiatorWidgetState initiatorWidgetState =
            tester.state(find.byType(InitiatorWidget));

        initiatorWidgetState.dynamicRoutesInitiator
            .initializeRoutes([participatorWidget]);

        initiatorWidgetState.dynamicRoutesInitiator.dispose();

        // Shouldn't be any error
        initiatorWidgetState.dynamicRoutesInitiator
            .initializeRoutes([participatorWidget]);
      });

      testWidgets(
          "When not disposed, reassignment from the same instance should still be possible.",
          (WidgetTester tester) async {
        const participatorWidget = ParticipatorWidget();
        await tester.pumpWidget(const InitiatorWidget(
          participatorPages: [],
        ));

        final InitiatorWidgetState initiatorWidgetState =
            tester.state(find.byType(InitiatorWidget));

        initiatorWidgetState.dynamicRoutesInitiator
            .initializeRoutes([participatorWidget]);

        // Shouldn't be any error
        initiatorWidgetState.dynamicRoutesInitiator
            .initializeRoutes([participatorWidget]);
      });
    });

    testWidgets(
        "When disposed, calling pushFirst without initializing again "
        "should throw an assertion error", (WidgetTester tester) async {
      await tester.pumpWidget(const InitiatorWidget(participatorPages: []));

      final InitiatorWidgetState initiatorWidgetState =
          tester.state(find.byType(InitiatorWidget));

      initiatorWidgetState.dynamicRoutesInitiator
          .initializeRoutes([const ParticipatorWidget()]);

      initiatorWidgetState.dynamicRoutesInitiator.dispose();

      expect(
          () => initiatorWidgetState.dynamicRoutesInitiator.pushFirst(context),
          throwsAssertionError);
    });

    testWidgets(
        "When disposed, getLoadedPages() expect an assertion to be thrown "
        "when trying to queried for existing participators (should always"
        "throw assertion error when array empty).",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          const InitiatorWidget(participatorPages: [ParticipatorWidget()]));

      final InitiatorWidgetState initiatorWidgetState =
          tester.state(find.byType(InitiatorWidget));

      initiatorWidgetState.dynamicRoutesInitiator.dispose();

      expect(() => initiatorWidgetState.dynamicRoutesInitiator.getLoadedPages(),
          throwsAssertionError);
    });
  });

  group("Interaction testing", () {
    testWidgets("Push first page, pop, and then push again.",
        (WidgetTester tester) async {
      final participator = TestingUtils.generateParticipatorWidget(1)[0];
      const initiatorPushFirstKey = Key("pushKey");
      await tester.pumpWidget(InitiatorWidget(
        participatorPages: [participator],
        pushFirstButtonKey: initiatorPushFirstKey,
      ));

      await tester.tap(find.byKey(initiatorPushFirstKey));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(participator.backButtonKey!));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(initiatorPushFirstKey));
      await tester.pumpAndSettle();
    });

    testWidgets(
        "Popping with value using dynamicRoutesNavigator should work like Navigator.pop",
        (WidgetTester tester) async {
      final participators = TestingUtils.generateParticipatorWidget(2);
      final initiatorWidget =
          TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiatorWidget);

      await tester.tap(find.byKey(initiatorWidget.pushFirstButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(0);

      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(1);

      await tester.tap(find.byKey(participators[1].backButtonWithValueKey!));
      await tester.pumpAndSettle();

      final foundText = find.text(valueForPreviousPage);
      expect(foundText, findsOneWidget);
    });

    testWidgets("pageIndex value test", (WidgetTester tester) async {
      final participators = TestingUtils.generateParticipatorWidget(5);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiator);
      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      await tester.pumpAndSettle();

      final firstParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[0].key!);
      expect(
          firstParticipatorState.dynamicRoutesParticipator
              .getCurrentPageIndex(),
          firstParticipatorState.pageIndex);

      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(participators[1].pushNextButtonKey!));
      await tester.pumpAndSettle();

      final thirdParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[2].key!);
      expect(
          thirdParticipatorState.dynamicRoutesParticipator
              .getCurrentPageIndex(),
          thirdParticipatorState.pageIndex);

      thirdParticipatorState.dynamicRoutesParticipator.popFor(
          thirdParticipatorState.context,
          thirdParticipatorState.dynamicRoutesParticipator
                  .getCurrentPageIndex() +
              1);
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(-1);
    });

    testWidgets("popFor behaves correctly.", (WidgetTester tester) async {
      final participators = TestingUtils.generateParticipatorWidget(5);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiator);
      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[1].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[2].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[3].pushNextButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(4);

      final fifthParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[4].key!);
      fifthParticipatorState.dynamicRoutesParticipator.popFor(
          fifthParticipatorState.context,
          fifthParticipatorState.dynamicRoutesParticipator
              // test will pass if index is 4.
              .getCurrentPageIndex());
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(0);

      final firstParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[0].key!);
      firstParticipatorState.dynamicRoutesParticipator
          .popFor(firstParticipatorState.context, 99999);
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(-1);

      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[1].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[2].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[3].pushNextButtonKey!));
      await tester.pumpAndSettle();

      final fifthParticipatorState2 = TestingUtils.getParticipatorStateFromKey(
          tester, participators[4].key!);
      fifthParticipatorState2.dynamicRoutesParticipator
          .popFor(fifthParticipatorState2.context, 3);
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(1);
    });

    testWidgets("pushFor functions correctly", (tester) async {
      final participators = TestingUtils.generateParticipatorWidget(5);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiator);

      final initiatorState =
          TestingUtils.getInitiatorWidgetStateFromKey(tester, initiator.key!);

      expect(initiatorState.isLastPageCallbackCalled, false);

      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      await tester.pumpAndSettle();

      final firstPageState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[0].key!);
      firstPageState.dynamicRoutesParticipator
          .pushFor(firstPageState.context, 4);
      await tester.pumpAndSettle();
      TestingUtils.expectPageExistsAtIndex(4);

      firstPageState.dynamicRoutesParticipator
          .popFor(firstPageState.context, 4);
      TestingUtils.expectPageExistsAtIndex(4);

      firstPageState.dynamicRoutesParticipator
          .pushFor(firstPageState.context, 5);
      TestingUtils.expectPageExistsAtIndex(4);

      expect(initiatorState.isLastPageCallbackCalled, true);
    });

    testWidgets("Routes get pushed correctly ", (WidgetTester tester) async {
      final participators = TestingUtils.generateParticipatorWidget(4);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiator);

      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(0);

      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[1].pushNextButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(2);

      await tester.tap(find.byKey(participators[2].pushNextButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(3);
    });
  });

  group("Cache test", () {
    testWidgets("Test read and write to cache", (WidgetTester tester) async {
      //Assign a value to the routeCache in the first page
      final mockCacheData = {"some-key": 1, "some-other-key": 2};
      const pushFirstButtonKey = Key("pushFirstButton");
      const firstPagePushNextKey = Key("firstPagePushNextKey");
      const secondPagePushNextKey = Key("secondPagePushNextKey");
      const thirdWidget = ParticipatorWidget();

      await tester.pumpWidget(const InitiatorWidget(
        pushFirstButtonKey: pushFirstButtonKey,
        participatorPages: [
          ParticipatorWidget(pushNextButtonKey: firstPagePushNextKey),
          ParticipatorWidget(
            pushNextButtonKey: secondPagePushNextKey,
          ),
          thirdWidget
        ],
      ));
      final InitiatorWidgetState initiatorState =
          tester.state(find.byType(InitiatorWidget));

      await tester.tap(find.byKey(pushFirstButtonKey));
      initiatorState.dynamicRoutesInitiator.setCache(mockCacheData);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(firstPagePushNextKey));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(secondPagePushNextKey));
      await tester.pumpAndSettle();

      final ParticipatorWidgetState stateToTest =
          tester.state(find.byWidget(thirdWidget));

      expect(stateToTest.dynamicRoutesParticipator.getCache(), mockCacheData);
    });
  });

  group("Custom navigation logic implementation test", () {});
}
