import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

class NotFoundScreen extends StatelessWidget {
  final String location;

  const NotFoundScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      section: Section.none,
      title: 'Страница не найдена',
      child: MessageView(
        icon: Icons.explore_off,
        title: '404',
        message: 'Адрес $location не существует.',
        actionLabel: 'К каталогу книг',
        onAction: () => context.go('/books'),
      ),
    );
  }
}
