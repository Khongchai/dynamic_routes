import 'package:dynamic_routes/dynamic_routes/navigation_logic_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import "package:flutter/material.dart";

import 'pages.dart';
import 'testing_utils.dart';

class NavigationLogger extends NavigationLogicProviderImpl {
  int nextCount = 0;
  int backCount = 0;

  @override
  Future<T?> next<T>(NextArguments args) {
    nextCount++;

    return super.next(args);
  }

  @override
  @mustCallSuper
  void back<T>(BackArguments args) {
    backCount++;

    super.back(args);
  }
}

void main() {
  late NavigationLogger navigationLogger;

  setUp(() {
    navigationLogger = NavigationLogger();
  });

  group("Double guard tests", () {
    final participators = TestingUtils.generateParticipatorWidget(5);
    final initiator = TestingUtils.generateInitiatorWidget(participators);

    Future<InitiatorWidgetState> setUpTest(WidgetTester tester) async {
      await TestingUtils.pushInitiatorPageWithFullStateControl(
          initiator: initiator, participators: participators, tester: tester);

      TestingUtils.expectCurrentPageToBe(-1);

      final initiatorState =
          TestingUtils.getInitiatorWidgetStateFromKey(tester, initiator.key!);
      initiatorState.dynamicRoutesInitiator.initializeRoutes(participators);
      initiatorState.dynamicRoutesInitiator
          .setNavigationLogicProvider(navigationLogger);

      return initiatorState;
    }

    testWidgets(
        "Calling pushFirst from the same page twice should be the same as calling it once.",
        (tester) async {
      final initiatorState = await setUpTest(tester);

      initiatorState.dynamicRoutesInitiator.pushFirst(initiatorState.context);
      initiatorState.dynamicRoutesInitiator.pushFirst(initiatorState.context);
      initiatorState.dynamicRoutesInitiator.pushFirst(initiatorState.context);
      initiatorState.dynamicRoutesInitiator.pushFirst(initiatorState.context);
      initiatorState.dynamicRoutesInitiator.pushFirst(initiatorState.context);
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(0);

      await tester.tap(find.byKey(participators[0].backButtonKey!));
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(-1);

      expect(navigationLogger.nextCount, 1);
      expect(navigationLogger.backCount, 1);
    });

    testWidgets(
        "Calling popCurrent from the same page twice should be the same as calling it once.",
        (tester) async {
      final initiatorState = await setUpTest(tester);

      initiatorState.dynamicRoutesInitiator.pushFirst(initiatorState.context);
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(0);

      final firstParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[0].key!);
      firstParticipatorState.dynamicRoutesParticipator
          .pushNext(firstParticipatorState.context);
      firstParticipatorState.dynamicRoutesParticipator
          .pushNext(firstParticipatorState.context);
      firstParticipatorState.dynamicRoutesParticipator
          .pushNext(firstParticipatorState.context);
      firstParticipatorState.dynamicRoutesParticipator
          .pushNext(firstParticipatorState.context);
      firstParticipatorState.dynamicRoutesParticipator
          .pushNext(firstParticipatorState.context);
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(1);

      expect(navigationLogger.nextCount, 2);
      expect(navigationLogger.backCount, 0);
    });

    testWidgets(
        "Calling popCurrent from the same page twice should be the same as calling it once.",
        (tester) async {
      final initiatorState = await setUpTest(tester);

      initiatorState.dynamicRoutesInitiator.pushFirst(initiatorState.context);
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(0);

      final firstParticipatorState = TestingUtils.getParticipatorStateFromKey(
          tester, participators[0].key!);
      firstParticipatorState.dynamicRoutesParticipator
          .popCurrent(firstParticipatorState.context);
      firstParticipatorState.dynamicRoutesParticipator
          .popCurrent(firstParticipatorState.context);
      firstParticipatorState.dynamicRoutesParticipator
          .popCurrent(firstParticipatorState.context);
      firstParticipatorState.dynamicRoutesParticipator
          .popCurrent(firstParticipatorState.context);
      await tester.pumpAndSettle();

      TestingUtils.expectCurrentPageToBe(-1);

      expect(navigationLogger.nextCount, 1);
      expect(navigationLogger.nextCount, 1);
    });
  });
}
