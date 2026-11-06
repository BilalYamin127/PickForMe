import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/decision.dart';
import '../view_models/app_view_model.dart';
import '../view_models/picker_view_model.dart';
import '../widgets/decision_wheel.dart';

class PickerView extends ConsumerStatefulWidget {
  final DecisionList decision;
  const PickerView({super.key, required this.decision});
  @override
  ConsumerState<PickerView> createState() => _PickerViewState();
}

class _PickerViewState extends ConsumerState<PickerView>
    with SingleTickerProviderStateMixin {
  late final PickerViewModel vm;
  late final AnimationController controller;
  late Animation<double> rotation;
  int highlight = -1;
  int lastTick = -1;
  @override
  void initState() {
    super.initState();
    vm = PickerViewModel(widget.decision);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );
    rotation = const AlwaysStoppedAnimation(0);
    controller.addListener(() {
      final tick = (controller.value * 36).floor();
      if (tick != lastTick) {
        lastTick = tick;
        highlight = controller.value >= 1
            ? vm.winner!
            : (tick % widget.decision.options.length);
        final settings = ref.read(appViewModelProvider).settings;
        if (settings.soundEnabled) SystemSound.play(SystemSoundType.click);
        if (settings.vibrationEnabled && tick % 4 == 0) {
          HapticFeedback.selectionClick();
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    vm.dispose();
    super.dispose();
  }

  Future<void> spin() async {
    if (vm.busy) return;
    final target = vm.begin();
    lastTick = -1;
    rotation = Tween(
      begin: vm.rotation,
      end: target,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    setState(() {});
    await controller.forward(from: 0);
    if (!mounted) return;
    final state = ref.read(appViewModelProvider);
    final result = vm.finish(
      target,
      saved: state.lists.any((e) => e.id == widget.decision.id),
    );
    if (state.settings.vibrationEnabled) HapticFeedback.mediumImpact();
    try {
      await ref.read(appViewModelProvider.notifier).record(result);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Result could not be saved to history.'),
          ),
        );
      }
    }
    if (mounted) context.push('/result', extra: result);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !vm.busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('A little moment of chance')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.decision.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.decision.options.length} possibilities. One happy decision.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Center(
                child: SegmentedButton<SelectionMode>(
                  segments: const [
                    ButtonSegment(
                      value: SelectionMode.wheel,
                      icon: Icon(Icons.pie_chart_outline),
                      label: Text('Spin wheel'),
                    ),
                    ButtonSegment(
                      value: SelectionMode.list,
                      icon: Icon(Icons.shuffle),
                      label: Text('Shuffle list'),
                    ),
                  ],
                  selected: {vm.mode},
                  onSelectionChanged: vm.busy
                      ? null
                      : (s) => setState(() => vm.changeMode(s.first)),
                ),
              ),
              const SizedBox(height: 20),
              if (vm.mode == SelectionMode.wheel)
                DecisionWheel(
                  options: widget.decision.options,
                  rotation: rotation.value,
                )
              else
                ...List.generate(
                  widget.decision.options.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 90),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: highlight == i
                          ? const Color(0xff7958d6)
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: highlight == i ? Colors.white : null,
                        ),
                      ),
                      title: Text(
                        widget.decision.options[i],
                        style: TextStyle(
                          color: highlight == i ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: vm.busy ? null : spin,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(62),
                ),
                icon: Icon(
                  vm.mode == SelectionMode.wheel
                      ? Icons.rotate_right
                      : Icons.shuffle,
                ),
                label: Text(
                  vm.busy
                      ? 'A little suspense…'
                      : vm.mode == SelectionMode.wheel
                      ? 'Let’s spin!'
                      : 'Pick for me!',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Equal chances. No second guessing.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
