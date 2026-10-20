import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/book_query.dart';
import '../state/book_list_notifier.dart';
import '../state/lookup_notifier.dart';
import '../widgets/app_shell.dart';
import '../widgets/debounced_field.dart';
import '../widgets/entity_list_page.dart';
import '../widgets/entity_table.dart';
import '../widgets/filter_dropdown.dart';

class BooksScreen extends StatelessWidget {
  final BookQuery query;

  const BooksScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final lookups = context.watch<LookupNotifier>();
    return AppShell(
      section: Section.books,
      title: 'Каталог книг',
      child: EntityListPage<Book, BookQuery>(
        query: query,
        notifier: notifier,
        searchLabel: 'Поиск по названию или ISBN',
        itemLabel: (b) => b.title,
        detailsLocation: (b) => '/books/${b.id}',
        isDeleted: (b) => b.isDeleted,
        cardTitle: (b) => b.title,
        cardSubtitle: (b) => '${lookups.authorNames(b.authorIds)} · ${b.year} · '
            '${b.pages} стр.\n${lookups.genreNames(b.genreIds)} · '
            '${lookups.publisherName(b.publisherId)} · '
            'в наличии ${b.copiesAvailable} из ${b.copiesTotal}',
        activeFilterCount: (q) => [
          q.authorId,
          q.genreId,
          q.publisherId,
          q.yearFrom,
          q.yearTo,
        ].where((v) => v != null).length,
        filters: (q, apply) => [
          if (q.authorId != null)
            InputChip(
              avatar: const Icon(Icons.person, size: 18),
              label: Text(
                'Автор: ${lookups.author(q.authorId!)?.shortName ?? q.authorId}',
              ),
              onDeleted: () => apply(q.copyWith(authorId: null)),
            ),
          FilterDropdown<int>(
            label: 'Жанр',
            allLabel: 'Все жанры',
            value: q.genreId,
            options: [for (final g in lookups.genres) (g.id, g.name)],
            onChanged: (id) => apply(q.copyWith(genreId: id)),
          ),
          FilterDropdown<int>(
            label: 'Издательство',
            allLabel: 'Все издательства',
            value: q.publisherId,
            options: [for (final p in lookups.publishers) (p.id, p.name)],
            onChanged: (id) => apply(q.copyWith(publisherId: id)),
          ),
          DebouncedField(
            label: 'Год с',
            width: 110,
            digitsOnly: true,
            value: q.yearFrom?.toString() ?? '',
            onChanged: (t) => apply(q.copyWith(yearFrom: int.tryParse(t))),
          ),
          DebouncedField(
            label: 'Год по',
            width: 110,
            digitsOnly: true,
            value: q.yearTo?.toString() ?? '',
            onChanged: (t) => apply(q.copyWith(yearTo: int.tryParse(t))),
          ),
        ],
        columns: [
          TableColumnSpec(
            label: 'Название',
            sortField: 'title',
            build: (b) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(b.title, overflow: TextOverflow.ellipsis),
            ),
          ),
          TableColumnSpec(
            label: 'Авторы',
            build: (b) => Text(lookups.authorNames(b.authorIds)),
          ),
          TableColumnSpec(
            label: 'Год',
            sortField: 'year',
            numeric: true,
            build: (b) => Text('${b.year}'),
          ),
          TableColumnSpec(
            label: 'Страниц',
            sortField: 'pages',
            numeric: true,
            build: (b) => Text('${b.pages}'),
          ),
          TableColumnSpec(
            label: 'Жанр',
            build: (b) => Text(lookups.genreNames(b.genreIds)),
          ),
          TableColumnSpec(
            label: 'Издательство',
            build: (b) => Text(lookups.publisherName(b.publisherId)),
          ),
          TableColumnSpec(
            label: 'В наличии',
            sortField: 'copies',
            numeric: true,
            build: (b) => Text('${b.copiesAvailable} / ${b.copiesTotal}'),
          ),
        ],
      ),
    );
  }
}
