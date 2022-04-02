import 'package:dynamic_routing/pages/non_dynamic_route_participating_page.dart';
import 'package:dynamic_routing/pages/page1.dart';
import 'package:dynamic_routing/pages/page2.dart';
import 'package:dynamic_routing/pages/page3.dart';
import 'package:dynamic_routing/pages/page4.dart';
import 'package:dynamic_routing/pages/page5.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";

Future<void> stubWidgetAndPerformNavigationTest(
    WidgetTester tester, Function(BuildContext context) doStuff) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(builder: (context) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        doStuff(context);
      });
      return Container();
    }),
  ));
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
    expect(StackedRoutesNavigator.getCurrentRouteStack().length,
        pageStack1.length);

    StackedRoutesNavigator.loadStack(pageStack2);
    expect(StackedRoutesNavigator.getCurrentRouteStack().length,
        pageStack2.length);

    StackedRoutesNavigator.loadStack(pageStack3);
    expect(StackedRoutesNavigator.getCurrentRouteStack().length,
        pageStack3.length);
  });

  group("Navigation test", () {
    setUp(() {
      StackedRoutesNavigator.loadStack(pageStack4);
    });
    tearDown(() {
      StackedRoutesNavigator.clearStack();
    });

    testWidgets("Routes push correctly", (WidgetTester tester) async {
      stubWidgetAndPerformNavigationTest(tester, (context) {
        StackedRoutesNavigator.pushFirst(context); // Page1();

        expect(
            StackedRoutesNavigator.getCurrentRouteWidget(), pageStack4.first);

        StackedRoutesNavigator.pushNext(context); // Page2();
        StackedRoutesNavigator.pushNext(context); // Page3();
        StackedRoutesNavigator.pushNext(context); // Page4();

        expect(StackedRoutesNavigator.getCurrentRouteWidget(),
            pageStack4.last); // Page4()
      });
    });

    testWidgets("Routes pop correctly", (WidgetTester tester) async {
      stubWidgetAndPerformNavigationTest(tester, (context) {
        StackedRoutesNavigator.pushFirst(context); // Page1();

        expect(
            StackedRoutesNavigator.getCurrentRouteWidget(), pageStack4.first);

        StackedRoutesNavigator.pushNext(context); // Page2();
        StackedRoutesNavigator.pushNext(context); // Page3();
        StackedRoutesNavigator.popCurrent(context); // Page2();

        expect(StackedRoutesNavigator.getCurrentRouteWidget(),
            pageStack4[1]); // Page4()

        StackedRoutesNavigator.popCurrent(context); // Page1();

        expect(
            StackedRoutesNavigator.getCurrentRouteWidget(), pageStack4.first);
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
}
