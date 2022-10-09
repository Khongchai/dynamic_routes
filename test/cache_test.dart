import 'package:flutter_test/flutter_test.dart';

import 'pages.dart';

import "package:flutter/material.dart";

import 'testing_utils.dart';

void main() {
  group("Cache test", () {
    testWidgets("Test read and write to cache", (WidgetTester tester) async {
      //Assign a value to the routeCache in the first page
      final mockCacheData = {"some-key": 1, "some-other-key": 2};

      final participators = TestingUtils.generateParticipatorWidget(3);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      await tester.pumpWidget(initiator);

      final InitiatorWidgetState initiatorState =
          tester.state(find.byType(InitiatorWidget));

      await tester.tap(find.byKey(initiator.pushFirstButtonKey!));
      initiatorState.dynamicRoutesInitiator.setCache(mockCacheData);
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
      await tester.tap(find.byKey(participators[2].pushNextButtonKey!));
      await tester.pumpAndSettle();

      expect(initiatorState.dynamicRoutesInitiator.getCache(), mockCacheData);
      expect(firstParticipatorState.dynamicRoutesParticipator.getCache(),
          mockCacheData);
      expect(secondParticipatorState.dynamicRoutesParticipator.getCache(),
          mockCacheData);
      expect(thirdParticipatorState.dynamicRoutesParticipator.getCache(),
          mockCacheData);
    });

    testWidgets(
        "Once a navigation scope is disposed, the cache should no longer have a "
        "reference to the value.", (tester) async {
      const cacheData = 0;

      final participators = TestingUtils.generateParticipatorWidget(3);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      final initiatorState =
          await TestingUtils.pushInitiatorPageWithFullStateControl(
              initiator: initiator,
              participators: participators,
              tester: tester);

      final dynamicRoutesInitiator = initiatorState.dynamicRoutesInitiator;

      dynamicRoutesInitiator.setCache(cacheData);

      expect(dynamicRoutesInitiator.getCache(), cacheData);

      dynamicRoutesInitiator.dispose();

      expect(dynamicRoutesInitiator.getCache(), null);
    });
  });
}
