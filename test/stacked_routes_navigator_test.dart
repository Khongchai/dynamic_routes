import "package:flutter_test/flutter_test.dart";

//TODO think about a way to test everything. Right now the initiator and participator instance is tied the widget in which the mixin is attached.
// TODO test with the pages in the pages folder

void main() {
  testWidgets("Navigator load test", (WidgetTester tester) async {
    //
    // _mockInitiatorWidget(tester,
    //     andThen: (context, stackedRoutesInitiator) async {
    //   stackedRoutesInitiator.initializeNewStack(pageStack1);
    //   expect(stackedRoutesInitiator.getLoadedPages().length, pageStack1.length);
    //
    //   stackedRoutesInitiator.initializeNewStack(pageStack2);
    //   expect(stackedRoutesInitiator.getLoadedPages().length, pageStack2.length);
    //
    //   stackedRoutesInitiator.initializeNewStack(pageStack3);
    //   expect(stackedRoutesInitiator.getLoadedPages().length, pageStack3.length);
    // });
  });

  group("Navigation test", () {
    // testWidgets("Routes push correctly", (WidgetTester tester) async {
    //   await _mockInitiatorWidget(tester,
    //       andThen: (context, initiatorNavigator) {
    //     initiatorNavigator.initializeNewStack(pageStack4);
    //
    //     initiatorNavigator.pushFirst(context); // Page1();
    //   });
    //
    //   tester.tap(find.byKey(Key("")));
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
    //     stackedRoutesNavigator.pushNext(context,
    //         currentPage: pageStack4[2]); // current: Page3(), next: Page4();
    //
    //     expect(stackedRoutesNavigator.getCurrentWidgetHash(),
    //         pageStack4.last.hashCode); // Page4()
    //   });
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
    // });
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
