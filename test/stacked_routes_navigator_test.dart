import 'package:dynamic_routing/pages/non_dynamic_route_participating_page.dart';
import 'package:dynamic_routing/pages/page1.dart';
import 'package:dynamic_routing/pages/page2.dart';
import 'package:dynamic_routing/pages/page3.dart';
import 'package:dynamic_routing/pages/page4.dart';
import 'package:dynamic_routing/pages/page5.dart';
import 'package:dynamic_routing/stacked_routes/stacked_navigator.dart';
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";

class _InitiatorWidgetStub extends StatelessWidget with StackedRoutesInitiator {
  final Function(
          BuildContext context, InitiatorNavigator stackedRoutesNavigator)
      postBuildCallback;

  _InitiatorWidgetStub({required this.postBuildCallback, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          postBuildCallback(context, stackedRoutesNavigator);
        });
        return Container();
      }),
    );
  }
}

Future<void> stubInitiatorWidget(WidgetTester tester,
    {required Function(
            BuildContext context, InitiatorNavigator initiatorNavigator)
        andThen}) async {
  await tester.pumpWidget(_InitiatorWidgetStub(postBuildCallback: andThen));
}

class _ParticipatorWidgetStub extends StatelessWidget
    with StackedRoutesParticipator {
  final Function(
          BuildContext context, ParticipatorNavigator participatorNavigator)
      postBuildCallback;

  _ParticipatorWidgetStub({required this.postBuildCallback, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          postBuildCallback(context, stackedRoutesNavigator);
        });
        return Container();
      }),
    );
  }
}

Future<void> stubParticipatorWidget(WidgetTester tester,
    {required Function(
            BuildContext context, ParticipatorNavigator stackedRoutesNavigator)
        andThen}) async {
  await tester.pumpWidget(_ParticipatorWidgetStub(postBuildCallback: andThen));
}

final pageStack1 = [
  Page1(),
  Page2(),
  Page3(),
  Page5(),
];
final pageStack2 = [
  Page1(),
  Page3(),
  Page5(),
];
final pageStack3 = [
  Page5(),
];

final pageStack4 = [
  Page1(),
  Page2(),
  Page3(),
  Page4(),
];

void main() {
  testWidgets("Navigator load test", (WidgetTester tester) async {
    stubInitiatorWidget(tester,
        andThen: (context, stackedRoutesNavigator) async {
      stackedRoutesNavigator.loadStack(pageStack1);
      expect(stackedRoutesNavigator.getLoadedPages().length, pageStack1.length);

      stackedRoutesNavigator.loadStack(pageStack2);
      expect(stackedRoutesNavigator.getLoadedPages().length, pageStack2.length);

      stackedRoutesNavigator.loadStack(pageStack3);
      expect(stackedRoutesNavigator.getLoadedPages().length, pageStack3.length);
    });
  });

  group("Navigation test", () {
    testWidgets("Routes push correctly", (WidgetTester tester) async {
      await stubInitiatorWidget(tester, andThen: (context, initiatorNavigator) {
        initiatorNavigator.loadStack(pageStack4);

        initiatorNavigator.pushFirst(context); // Page1();
      });

      await stubParticipatorWidget(tester,
          andThen: (context, stackedRoutesNavigator) {
        expect(stackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.first.hashCode);

        stackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[0]); // current: Page1(), next: Page2();
        stackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page3();
        stackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[2]); // current: Page3(), next: Page4();

        expect(stackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.last.hashCode); // Page4()

        stackedRoutesNavigator.clearData();
      });
    });

    testWidgets("Routes pop correctly", (WidgetTester tester) async {
      await stubInitiatorWidget(tester,
          andThen: ((context, initiatorNavigator) {
        initiatorNavigator.loadStack(pageStack4);

        initiatorNavigator.pushFirst(context); // Page1();
      }));

      await stubParticipatorWidget(tester,
          andThen: (context, stackedRoutesNavigator) {
        expect(stackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.first.hashCode);

        stackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[0]); // current: Page1(), next: Page2();
        stackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page3();
        stackedRoutesNavigator.popCurrent(context,
            currentWidget: pageStack4[2]); // current: Page3(), next: Page2();

        expect(stackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4[1].hashCode);

        stackedRoutesNavigator.popCurrent(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page1();

        expect(stackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4.first.hashCode);

        stackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[0]); // current: Page1(), next: Page2();
        stackedRoutesNavigator.pushNext(context,
            currentWidget: pageStack4[1]); // current: Page2(), next: Page3();
        expect(stackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4[2].hashCode);

        stackedRoutesNavigator.clearData();
      });
    });

    testWidgets(
        "Routes push correctly after being interrupted by Navigator.pop()",
        (WidgetTester tester) async {
      await stubInitiatorWidget(tester, andThen: (context, initiatorNavigator) {
        initiatorNavigator.loadStack(pageStack4);

        initiatorNavigator.pushFirst(context);
      });

      await stubParticipatorWidget(tester,
          andThen: (context, stackedRoutesNavigator) {
        stackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[0]);
        stackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[1]);
        stackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[2]);

        Navigator.of(context).pop();

        stackedRoutesNavigator.pushNext(context, currentWidget: pageStack4[2]);

        expect(stackedRoutesNavigator.getCurrentWidgetHash(),
            pageStack4[3].hashCode);

        stackedRoutesNavigator.clearData();
      });
    });
  });

  group("Dynamic route safeguard", () {
    testWidgets("throws assertion error when strict is true",
        (WidgetTester tester) async {
      await stubInitiatorWidget(tester, andThen: (context, initiatorNavigator) {
        final pageStack = [
          Page1(),
          Page2(),
          Page3(),
          const NonStackedRouteParticipatingPage(),
        ];

        // true is the default value
        expect(() => initiatorNavigator.loadStack(pageStack),
            throwsAssertionError);
      });
    });

    testWidgets("does not throw any error when strict is false ",
        (WidgetTester tester) async {
      await stubInitiatorWidget(tester,
          andThen: (context, stackedRouteInitiator) {
        final pageStack = [
          Page1(),
          Page2(),
          Page3(),
          const NonStackedRouteParticipatingPage(),
        ];

        stackedRouteInitiator.loadStack(pageStack, strict: false);
      });
    });
  });
  //TODO test for the initiator

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
      //   StackedRoutesNavigator.clearData();
      // });
    };
  });
}
