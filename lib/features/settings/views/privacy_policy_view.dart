import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bundled policy stays readable without opening a browser or using a network.
class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  late final Future<String> _policy = rootBundle.loadString(
    'assets/legal/privacy-policy.md',
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy policy')),
    body: FutureBuilder<String>(
      future: _policy,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'The privacy policy could not be loaded. Please restart the app.',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: SelectionArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  for (final paragraph in snapshot.data!.trim().split('\n\n'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        paragraph.replaceFirst(RegExp(r'^#{1,2} '), ''),
                        style: paragraph.startsWith('## ')
                            ? Theme.of(context).textTheme.titleLarge
                            : paragraph.startsWith('# ')
                            ? Theme.of(context).textTheme.headlineSmall
                            : Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(height: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
