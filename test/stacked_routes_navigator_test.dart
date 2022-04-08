import 'package:dynamic_routing/dynamic_routes/mixins/initiator.dart';
import 'package:dynamic_routing/dynamic_routes/mixins/participator.dart';
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import 'package:mockito/mockito.dart';

class MockBuildContext extends Mock implements BuildContext {}

/// For testing the internal states of the navigator
class InitiatorPageMock extends StatefulWidget {
  final Key? pushFirstButtonKey;
  final Key? backButtonKey;

  /// Provide this if you wanna test the widget by tapping on the page's button.
  ///
  /// If testing the state, just give empty array.
  final List<Widget> participatorPages;

  const InitiatorPageMock({
    this.pushFirstButtonKey,
    this.backButtonKey,
    Key? key,
    required this.participatorPages,
  }) : super(key: key);

  @override
  State<InitiatorPageMock> createState() => _InitiatorPageMockState();
}

class _InitiatorPageMockState extends State<InitiatorPageMock>
    with DynamicRoutesInitiator {
  @override
  void dispose() {
    // Do nothing, we'll do it
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

class MockParticipatorWidget extends StatefulWidget {
  final Key? pushNextButtonKey;
  final Key? backButtonKey;

  const MockParticipatorWidget(
      {this.pushNextButtonKey, this.backButtonKey, Key? key})
      : super(key: key);

  @override
  State<MockParticipatorWidget> createState() => _MockParticipatorWidgetState();
}

class _MockParticipatorWidgetState extends State<MockParticipatorWidget>
    with DynamicRoutesParticipator {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            key: widget.pushNextButtonKey,
            onPressed: () {
              dynamicRoutesParticipator.pushNext(context);
            },
            child: const Text("Push First")),
        TextButton(
            key: widget.backButtonKey,
            onPressed: () => dynamicRoutesParticipator.popCurrent(context),
            child: const Text("Pop")),
      ],
    );
  }
}

_MockParticipatorWidgetState getParticipatorStateFromKey(
    WidgetTester tester, Key key) {
  return tester.state(find.byKey(key)) as _MockParticipatorWidgetState;
}

