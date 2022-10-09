import 'package:dynamic_routes/dynamic_routes/navigation_logic_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_utils.dart';

class HomePage extends StatefulWidget {
  final Key pushInitiatorWidgetKey;
  final Widget initiatorPage;

  const HomePage(
      {required this.initiatorPage,
      required this.pushInitiatorWidgetKey,
      Key? key})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Builder(builder: (context) {
      return TextButton(
        child: const Text("Push Initiator Widget"),
        key: widget.pushInitiatorWidgetKey,
        onPressed: () {
          // Call this one first to make sure that the navigation page's context
          // can be used with a navigator.
          Navigator.of(context).push(MaterialPageRoute(
              // Won't be using the participatorPages array passed here.
              builder: (context) => widget.initiatorPage));
        },
      );
    }));
  }
}

class CustomNavigationLogicProvider extends NavigationLogicProviderImpl {
  final VoidCallback customNextCallback;
  final VoidCallback customBackCallback;

  const CustomNavigationLogicProvider(
      {required this.customNextCallback, required this.customBackCallback});

  @override
  void back<T>(args) {
    customBackCallback();

    super.back(args);
  }

  @override
  Future<T?> next<T>(args) async {
    customNextCallback();

    return super.next(args);
  }
}

void main() {
  group("Custom navigation logic implementation test", () {
    testWidgets("Replaces the navigation logic with just widgets replacement",
        (tester) async {
      final participators = TestingUtils.generateParticipatorWidget(5);
      final initiator = TestingUtils.generateInitiatorWidget(participators);

      const pushInitiatorWidgetKey = Key('push_initiator_button');
      await tester.pumpWidget(HomePage(
          initiatorPage: initiator,
          pushInitiatorWidgetKey: pushInitiatorWidgetKey));
      await tester.tap(find.byKey(pushInitiatorWidgetKey));
      await tester.pumpAndSettle();

      TestingUtils.expectPageExistsAtIndex(-1);

      // Initiator pushed

      final initiatorState =
          TestingUtils.getInitiatorWidgetStateFromKey(tester, initiator.key!);

      int customNextCallbackCount = 0;
      int customBackCallbackCount = 0;
      final customNavigationLogicProvider =
          CustomNavigationLogicProvider(customNextCallback: () {
        customNextCallbackCount++;
      }, customBackCallback: () {
        customBackCallbackCount++;
      });

      initiatorState.dynamicRoutesInitiator.initializeRoutes(participators);
      initiatorState.dynamicRoutesInitiator
          .setNavigationLogicProvider(customNavigationLogicProvider);
      initiatorState.dynamicRoutesInitiator
          .pushFirstThenFor(initiatorState.context, participators.length);
      await tester.pumpAndSettle();

      // Expect that the new logic is called everytime next() method is invoked.
      expect(customNextCallbackCount, participators.length);

      final lastParticipatorsState = TestingUtils.getParticipatorStateFromKey(
          tester, participators.last.key!);
      lastParticipatorsState.dynamicRoutesParticipator.popFor(
          lastParticipatorsState.context,
          lastParticipatorsState.dynamicRoutesParticipator
                  .getCurrentPageIndex() +
              1);
      await tester.pumpAndSettle();

      expect(customBackCallbackCount, participators.length);

      TestingUtils.expectPageExistsAtIndex(-1);
    });
  });
}
