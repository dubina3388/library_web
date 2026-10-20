import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../state/fault_notifier.dart';

enum Section { books, authors, none }

class AppShell extends StatelessWidget {
  final Section section;
  final String title;
  final Widget child;

  const AppShell({
    super.key,
    required this.section,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final faults = context.watch<FaultNotifier>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: [
          _NavButton(
            label: 'Книги',
            icon: Icons.menu_book,
            selected: section == Section.books,
            compact: narrow,
            onPressed: () =>
                context.go(context.read<BookListNotifier>().query.toLocation()),
          ),
          _NavButton(
            label: 'Авторы',
            icon: Icons.people,
            selected: section == Section.authors,
            compact: narrow,
            onPressed: () => context
                .go(context.read<AuthorListNotifier>().query.toLocation()),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: faults.enabled
                ? 'Имитация сбоя сервера включена'
                : 'Включить имитацию сбоя сервера',
            color: faults.enabled ? scheme.error : null,
            icon: Icon(faults.enabled ? Icons.cloud_off : Icons.cloud_done),
            onPressed: () {
              context.read<FaultNotifier>().toggle();
              context.read<BookListNotifier>().load();
              context.read<AuthorListNotifier>().load();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: child),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final VoidCallback onPressed;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.compact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (compact) {
      return IconButton(
        tooltip: label,
        isSelected: selected,
        style: selected
            ? IconButton.styleFrom(backgroundColor: scheme.secondaryContainer)
            : null,
        icon: Icon(icon),
        onPressed: onPressed,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: selected
          ? FilledButton.tonalIcon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            )
          : TextButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }
}
