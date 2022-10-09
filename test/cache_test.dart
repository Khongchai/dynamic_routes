import 'package:flutter_test/flutter_test.dart';

import 'pages.dart';

import "package:flutter/material.dart";

void main() {
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

    testWidgets(
        "Once a navigation scope is disposed, the cache should be cleared",
        (tester) async {

        });
  });
}
