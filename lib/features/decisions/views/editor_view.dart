import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/decision.dart';
import '../view_models/editor_view_model.dart';
import '../view_models/app_view_model.dart';

class EditorView extends ConsumerStatefulWidget {
  final DecisionList? initial;
  const EditorView({super.key, this.initial});
  @override
  ConsumerState<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends ConsumerState<EditorView> {
  late final EditorViewModel vm;
  bool saving = false;
  String? error;
  final keys = <Object>[];
  @override
  void initState() {
    super.initState();
    vm = EditorViewModel(widget.initial);
    keys.addAll(vm.options.map((_) => Object()));
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  Future<void> proceed(bool save) async {
    final decision = vm.validate();
    if (decision == null) {
      setState(() => error = 'Add a title and at least two nonempty options.');
      return;
    }
    setState(() => saving = true);
    try {
      if (save) await ref.read(appViewModelProvider.notifier).save(decision);
      if (mounted) context.push('/pick', extra: decision);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Could not save your list. Please try again.');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.initial == null ? 'A new possibility' : 'Make it yours',
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'What’s the question?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Every good decision starts with a few possibilities.'),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: vm.title,
              onChanged: (v) => vm.title = v,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Decision title',
                hintText: 'What should I eat?',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'YOUR OPTIONS  •  DRAG TO REORDER',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: vm.options.length,
              onReorderItem: (a, b) => setState(() {
                final target = b;
                keys.insert(target, keys.removeAt(a));
                vm.reorder(a, b > a ? b + 1 : b);
              }),
              itemBuilder: (context, i) => Padding(
                key: ValueKey(keys[i]),
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.drag_indicator),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: vm.options[i],
                        onChanged: (v) => vm.options[i] = v,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: 'Option ${i + 1}',
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove option',
                      onPressed: () => setState(() {
                        keys.removeAt(i);
                        vm.remove(i);
                      }),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                keys.add(Object());
                vm.add();
              }),
              icon: const Icon(Icons.add),
              label: const Text('Add another option'),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: saving ? null : () => proceed(true),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save list & let’s pick'),
            ),
            TextButton(
              onPressed: saving ? null : () => proceed(false),
              child: const Text('Just pick this once'),
            ),
          ],
        ),
      ),
    ),
  );
}
