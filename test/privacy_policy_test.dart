import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_for_me/features/settings/views/privacy_policy_view.dart';

void main() {
  testWidgets(
    'The bundled privacy policy is readable offline with the public contact',
    (tester) async {
      final policy = await tester.runAsync(
        () => rootBundle.loadString('assets/legal/privacy-policy.md'),
      );
      expect(policy, contains('zulqarnain.tech9068@gmail.com'));
      expect(policy, isNot(contains('support@pickforme.example')));
      await tester.runAsync(() async {
        await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyView()));
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pumpAndSettle();
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Privacy Policy for PickForMe'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('7. Retention and deletion'),
        400,
      );
      expect(find.text('7. Retention and deletion'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
