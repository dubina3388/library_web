import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../state/book_list_notifier.dart';
import '../state/details_notifier.dart';
import '../state/lookup_notifier.dart';
import '../widgets/app_shell.dart';
import '../widgets/details_layout.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DetailsNotifier<Book>>();
    final lookups = context.watch<LookupNotifier>();
    final theme = Theme.of(context);
    return AppShell(
      section: Section.books,
      title: 'Карточка книги',
      child: DetailsLayout<Book>(
        notifier: notifier,
        notFoundText: 'Книги с таким номером нет в каталоге.',
        backLabel: 'К списку книг',
        onBack: () =>
            context.go(context.read<BookListNotifier>().query.toLocation()),
        builder: (book) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: theme.textTheme.headlineSmall),
                if (book.isDeleted) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Запись удалена'),
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
                ],
                const Divider(height: 24),
                InfoRow(
                  label: 'Авторы',
                  value: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final id in book.authorIds)
                        ActionChip(
                          avatar: const Icon(Icons.person, size: 18),
                          label: Text(lookups.author(id)?.fullName ?? '№ $id'),
                          onPressed: () => context.go('/authors/$id'),
                        ),
                    ],
                  ),
                ),
                InfoRow.text(label: 'ISBN', text: book.isbn),
                InfoRow.text(label: 'Год издания', text: '${book.year}'),
                InfoRow.text(label: 'Страниц', text: '${book.pages}'),
                InfoRow.text(
                  label: 'Жанр',
                  text: lookups.genreNames(book.genreIds),
                ),
                InfoRow.text(
                  label: 'Издательство',
                  text: lookups.publisherName(book.publisherId),
                ),
                InfoRow.text(
                  label: 'Экземпляры',
                  text: 'в наличии ${book.copiesAvailable} из ${book.copiesTotal}',
                ),
                InfoRow.text(label: 'Идентификатор', text: '${book.id}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
