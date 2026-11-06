import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final int index;
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    this.index = 0,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Settings',
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: child,
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) => context.go(['/', '/saved', '/history'][i]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard_rounded),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmarks_outlined),
          selectedIcon: Icon(Icons.bookmarks_rounded),
          label: 'My lists',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
      ],
    ),
  );
}

Future<bool> confirmClear(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear your history?'),
        content: const Text('This permanently removes all past results.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep history'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Clear history'),
          ),
        ],
      ),
    ) ??
    false;