void main() {
  group("Navigation test", () {
    group("Navigator load test", () {
      testWidgets(
          "Test initializing a new stack and the initial binding between a widget and the initiator",
          (WidgetTester tester) async {
        const pageWidgetSet1 = [
          MockParticipatorWidget(),
          MockParticipatorWidget(),
          MockParticipatorWidget(),
          MockParticipatorWidget(),
          MockParticipatorWidget(),
          MockParticipatorWidget(),
          MockParticipatorWidget(),
          MockParticipatorWidget(),
          MockParticipatorWidget(),
        ];

        const initiatorPushFirstKey = Key("pushKey");
        await tester.pumpWidget(const InitiatorPageMock(
          participatorPages: pageWidgetSet1,
          pushFirstButtonKey: initiatorPushFirstKey,
        ));

        await tester.tap(find.byKey(initiatorPushFirstKey));

        final _InitiatorPageMockState initiatorWidgetState =
            tester.state(find.byType(InitiatorPageMock));

        expect(
            initiatorWidgetState.dynamicRoutesInitiator.getLoadedPages().length,
            pageWidgetSet1.length);
      });

      group("After initiation", () {
        testWidgets(
            "when disposed, reassignment from the same instance should be possible.",
            (WidgetTester tester) async {
          const participatorWidget = MockParticipatorWidget();
          await tester
              .pumpWidget(const InitiatorPageMock(participatorPages: []));

          final _InitiatorPageMockState initiatorWidgetState =
              tester.state(find.byType(InitiatorPageMock));

          initiatorWidgetState.dynamicRoutesInitiator
              .initializeRoutes([participatorWidget]);

          initiatorWidgetState.dynamicRoutesInitiator.dispose();

          // Shouldn't be any error
          initiatorWidgetState.dynamicRoutesInitiator
              .initializeRoutes([participatorWidget]);
        });

        testWidgets(
            "When not disposed, reassignment from the same instance should not be possible.",
            (WidgetTester tester) async {
          const participatorWidget = MockParticipatorWidget();
          await tester.pumpWidget(const InitiatorPageMock(
            participatorPages: [],
          ));

          final _InitiatorPageMockState initiatorWidgetState =
              tester.state(find.byType(InitiatorPageMock));

          initiatorWidgetState.dynamicRoutesInitiator
              .initializeRoutes([participatorWidget]);

          // We should be able to do this only once per the same set of widgets and there should be an assertion that guards this.
          expect(
              () => initiatorWidgetState.dynamicRoutesInitiator
                  .initializeRoutes([participatorWidget]),
              throwsAssertionError);
        });
      });
    });
    // testWidgets(
    //     "Dispose should be called automatically before each initialization to ensure a clean up.",
    //     (WidgetTester tester) async {
    //   const firstParticipatorKey = Key("fpk");
    //   const firstParticipatorNextButtonKey = Key("fnk");
    //   const secondParticipatorKey = Key("spk");
    //   const secondParticipatorNextButtonKey = Key("snk");
    //   const thirdParticipatorKey = Key("tpk");
    //   const thirdParticipatorNextButtonKey = Key("tnk");
    //   const fourthParticipatorKey = Key("tpk");
    //   const participatorPages = [
    //     MockParticipatorWidget(
    //         key: firstParticipatorKey,
    //         pushNextButtonKey: firstParticipatorNextButtonKey),
    //     MockParticipatorWidget(
    //       key: secondParticipatorKey,
    //       pushNextButtonKey: secondParticipatorNextButtonKey,
    //     ),
    //     MockParticipatorWidget(
    //       key: thirdParticipatorKey,
    //       pushNextButtonKey: thirdParticipatorNextButtonKey,
    //     ),
    //     MockParticipatorWidget(key: fourthParticipatorKey),
    //   ];
    //
    //   const initiatorPushFirstKey = Key("pushKey");
    //   await tester.pumpWidget(const InitiatorPageMock(
    //     participatorPages: participatorPages,
    //     pushFirstButtonKey: initiatorPushFirstKey,
    //   ));
    //
    //   await tester.tap(find.byKey(initiatorPushFirstKey));
    //   await tester.pumpAndSettle();
    //
    //   expect(
    //       getParticipatorStateFromKey(tester, firstParticipatorKey)
    //           .stackedRoutesParticipator
    //           .getCurrentWidgetHash(),
    //       participatorPages[0].hashCode);
    //
    //   await tester.tap(find.byKey(firstParticipatorNextButtonKey));
    //   await tester.pumpAndSettle();
    //   await tester.tap(find.byKey(secondParticipatorNextButtonKey));
    //   await tester.pumpAndSettle();
    //
    //   expect(
    //       getParticipatorStateFromKey(tester, thirdParticipatorKey)
    //           .stackedRoutesParticipator
    //           .getCurrentWidgetHash(),
    //       participatorPages[2].hashCode);
    //
    //   await tester.tap(find.byKey(thirdParticipatorNextButtonKey));
    //   await tester.pumpAndSettle();
    //
    //   expect(
    //       getParticipatorStateFromKey(tester, fourthParticipatorKey)
    //           .stackedRoutesParticipator
    //           .getCurrentWidgetHash(),
    //       participatorPages.last.hashCode);
    // });

    testWidgets("Routes push correctly", (WidgetTester tester) async {
      const firstParticipatorKey = Key("fpk");
      const firstParticipatorNextButtonKey = Key("fnk");
      const secondParticipatorKey = Key("spk");
      const secondParticipatorNextButtonKey = Key("snk");
      const thirdParticipatorKey = Key("tpk");
      const thirdParticipatorNextButtonKey = Key("tnk");
      const fourthParticipatorKey = Key("tpk");
      const participatorPages = [
        MockParticipatorWidget(
            key: firstParticipatorKey,
            pushNextButtonKey: firstParticipatorNextButtonKey),
        MockParticipatorWidget(
          key: secondParticipatorKey,
          pushNextButtonKey: secondParticipatorNextButtonKey,
        ),
        MockParticipatorWidget(
          key: thirdParticipatorKey,
          pushNextButtonKey: thirdParticipatorNextButtonKey,
        ),
        MockParticipatorWidget(key: fourthParticipatorKey),
      ];

      const initiatorPushFirstKey = Key("pushKey");
      await tester.pumpWidget(const InitiatorPageMock(
        participatorPages: participatorPages,
        pushFirstButtonKey: initiatorPushFirstKey,
      ));

      await tester.tap(find.byKey(initiatorPushFirstKey));
      await tester.pumpAndSettle();

      expect(
          getParticipatorStateFromKey(tester, firstParticipatorKey)
              .dynamicRoutesParticipator
              .getCurrentWidgetHash(),
          participatorPages[0].hashCode);

      await tester.tap(find.byKey(firstParticipatorNextButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(secondParticipatorNextButtonKey));
      await tester.pumpAndSettle();

      expect(
          getParticipatorStateFromKey(tester, thirdParticipatorKey)
              .dynamicRoutesParticipator
              .getCurrentWidgetHash(),
          participatorPages[2].hashCode);

      await tester.tap(find.byKey(thirdParticipatorNextButtonKey));
      await tester.pumpAndSettle();

      expect(
          getParticipatorStateFromKey(tester, fourthParticipatorKey)
              .dynamicRoutesParticipator
              .getCurrentWidgetHash(),
          participatorPages.last.hashCode);

      // await _mockParticipatorWidget(tester,
      //     andThen: (context, stackedRoutesNavigator) {
      //   expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //       pageStack4.first.hashCode);
      //
      //   stackedRoutesNavigator.pushNext(context,
      //       currentPage: pageStack4[0]); // current: Page1(), next: Page2();
      //   stackedRoutesNavigator.pushNext(context,
      //       currentPage: pageStack4[1]); // current: Page2(), next: Page3();
      //   stackedRoutesNavigator.pushNext(context,
      //       currentPage: pageStack4[2]); // current: Page3(), next: Page4();
      //
      //   expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //       pageStack4.last.hashCode); // Page4()
      // });
      //
      // testWidgets("Routes pop correctly", (WidgetTester tester) async {
      //   await _mockInitiatorWidget(tester,
      //       andThen: ((context, initiatorNavigator) {
      //     initiatorNavigator.initializeNewStack(pageStack4);
      //
      //     initiatorNavigator.pushFirst(context); // Page1();
      //   }));
      //
      //   await _mockParticipatorWidget(tester,
      //       andThen: (context, stackedRoutesNavigator) {
      //     expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //         pageStack4.first.hashCode);
      //
      //     stackedRoutesNavigator.pushNext(context,
      //         currentPage: pageStack4[0]); // current: Page1(), next: Page2();
      //     stackedRoutesNavigator.pushNext(context,
      //         currentPage: pageStack4[1]); // current: Page2(), next: Page3();
      //     stackedRoutesNavigator.popCurrent(context,
      //         currentPage: pageStack4[2]); // current: Page3(), next: Page2();
      //
      //     expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //         pageStack4[1].hashCode);
      //
      //     stackedRoutesNavigator.popCurrent(context,
      //         currentPage: pageStack4[1]); // current: Page2(), next: Page1();
      //
      //     expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //         pageStack4.first.hashCode);
      //
      //     stackedRoutesNavigator.pushNext(context,
      //         currentPage: pageStack4[0]); // current: Page1(), next: Page2();
      //     stackedRoutesNavigator.pushNext(context,
      //         currentPage: pageStack4[1]); // current: Page2(), next: Page3();
      //     expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //         pageStack4[2].hashCode);
      //   });
      // });
      //
      // testWidgets(
      //     "Routes push correctly even when the same pages are used more than once in the navigation stack",
      //     (WidgetTester tester) async {
      //   final duplicateWidgetsStack = [
      //     const Page1(),
      //     const Page2(),
      //     const Page2(),
      //   ];
      //   await _mockInitiatorWidget(tester,
      //       andThen: (context, initiatorNavigator) {
      //     initiatorNavigator.initializeNewStack(duplicateWidgetsStack);
      //
      //     initiatorNavigator.pushFirst(context);
      //   });
      //
      //   await _mockParticipatorWidget(tester,
      //       andThen: (context, stackedRoutesNavigator) {
      //     stackedRoutesNavigator.pushNext(context,
      //         currentPage: duplicateWidgetsStack[0]);
      //     stackedRoutesNavigator.pushNext(context,
      //         currentPage: duplicateWidgetsStack[1]);
      //
      //     // Should not be the same instance
      //     expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //         isNot(duplicateWidgetsStack[1].hashCode));
      //
      //     // Should be the same page
      //     expect(stackedRoutesNavigator.getCurrentWidgetHash(),
      //         duplicateWidgetsStack[2].hashCode);
      //   });
      // });
      //
      // testWidgets(
      //     "Routes push correctly after being interrupted by Navigator.pop()",
      //     (WidgetTester tester) async {
      //   await _mockInitiatorWidget(tester,
      //       andThen: (context, initiatorNavigator) {
      //     initiatorNavigator.initializeNewStack(
      //       pageStack4,
      //     );
      //
      //     initiatorNavigator.pushFirst(context);
      //   });
      //
      //   await _mockParticipatorWidget(tester,
      //       andThen: (context, stackedRoutesParticipator) {
      //     stackedRoutesParticipator.pushNext(context, currentPage: pageStack4[0]);
      //     stackedRoutesParticipator.pushNext(context, currentPage: pageStack4[1]);
      //     stackedRoutesParticipator.pushNext(context, currentPage: pageStack4[2]);
      //
      //     Navigator.of(context).pop();
      //
      //     stackedRoutesParticipator.pushNext(context, currentPage: pageStack4[2]);
      //
      //     expect(stackedRoutesParticipator.getCurrentWidgetHash(),
      //         pageStack4[3].hashCode);
      //   });
    });
  });

  // testWidgets("Test last page callback", (WidgetTester tester) async {
  //   const pages = [Page1(), Page2(), Page3()];
  //
  //   await _mockInitiatorWidget(tester,
  //       andThen: (context, stackedRoutesInitiator) async {
  //     stackedRoutesInitiator.initializeNewStack(pages,
  //         lastPageCallback: (BuildContext context) => Navigator.push(
  //             context, MaterialPageRoute(builder: (_) => const Page4())));
  //
  //     stackedRoutesInitiator.pushFirst(context);
  //   });
  //
  //   await _mockParticipatorWidget(tester,
  //       andThen: (context, stackedRoutesParticipator) {
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[0]);
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[1]);
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[2]);
  //
  //     expect(stackedRoutesParticipator.pushNextOfLastPageCalled(), true);
  //   });
  // });
  //
  // testWidgets(
  //     "Nested routes test when one of the pages is both an initiator and a participator",
  //     (WidgetTester tester) async {
  //   const pages = [Page1(), Page2(), Page3(), MixedPage(), Page5(), Page6()];
  //   const subPages = [SubPage1(), SubPage2(), SubPage3()];
  //
  //   await _mockInitiatorWidget(tester,
  //       andThen: (context, stackedRoutesInitiator) {
  //     stackedRoutesInitiator.initializeNewStack(pages);
  //     stackedRoutesInitiator.pushFirst(context);
  //   });
  //
  //   await _mockParticipatorWidget(tester,
  //       andThen: (context, stackedRoutesParticipator) async {
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[0]);
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[1]);
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[2]);
  //   });
  //
  //   /// With this new stack, we should be beginning a new flow.
  //   await _mockInitiatorWidget(tester,
  //       andThen: (context, stackedRoutesInitiator) {
  //     stackedRoutesInitiator.initializeNewStack(subPages,
  //         lastPageCallback: (context) {
  //       Navigator.of(context).pop();
  //       Navigator.of(context).pop();
  //       Navigator.of(context).pop();
  //     });
  //     stackedRoutesInitiator.pushFirst(context);
  //   });
  //
  //   await _mockParticipatorWidget(tester,
  //       andThen: (context, stackedRoutesParticipator) {
  //     expect(subPages[0].hashCode,
  //         stackedRoutesParticipator.getCurrentWidgetHash());
  //
  //     stackedRoutesParticipator.pushNext(context, currentPage: subPages[0]);
  //     stackedRoutesParticipator.pushNext(context, currentPage: subPages[1]);
  //     stackedRoutesParticipator.pushNext(context,
  //         currentPage: subPages[2]); // lastPageCallback calls pop() three times
  //
  //     expect(
  //         pages[3].hashCode, stackedRoutesParticipator.getCurrentWidgetHash());
  //
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[3]);
  //     stackedRoutesParticipator.pushNext(context, currentPage: pages[4]);
  //
  //     // Expect an error because we didn't assign a callback to this page initially and we call pushNext.
  //     expect(
  //         () => stackedRoutesParticipator.pushNext(context,
  //             currentPage: pages[5]),
  //         throwsAssertionError);
  //   });
  // });

  //TODO when no more routes to push, when first route not called, etc. basically all the assertion cases.
  group("Test gesture-based assertions", () {});

  group("Cache test", () {
    (WidgetTester tester) async {
      // //Assign a value to the routeCache in the first page
      // final mockCacheData = {"some-key": 1, "some-other-key": 2};
      // StackedRoutesNavigator.loadStack(pageStack1, routeCache: mockCacheData);
      //
      // stubWidgetAndPerformNavigationTest(tester, (context) {
      //   // Push the first page
      //   StackedRoutesNavigator.pushFirst(context);
      //
      //   // Push the second page
      //   StackedRoutesNavigator.pushNext(context,
      //       currentPage: pageStack1.first);
      //
      //   // Read data from cache in the second page
      //   final cachedData = StackedRoutesNavigator.getRouteCacheData();
      //
      //   expect(cachedData["some-key"], mockCacheData["some-key"]);
      //   expect(cachedData["some-other-key"], mockCacheData["some-other-key"]);
      //
      //   // Do something with the data and update the routeCache
      //   cachedData["some-key"]++;
      //   cachedData["some-other-key"]++;
      //   StackedRoutesNavigator.pushNext(context,
      //       currentPage: pageStack1[1], routeCache: cachedData);
      //
      //   expect(StackedRoutesNavigator.getCurrentWidgetHash(),
      //       const Page3().hashCode);
      //
      //   expect(cachedData["some-key"], mockCacheData["some-key"]! + 1);
      //   expect(
      //       cachedData["some-other-key"], mockCacheData["some-other-key"]! + 1);
      //
      //   StackedRoutesNavigator.clearData();
      // });
    };
  });
}
