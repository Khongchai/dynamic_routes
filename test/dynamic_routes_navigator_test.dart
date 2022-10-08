import 'package:dynamic_routes/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routes/dynamic_routes/mixins/participator.dart';
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import 'pages.dart';
import 'testing_utils.dart';

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
      firstPageState.dynamicRoutesParticipator.pushFor(
          firstPageState.context,
          firstPageState.dynamicRoutesParticipator
              .getProgressFromCurrentPage());
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

    testWidgets(
        "List of futures from pushFor completes when the pages that "
        "return them are popped", (tester) async {
      final participators = TestingUtils.generateParticipatorWidget(4);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiator);

      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      await tester.pumpAndSettle();

      // Participators pushed
      final firstPageState = TestingUtils.getParticipatorStateFromKey(
          tester, participators.first.key!);
      final List<Future> futures = firstPageState.dynamicRoutesParticipator
          .pushFor(firstPageState.context, participators.length - 1);

      expect(futures.length, 3);

      await tester.pumpAndSettle();

      final lastPageState = TestingUtils.getParticipatorStateFromKey(
          tester, participators.last.key!);
      lastPageState.dynamicRoutesParticipator
          .popCurrent(lastPageState.context, 4);
      await tester.pumpAndSettle();

      final secondToLastPageState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[participators.length - 2].key!);
      secondToLastPageState.dynamicRoutesParticipator
          .popCurrent(secondToLastPageState.context, 3);
      await tester.pumpAndSettle();

      final secondPageState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[participators.length - 3].key!);
      secondPageState.dynamicRoutesParticipator
          .popCurrent(secondPageState.context, 2);
      await tester.pumpAndSettle();

      final List<dynamic> values = await Future.wait(futures);
      // [2, 3, 4] in this exact order because, according to the docs, the
      // returned values from Future.wait is "a list of all the values that were
      // produced in the order that the futures are provided by iterating futures.
      expect(values, [2, 3, 4]);
    });

    testWidgets("pushFirstThenFor behaves correctly", (tester) async {
      final participators = TestingUtils.generateParticipatorWidget(5);
      final initiator =
          TestingUtils.generateInitiatorWidget(participators, pushForCount: 4);

      await tester.pumpWidget(initiator);

      final initiatorState =
          TestingUtils.getInitiatorWidgetStateFromKey(tester, initiator.key!);

      expect(initiatorState.isLastPageCallbackCalled, false);

      await tester.tap(find.byKey(initiator.pushFirstWithForKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(4);

      final lastPageState = TestingUtils.getParticipatorStateFromKey(
          tester, participators.last.key!);
      lastPageState.dynamicRoutesParticipator.popFor(lastPageState.context,
          lastPageState.dynamicRoutesParticipator.getCurrentPageIndex() + 1);
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(-1);

      initiatorState.pushForCount = 9999999;
      await tester.tap(find.byKey(initiator.pushFirstWithForKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(4);
      expect(initiatorState.isLastPageCallbackCalled, true);
    });

    testWidgets(
        "pushFirstThenFor contains all participators values, including"
        "the first one.", (tester) async {
      final participators = TestingUtils.generateParticipatorWidget(5);
      final initiator =
          TestingUtils.generateInitiatorWidget(participators, pushForCount: 4);

      await tester.pumpWidget(initiator);

      await tester.tap(find.byKey(initiator.pushFirstWithForKey!));
      await tester.pumpAndSettle();

      final initiatorPageState =
          TestingUtils.getInitiatorWidgetStateFromKey(tester, initiator.key!);
      final List<Future> futures = initiatorPageState.pushFirstThenForFutures;

      expect(futures.length, 5);

      for (int i = participators.length - 1; i >= 0; i--) {
        final pageState = TestingUtils.getParticipatorStateFromKey(
            tester, participators[i].key!);
        pageState.dynamicRoutesParticipator.popCurrent(pageState.context, i);
        await tester.pumpAndSettle();
      }

      final List<dynamic> values = await Future.wait(futures);
      expect(values, [0, 1, 2, 3, 4]);
    });

    group("Nested navigation", () {
      testWidgets(
          "In a nested navigation, using popCurrent should guarantees that"
          "the current participator page will be popped along with all routes it "
          "initiated as an Initiator", (tester) async {
        final participatorsSet1 = TestingUtils.generateParticipatorWidget(5);
        final participatorsSet2 = TestingUtils.generateParticipatorWidget(5);
        final initiator = TestingUtils.generateInitiatorWidget([]);
        //TODO once you get it, see it fails first using the first version.

        // 1. Push initiator
        // 2. Push like 2 participators
        // 3. Push the mixed page
        // 4. From that mixed page, push 3 more participators pages with
        // lastCallback = popCurrent
        // 5. Once lastCallback is called, assert that we are back to the last
        // participator page from step 2.
      });
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
}
