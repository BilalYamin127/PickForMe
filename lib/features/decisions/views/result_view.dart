import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/decision.dart';

class ResultView extends StatelessWidget {
  final DecisionResult result;
  const ResultView({super.key, required this.result});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('The universe has spoken')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: const Text('🎉', style: TextStyle(fontSize: 88)),
            ),
            const SizedBox(height: 24),
            const Text(
              'AND THE WINNER IS…',
              style: TextStyle(
                letterSpacing: 3,
                fontWeight: FontWeight.w800,
                color: Color(0xff9577df),
              ),
            ),
            const SizedBox(height: 18),
            SelectableText(
              result.selectedOption,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(result.decisionTitle, textAlign: TextAlign.center),
            const SizedBox(height: 36),
            Builder(
              builder: (buttonContext) => FilledButton.icon(
                onPressed: () async {
                  try {
                    final box = buttonContext.findRenderObject() as RenderBox;
                    await SharePlus.instance.share(
                      ShareParams(
                        text: 'PickForMe selected: ${result.selectedOption}!',
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size,
                      ),
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sharing is unavailable on this device.',
                          ),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.ios_share),
                label: const Text('Share my result'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Pick again'),
            ),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    ),
  );
}
