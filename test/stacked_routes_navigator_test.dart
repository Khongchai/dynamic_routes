import 'package:dynamic_routing/pages/non_dynamic_route_participating_page.dart';
import 'package:dynamic_routing/pages/page1.dart';
import 'package:dynamic_routing/pages/page2.dart';
import 'package:dynamic_routing/pages/page3.dart';
import 'package:dynamic_routing/pages/page4.dart';
import 'package:dynamic_routing/pages/page5.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";

class _TestWidgetForNavigationStubbing extends StatelessWidget {
  final Function(BuildContext context) postBuildCallback;

  const _TestWidgetForNavigationStubbing(
      {required this.postBuildCallback, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          postBuildCallback(context);
        });
        return Container();
      }),
    );
  }
}

Future<void> stubMaterialWidget(WidgetTester tester,
    {required Function(BuildContext context) andThen}) async {
  await tester
      .pumpWidget(_TestWidgetForNavigationStubbing(postBuildCallback: andThen));
}

final pageStack1 = [
  const Page1(),
  const Page2(),
  const Page3(),
  const Page5(),
];
final pageStack2 = [
  const Page1(),
  const Page3(),
  const Page5(),
];
final pageStack3 = [
  const Page5(),
];

final pageStack4 = [
  const Page1(),
  const Page2(),
  const Page3(),
  const Page4(),
];

void main() {
  test("Navigator load test", () {
    StackedRoutesNavigator.loadStack(pageStack1);
    expect(StackedRoutesNavigator.getLoadedPages().length, pageStack1.length);

    StackedRoutesNavigator.loadStack(pageStack2);
    expect(StackedRoutesNavigator.getLoadedPages().length, pageStack2.length);

    StackedRoutesNavigator.loadStack(pageStack3);
    expect(StackedRoutesNavigator.getLoadedPages().length, pageStack3.length);
  });

  group("Navigation test", () {
    setUp(() {
      StackedRoutesNavigator.loadStack(pageStack4);
    });
    tearDown(() {
      StackedRoutesNavigator.cleanUp();
    });

    testWidgets("Routes push correctly", (WidgetTester tester) async {
      stubMaterialWidget(tester, andThen: (context) {
        StackedRoutesNavigator.pushFirst(context); // Page1();

        expect(StackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.first.hashCode);

        StackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[0]); // current: Page1(), next: Page2();
        StackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page3();
        StackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[2]); // current: Page3(), next: Page4();

        expect(StackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.last.hashCode); // Page4()
      });
    });

    testWidgets("Routes pop correctly", (WidgetTester tester) async {
      stubMaterialWidget(tester, andThen: (context) {
        StackedRoutesNavigator.pushFirst(context); // Page1();

        expect(StackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.first.hashCode);

        StackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[0]); // current: Page1(), next: Page2();
        StackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page3();
        StackedRoutesNavigator.popCurrent(context,
            currentWidget: pageStack4[2]); // current: Page3(), next: Page2();

        expect(StackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4[1].hashCode);

        StackedRoutesNavigator.popCurrent(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page1();

        expect(StackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.first.hashCode);

        StackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[0]); // current: Page1(), next: Page2();
        StackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page3();
        expect(StackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4[2].hashCode);
      });
    });

    testWidgets(
        "Routes push correctly after being interrupted by Navigator.pop()",
        (WidgetTester tester) async {
      stubMaterialWidget(tester, andThen: (context) {
        StackedRoutesNavigator.pushFirst(context);
        StackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[0]);
        StackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[1]);
        StackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[2]);

        Navigator.of(context).pop();

        StackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[2]);

        expect(StackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4[3].hashCode);
      });
    });
  });

  group("Dynamic route safeguard", () {
    testWidgets("throws assertion error when strict is true",
        (WidgetTester tester) async {
      final pageStack = [
        const Page1(),
        const Page2(),
        const Page3(),
        const NonDynamicRouteParticipatingPage(),
      ];

      // true is the default value
      expect(() => StackedRoutesNavigator.loadStack(pageStack),
          throwsAssertionError);
    });

    testWidgets("does not throw any error when strict is false ",
        (WidgetTester tester) async {
      final pageStack = [
        const Page1(),
        const Page2(),
        const Page3(),
        const NonDynamicRouteParticipatingPage(),
      ];

      StackedRoutesNavigator.loadStack(pageStack, strict: false);
    });
  });

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
      //       currentWidget: pageStack1.first);
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
      //       currentWidget: pageStack1[1], routeCache: cachedData);
      //
      //   expect(StackedRoutesNavigator.getCurrentWidgetHash(),
      //       const Page3().hashCode);
      //
      //   expect(cachedData["some-key"], mockCacheData["some-key"]! + 1);
      //   expect(
      //       cachedData["some-other-key"], mockCacheData["some-other-key"]! + 1);
      //
      //   StackedRoutesNavigator.cleanUp();
      // });
    };
  });
}
