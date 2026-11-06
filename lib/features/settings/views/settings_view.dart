import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../decisions/view_models/app_view_model.dart';
import '../../../shared/widgets/page_frame.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appViewModelProvider).settings;
    final vm = ref.read(appViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Make yourself at home')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'THE LITTLE DETAILS',
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Sound effects'),
                      subtitle: const Text(
                        'A little click with every possibility',
                      ),
                      secondary: const Icon(Icons.volume_up_outlined),
                      value: s.soundEnabled,
                      onChanged: (v) =>
                          vm.settings(s.copyWith(soundEnabled: v)),
                    ),
                    SwitchListTile(
                      title: const Text('Vibration'),
                      subtitle: const Text(
                        'Feel the moment on supported devices',
                      ),
                      secondary: const Icon(Icons.vibration),
                      value: s.vibrationEnabled,
                      onChanged: (v) =>
                          vm.settings(s.copyWith(vibrationEnabled: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: s.themeMode,
                decoration: const InputDecoration(
                  labelText: 'Appearance',
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text('Follow device'),
                  ),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (v) => vm.settings(s.copyWith(themeMode: v)),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: const Text('Clear decision history'),
                onTap: () async {
                  if (await confirmClear(context)) await vm.clearHistory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy policy'),
                subtitle: const Text(
                  'How your information stays on your device',
                ),
                onTap: () => context.push('/privacy'),
              ),
              const SizedBox(height: 40),
              const Text(
                'PickForMe\nA little less overthinking.\nAll your lists stay on this device.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
