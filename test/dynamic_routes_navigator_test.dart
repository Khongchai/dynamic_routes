import 'package:dynamic_routes/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routes/dynamic_routes/mixins/participator.dart';
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import 'package:mockito/mockito.dart';

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
  State<InitiatorWidget> createState() => _InitiatorWidgetState();
}

class _InitiatorWidgetState extends State<InitiatorWidget>
    with DynamicRoutesInitiator {
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
            TextButton(
                key: widget.pushFirstButtonKey,
                onPressed: () {
                  dynamicRoutesInitiator
                      .initializeRoutes(widget.participatorPages);
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
  State<ParticipatorWidget> createState() => _ParticipatorWidgetState();
}

class _ParticipatorWidgetState extends State<ParticipatorWidget>
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

_ParticipatorWidgetState getParticipatorStateFromKey(
    WidgetTester tester, Key key) {
  return tester.state(find.byKey(key)) as _ParticipatorWidgetState;
}

void main() {
  final MockBuildContext context = MockBuildContext();
  group("Navigation test", () {
    group("Navigator load test", () {
      testWidgets(
          "Test initializing a new stack and the initial binding between a widget and the initiator",
          (WidgetTester tester) async {
        const pageWidgetSet1 = [
          ParticipatorWidget(),
          ParticipatorWidget(),
          ParticipatorWidget(),
          ParticipatorWidget(),
          ParticipatorWidget(),
          ParticipatorWidget(),
          ParticipatorWidget(),
          ParticipatorWidget(),
          ParticipatorWidget(),
        ];

        const initiatorPushFirstKey = Key("pushKey");
        await tester.pumpWidget(const InitiatorWidget(
          participatorPages: pageWidgetSet1,
          pushFirstButtonKey: initiatorPushFirstKey,
        ));

        await tester.tap(find.byKey(initiatorPushFirstKey));

        final _InitiatorWidgetState initiatorWidgetState =
            tester.state(find.byType(InitiatorWidget));

        expect(
            initiatorWidgetState.dynamicRoutesInitiator.getLoadedPages().length,
            pageWidgetSet1.length);
      });

      group("Before initialization", () {
        testWidgets(
            "Calling pushFirst without calling initializeRoutes should "
            "throw an assertion error", (WidgetTester tester) async {
          await tester.pumpWidget(const InitiatorWidget(participatorPages: []));

          final _InitiatorWidgetState initiatorWidgetState =
              tester.state(find.byType(InitiatorWidget));

          expect(
              () => initiatorWidgetState.dynamicRoutesInitiator
                  .pushFirst(context),
              throwsAssertionError);
        });
      });

      group("After initiation", () {
        testWidgets(
            "when disposed, reassignment from the same instance should be possible.",
            (WidgetTester tester) async {
          const participatorWidget = ParticipatorWidget();
          await tester.pumpWidget(const InitiatorWidget(participatorPages: []));

          final _InitiatorWidgetState initiatorWidgetState =
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

          final _InitiatorWidgetState initiatorWidgetState =
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

        final _InitiatorWidgetState initiatorWidgetState =
            tester.state(find.byType(InitiatorWidget));

        initiatorWidgetState.dynamicRoutesInitiator
            .initializeRoutes([const ParticipatorWidget()]);

        initiatorWidgetState.dynamicRoutesInitiator.dispose();

        expect(
            () =>
                initiatorWidgetState.dynamicRoutesInitiator.pushFirst(context),
            throwsAssertionError);
      });

      testWidgets(
          "When disposed, getLoadedPages() expect an assertion to be thrown "
          "when trying to queried for existing participators (should always"
          "throw assertion error when array empty).",
          (WidgetTester tester) async {
        await tester.pumpWidget(
            const InitiatorWidget(participatorPages: [ParticipatorWidget()]));

        final _InitiatorWidgetState initiatorWidgetState =
            tester.state(find.byType(InitiatorWidget));

        initiatorWidgetState.dynamicRoutesInitiator.dispose();

        expect(
            () => initiatorWidgetState.dynamicRoutesInitiator.getLoadedPages(),
            throwsAssertionError);
      });
    });

    group("Interaction testing", () {
      testWidgets("Push first page, pop, and then push again.",
          (WidgetTester tester) async {
        const initiatorPushFirstKey = Key("pushKey");
        const participatorBackButtonKey = Key("backKey");
        await tester.pumpWidget(const InitiatorWidget(
          participatorPages: [
            ParticipatorWidget(
              backButtonKey: participatorBackButtonKey,
            ),
          ],
          pushFirstButtonKey: initiatorPushFirstKey,
        ));

        await tester.tap(find.byKey(initiatorPushFirstKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(participatorBackButtonKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(initiatorPushFirstKey));
        await tester.pumpAndSettle();
      });

      testWidgets(
          "Popping with value using dynamicRoutesNavigator should work like Navigator.pop",
          (WidgetTester tester) async {
        const initiatorPushFirstKey = Key("pushKey");
        const participatorPushNextKey = Key("pushNextKey");
        const participatorBackButtonWithValueKey = Key("backKeyWithValue");
        await tester.pumpWidget(const InitiatorWidget(
          participatorPages: [
            ParticipatorWidget(
              pushNextButtonKey: participatorPushNextKey,
            ),
            ParticipatorWidget(
              backButtonWithValueKey: participatorBackButtonWithValueKey,
            ),
          ],
          pushFirstButtonKey: initiatorPushFirstKey,
        ));

        await tester.tap(find.byKey(initiatorPushFirstKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(participatorPushNextKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(participatorBackButtonWithValueKey));
        await tester.pumpAndSettle();

        final foundText = find.text(valueForPreviousPage);
        expect(foundText, findsOneWidget);
      });

      testWidgets("popFor behaves correctly.", (WidgetTester tester) async {
        const firstParticipatorNextButtonKey = Key("fnk");
        const secondParticipatorNextButtonKey = Key("snk");
        const thirdParticipatorNextButtonKey = Key("tnk");
        const fourthParticipatorNextButtonKey = Key("fnk");
        const fifthParticipatorKey = Key("fipk");
        const participatorPages = [
          ParticipatorWidget(pushNextButtonKey: firstParticipatorNextButtonKey),
          ParticipatorWidget(
            pushNextButtonKey: secondParticipatorNextButtonKey,
          ),
          ParticipatorWidget(
            pushNextButtonKey: thirdParticipatorNextButtonKey,
          ),
          ParticipatorWidget(
            pushNextButtonKey: fourthParticipatorNextButtonKey,
          ),
          ParticipatorWidget(key: fifthParticipatorKey),
        ];

        const initiatorPushFirstKey = Key("pushKey");
        await tester.pumpWidget(const InitiatorWidget(
          participatorPages: participatorPages,
          pushFirstButtonKey: initiatorPushFirstKey,
        ));

        await tester.tap(find.byKey(initiatorPushFirstKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(firstParticipatorNextButtonKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondParticipatorNextButtonKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(thirdParticipatorNextButtonKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(fourthParticipatorNextButtonKey));
        await tester.pumpAndSettle();
        //
        // getParticipatorStateFromKey(tester, fifthParticipatorKey)
        //     .dynamicRoutesParticipator
        //     .popFor(4);
        //
        // expect(
        //     getParticipatorStateFromKey(tester, fifthParticipatorKey)
        //         .dynamicRoutesParticipator
        //         .getCurrentWidgetHash(),
        //     participatorPages[0]);
      });

      testWidgets("Routes get pushed correctly ", (WidgetTester tester) async {
        const firstParticipatorKey = Key("fpk");
        const firstParticipatorNextButtonKey = Key("fnk");
        const secondParticipatorKey = Key("spk");
        const secondParticipatorNextButtonKey = Key("snk");
        const thirdParticipatorKey = Key("tpk");
        const thirdParticipatorNextButtonKey = Key("tnk");
        const fourthParticipatorKey = Key("tpk");
        const participatorPages = [
          ParticipatorWidget(
            key: firstParticipatorKey,
            pushNextButtonKey: firstParticipatorNextButtonKey,
            pageIndex: 0,
          ),
          ParticipatorWidget(
            key: secondParticipatorKey,
            pushNextButtonKey: secondParticipatorNextButtonKey,
            pageIndex: 1,
          ),
          ParticipatorWidget(
            key: thirdParticipatorKey,
            pushNextButtonKey: thirdParticipatorNextButtonKey,
            pageIndex: 2,
          ),
          ParticipatorWidget(key: fourthParticipatorKey, pageIndex: 3),
        ];

        const initiatorPushFirstKey = Key("pushKey");
        await tester.pumpWidget(const InitiatorWidget(
          participatorPages: participatorPages,
          pushFirstButtonKey: initiatorPushFirstKey,
        ));

        await tester.tap(find.byKey(initiatorPushFirstKey));
        await tester.pumpAndSettle();

        expect(find.text(currentPageIndexText + "0"), findsOneWidget);

        await tester.tap(find.byKey(firstParticipatorNextButtonKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(secondParticipatorNextButtonKey));
        await tester.pumpAndSettle();

        expect(find.text(currentPageIndexText + "2"), findsOneWidget);

        await tester.tap(find.byKey(thirdParticipatorNextButtonKey));
        await tester.pumpAndSettle();

        expect(find.text(currentPageIndexText + "3"), findsOneWidget);
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
        final _InitiatorWidgetState initiatorState =
            tester.state(find.byType(InitiatorWidget));

        await tester.tap(find.byKey(pushFirstButtonKey));
        initiatorState.dynamicRoutesInitiator.setCache(mockCacheData);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(firstPagePushNextKey));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(secondPagePushNextKey));
        await tester.pumpAndSettle();

        final _ParticipatorWidgetState stateToTest =
            tester.state(find.byWidget(thirdWidget));

        expect(stateToTest.dynamicRoutesParticipator.getCache(), mockCacheData);
      });
    });
  });
}
