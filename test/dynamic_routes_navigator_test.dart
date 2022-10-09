import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import 'pages.dart';
import 'testing_utils.dart';

void main() {
  final MockBuildContext context = MockBuildContext();

  group("Internal tests", () {
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

    testWidgets(
        "dynamicRoutesInitiator and dynamicRoutesParticipators are "
        "the same object", (tester) async {
      final participators = TestingUtils.generateParticipatorWidget(3);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiator);
      TestingUtils.expectCurrentPageToBe(-1);

      final initiatorState =
          TestingUtils.getInitiatorWidgetStateFromKey(tester, initiator.key!);

      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      await tester.pumpAndSettle();

      final firstParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[0].key!);

      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();

      final secondParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[1].key!);

      await tester.tap(find.byKey(participators[1].pushNextButtonKey!));
      await tester.pumpAndSettle();

      final thirdParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[2].key!);

      TestingUtils.expectCurrentPageToBe(2);

      expect(initiatorState.dynamicRoutesInitiator.navigator,
          firstParticipatorState.dynamicRoutesParticipator.navigator);
      expect(initiatorState.dynamicRoutesInitiator.navigator,
          secondParticipatorState.dynamicRoutesParticipator.navigator);
      expect(initiatorState.dynamicRoutesInitiator.navigator,
          thirdParticipatorState.dynamicRoutesParticipator.navigator);
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

      TestingUtils.expectCurrentPageToBe(0);

      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(participators[1].pushNextButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(2);

      await tester.tap(find.byKey(participators[2].pushNextButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(3);
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

      TestingUtils.expectCurrentPageToBe(0);

      await tester.tap(find.byKey(participators[0].pushNextButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(1);

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

      TestingUtils.expectCurrentPageToBe(-1);
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

      TestingUtils.expectCurrentPageToBe(4);

      final fifthParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[4].key!);
      fifthParticipatorState.dynamicRoutesParticipator.popFor(
          fifthParticipatorState.context,
          fifthParticipatorState.dynamicRoutesParticipator
              // test will pass if index is 4.
              .getCurrentPageIndex());
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(0);

      final firstParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[0].key!);
      firstParticipatorState.dynamicRoutesParticipator
          .popFor(firstParticipatorState.context, 99999);
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(-1);

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

      TestingUtils.expectCurrentPageToBe(1);
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
      TestingUtils.expectCurrentPageToBe(4);

      firstPageState.dynamicRoutesParticipator
          .popFor(firstPageState.context, 4);
      TestingUtils.expectCurrentPageToBe(4);

      firstPageState.dynamicRoutesParticipator
          .pushFor(firstPageState.context, 5);
      TestingUtils.expectCurrentPageToBe(4);

      expect(initiatorState.isLastPageCallbackCalled, true);
    });

    testWidgets(
        "popUntilInitiator should pops pages until the current initiator(the one "
        "that calls the method)", (tester) async {
      final participators = TestingUtils.generateParticipatorWidget(5);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      final initiatorState =
          await TestingUtils.pushInitiatorPageWithFullStateControl(
              initiator: initiator,
              participators: participators,
              tester: tester);

      initiatorState.dynamicRoutesInitiator.initializeRoutes(participators,
          lastPageCallback: (context) {
        initiatorState.dynamicRoutesInitiator.popUntilInitiatorPage(context);
      });
      initiatorState.dynamicRoutesInitiator
          .pushFirstThenFor(initiatorState.context, participators.length - 1);
      await tester.pumpAndSettle();

      // Expect last participator page.
      TestingUtils.expectCurrentPageToBe(4);

      await tester.tap(find.byKey(participators.last.pushNextButtonKey!));
      await tester.pumpAndSettle();

      // Back to first initiator page again.
      TestingUtils.expectCurrentPageToBe(-1);
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

      TestingUtils.expectCurrentPageToBe(4);

      final lastPageState = TestingUtils.getParticipatorStateFromKey(
          tester, participators.last.key!);
      lastPageState.dynamicRoutesParticipator.popFor(lastPageState.context,
          lastPageState.dynamicRoutesParticipator.getCurrentPageIndex() + 1);
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(-1);

      initiatorState.pushForCount = 9999999;
      await tester.tap(find.byKey(initiator.pushFirstWithForKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(4);
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
        // 1. Push initiator
        // 2. Push like 2 participators
        // 3. Push the mixed page
        // 4. From that mixed page, push 3 more participators pages with
        // lastCallback = popCurrent
        // 5. Once lastCallback is called, assert that we are back to the last
        // participator page from step 2.

        const baseParticipatorsIdentifier = "Base Participators";
        const nestedParticipatorsIdentifier = "Nested Participators";
        final baseParticipatorsSet = TestingUtils.generateParticipatorWidget(2,
            extraIdentifier: baseParticipatorsIdentifier);
        final nestedParticipatorsSet = TestingUtils.generateParticipatorWidget(
            2,
            extraIdentifier: nestedParticipatorsIdentifier);
        final mixedWidget = TestingUtils.generateMixedWidget(
            subPages: nestedParticipatorsSet, pageIndex: 2);

        final initiator = TestingUtils.generateInitiatorWidget(
            [...baseParticipatorsSet, mixedWidget]);

        await tester.pumpWidget(initiator);
        await tester.pumpAndSettle();

        TestingUtils.expectCurrentPageToBe(-1);

        await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
        await tester.pumpAndSettle();

        await tester
            .tap(find.byKey(baseParticipatorsSet[0].pushNextButtonKey!));
        await tester.pumpAndSettle();

        await tester
            .tap(find.byKey(baseParticipatorsSet[1].pushNextButtonKey!));
        await tester.pumpAndSettle();

        // Check that it's the MixedPage.
        TestingUtils.expectCurrentPageToBe(2);

        final mixedPageState =
            TestingUtils.getMixedWidgetStateFromKey(tester, mixedWidget.key!);
        bool isCallbackCalled = false;
        mixedPageState.lastPageCallback = (context) {
          isCallbackCalled = true;
          mixedPageState.dynamicRoutesParticipator.popCurrent(context);
        };
        await tester.tap(find.byKey(mixedWidget.branchOffButton!));
        await tester.pumpAndSettle();

        // Check that it's the first participator page of the nested set.
        TestingUtils.expectCurrentPageToBe(0);

        await tester
            .tap(find.byKey(nestedParticipatorsSet[0].pushNextButtonKey!));
        await tester.pumpAndSettle();

        await tester
            .tap(find.byKey(nestedParticipatorsSet[1].pushNextButtonKey!));
        await tester.pumpAndSettle();

        // Check that it's the second participator page of the base flow.
        TestingUtils.expectCurrentPageToBe(1);
        expect(find.text(nestedParticipatorsIdentifier), findsNothing);
        expect(find.text(baseParticipatorsIdentifier), findsOneWidget);

        // Check that the nested flow has ended
        expect(isCallbackCalled, true);
      });
    });
  });

}
