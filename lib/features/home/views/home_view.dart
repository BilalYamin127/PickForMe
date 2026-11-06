import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../decisions/view_models/app_view_model.dart';
import '../../../data/models/decision.dart';
import '../../../shared/widgets/page_frame.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appViewModelProvider);
    return PageFrame(
      title: '✳ PickForMe',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'LESS OVERTHINKING. MORE LIVING.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: Color(0xff8170c9),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Big choices.\nLittle spins.',
            style: Theme.of(context).textTheme.displayMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -2),
          ),
          const SizedBox(height: 12),
          const Text(
            'Can’t choose? Leave a little room for chance.',
            style: TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff7154dc), Color(0xffab76e9)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.casino_rounded, color: Colors.white, size: 44),
                const SizedBox(height: 18),
                const Text(
                  'Your next “that’s the one!”',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your options. Give it a spin. Let fate do its thing.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xff6546c7),
                  ),
                  onPressed: () => context.push('/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Start a new decision'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'A little inspiration',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _starter(context, '🍕', 'What’s for dinner?', [
                'Pizza',
                'Sushi',
                'Tacos',
                'Pasta',
                'Burgers',
                'Salad',
              ]),
              _starter(context, '🎬', 'Movie night', [
                'Comedy',
                'Thriller',
                'Animation',
                'Adventure',
              ]),
              _starter(context, '🎲', 'What should we play?', [
                'Cards',
                'Board game',
                'Video game',
                'Charades',
              ]),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent little victories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/history'),
                child: const Text('View all'),
              ),
            ],
          ),
          if (state.history.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Your first decision is a spin away. ✨'),
              ),
            ),
          ...state.history
              .take(3)
              .map(
                (e) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.auto_awesome),
                    ),
                    title: Text(e.selectedOption),
                    subtitle: Text(e.decisionTitle),
                    onTap: () => context.push('/result', extra: e),
                  ),
                ),
              ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Made for indecisive humans.  •  100% offline',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _starter(
    BuildContext context,
    String emoji,
    String title,
    List<String> options,
  ) => ActionChip(
    label: Text('$emoji  $title'),
    onPressed: () => context.push(
      '/create',
      extra: DecisionList(
        id: newId(),
        title: title,
        options: options,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
  );
}
