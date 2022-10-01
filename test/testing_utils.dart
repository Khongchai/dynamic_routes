import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dynamic_routes_navigator_test.dart';

class TestingUtils {
  TestingUtils._();

  static ParticipatorWidgetState getParticipatorStateFromKey(
      WidgetTester tester, Key key) {
    return tester.state(find.byKey(key)) as ParticipatorWidgetState;
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
      List<ParticipatorWidget> participators) {
    const key = Key("i");
    const backButtonKey = Key("i_b");
    const pushFirstButtonKey = Key("i_p");
    return InitiatorWidget(
      participatorPages: participators,
      key: key,
      backButtonKey: backButtonKey,
      pushFirstButtonKey: pushFirstButtonKey,
    );
  }
}
