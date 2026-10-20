import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book_query.dart';
import '../state/author_list_notifier.dart';
import '../state/details_notifier.dart';
import '../widgets/app_shell.dart';
import '../widgets/details_layout.dart';

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DetailsNotifier<Author>>();
    final theme = Theme.of(context);
    return AppShell(
      section: Section.authors,
      title: 'Карточка автора',
      child: DetailsLayout<Author>(
        notifier: notifier,
        notFoundText: 'Автора с таким номером нет в каталоге.',
        backLabel: 'К списку авторов',
        onBack: () =>
            context.go(context.read<AuthorListNotifier>().query.toLocation()),
        builder: (author) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author.fullName, style: theme.textTheme.headlineSmall),
                if (author.isDeleted) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Запись удалена'),
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
                ],
                const Divider(height: 24),
                InfoRow.text(label: 'Фамилия', text: author.lastName),
                InfoRow.text(label: 'Имя', text: author.firstName),
                InfoRow.text(
                  label: 'Отчество',
                  text: author.middleName.isEmpty ? '—' : author.middleName,
                ),
                InfoRow.text(label: 'Страна', text: author.country),
                InfoRow.text(label: 'Год рождения', text: '${author.birthYear}'),
                InfoRow.text(label: 'Идентификатор', text: '${author.id}'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () =>
                      context.go(BookQuery(authorId: author.id).toLocation()),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Книги автора в каталоге'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
