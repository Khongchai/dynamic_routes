import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pages.dart';

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

  static MixedWidgetState getMixedWidgetStateFromKey(
      WidgetTester tester, Key key) {
    return tester.state(find.byKey(key)) as MixedWidgetState;
  }

  /// Index -1 = initiator page.
  /// Index > -1 = participator pages.
  static void expectCurrentPageToBe(int number) {
    expect(find.text(currentPageIndexText + number.toString()), findsOneWidget);
  }

  /// For generating participator with keys.
  static List<ParticipatorWidget> generateParticipatorWidget(int amount,
      {String? extraIdentifier}) {
    final List<ParticipatorWidget> list = [];
    for (int i = 0; i < amount; i++) {
      final key = Key("p_$i");
      final nextButtonKey = Key("p_n_$i");
      final backButtonKey = Key("p_b_$i");
      final backButtonWithValueKey = Key("p_bwv_$i");
      list.add(ParticipatorWidget(
        pageIndex: i,
        pushNextButtonKey: key,
        extraIdentifier: extraIdentifier,
        backButtonKey: nextButtonKey,
        backButtonWithValueKey: backButtonKey,
        key: backButtonWithValueKey,
      ));
    }

    return list;
  }

  static MixedWidget generateMixedWidget({
    required List<ParticipatorWidget> subPages,
    Function(BuildContext context)? lastPageCallback,
    required int pageIndex,
  }) {
    const key = Key("m");
    const branchOffButtonKey = Key("b_o_b");
    const continueFlowButtonKey = Key("c_f_b");
    return MixedWidget(
      subPages: subPages,
      lastPageCallback: lastPageCallback,
      key: key,
      branchOffButton: branchOffButtonKey,
      pageIndex: pageIndex,
      continueFlowButton: continueFlowButtonKey,
    );
  }

  static InitiatorWidget generateInitiatorWidget(List<Widget> participators,

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

  static Future<InitiatorWidgetState> pushInitiatorPageWithFullStateControl({
    required InitiatorWidget initiator,
    required List<Widget> participators,
    required WidgetTester tester,
  }) async {
    const pushInitiatorWidgetKey = Key('push_initiator_button');
    await tester.pumpWidget(HomePage(
        initiatorPage: initiator,
        pushInitiatorWidgetKey: pushInitiatorWidgetKey));
    await tester.tap(find.byKey(pushInitiatorWidgetKey));
    await tester.pumpAndSettle();

    assert(initiator.key != null);

    return getInitiatorWidgetStateFromKey(tester, initiator.key!);
  }
}
