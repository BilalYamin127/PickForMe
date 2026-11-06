import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../decisions/view_models/app_view_model.dart';
import '../../../shared/widgets/page_frame.dart';

class LibraryView extends ConsumerWidget {
  final bool history;
  const LibraryView({super.key, this.history = false});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appViewModelProvider);
    final vm = ref.read(appViewModelProvider.notifier);
    return PageFrame(
      title: history ? 'Your decision diary' : 'Your possibility collection',
      index: history ? 2 : 1,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  history
                      ? 'A look back at chance.'
                      : 'Good lists deserve another spin.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (history)
                IconButton(
                  tooltip: 'Clear history',
                  onPressed: state.history.isEmpty
                      ? null
                      : () async {
                          if (await confirmClear(context)) {
                            await vm.clearHistory();
                          }
                        },
                  icon: const Icon(Icons.delete_sweep_outlined),
                )
              else
                IconButton(
                  tooltip: 'New list',
                  onPressed: () => context.push('/create'),
                  icon: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (history && state.history.isEmpty ||
              !history && state.lists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'A blank page, full of possibilities.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (history)
            ...state.history.map(
              (e) => Card(
                child: ListTile(
                  leading: Icon(
                    e.selectionMode.name == 'wheel'
                        ? Icons.pie_chart
                        : Icons.shuffle,
                  ),
                  title: Text(e.selectedOption),
                  subtitle: Text(
                    '${e.decisionTitle}\n${_date(e.createdAt)} • ${e.selectionMode.name}',
                  ),
                  isThreeLine: true,
                  onTap: () => context.push('/result', extra: e),
                ),
              ),
            )
          else
            ...state.lists.map(
              (e) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.pie_chart_outline),
                  ),
                  title: Text(e.title),
                  subtitle: Text(
                    '${e.options.length} options • ${e.options.take(3).join(', ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.push('/pick', extra: e),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'List actions',
                    onSelected: (action) async {
                      switch (action) {
                        case 'edit':
                          context.push('/create', extra: e);
                        case 'duplicate':
                          await vm.duplicate(e);
                        case 'delete':
                          final yes = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text('Delete ${e.title}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (yes == true) await vm.delete(e.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit list')),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _date(DateTime date) {
    final d = date.toLocal();
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
