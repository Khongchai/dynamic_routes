import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dynamic_routes_navigator_test.dart';

class TestingUtils {
  TestingUtils._();

  static ParticipatorWidgetState getParticipatorStateFromKey(
      WidgetTester tester, Key key) {
    return tester.state(find.byKey(key)) as ParticipatorWidgetState;
  }

  static InitiatorWidgetState getInitiatorWidgetStateFromKey(
      WidgetTester tester, Key key) {
    return tester.state(find.byKey(key)) as InitiatorWidgetState;
  }

  /// Index -1 = initiator page.
  /// Index > -1 = participator pages.
  static void expectPageExistsAtIndex(int number) {
    expect(find.text(currentPageIndexText + number.toString()), findsOneWidget);
  }

  /// For generating participator with keys.
  static List<ParticipatorWidget> generateParticipatorWidget(int amount) {
    final List<ParticipatorWidget> list = [];
    for (int i = 0; i < amount; i++) {
      final key = Key("p_$i");
      final nextButtonKey = Key("p_n_$i");
      final backButtonKey = Key("p_b_$i");
      final backButtonWithValueKey = Key("p_bwv_$i");
      list.add(ParticipatorWidget(
        pageIndex: i,
        pushNextButtonKey: key,
        backButtonKey: nextButtonKey,
        backButtonWithValueKey: backButtonKey,
        key: backButtonWithValueKey,
      ));
    }

    return list;
  }

  static InitiatorWidget generateInitiatorWidget(
      List<ParticipatorWidget> participators,

      /// [pushForCount] should be length of participators - 1 because pushFirst
      /// already pushes one page, then pushFor comes in and pushes the rest.
      {pushForCount = 0}) {
    const key = Key("i");
    const backButtonKey = Key("i_b");
    const pushFirstButtonKey = Key("i_p");
    const pushFirstThenForButtonKey = Key("i_p_t_f");
    return InitiatorWidget(
      pushForCount: pushForCount,
      participatorPages: participators,
      pushFirstWithForKey: pushFirstThenForButtonKey,
      key: key,
      backButtonKey: backButtonKey,
      pushFirstButtonKey: pushFirstButtonKey,
    );
  }
}
