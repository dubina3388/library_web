import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/author_query.dart';
import '../state/author_list_notifier.dart';
import '../state/lookup_notifier.dart';
import '../widgets/app_shell.dart';
import '../widgets/entity_list_page.dart';
import '../widgets/entity_table.dart';
import '../widgets/filter_dropdown.dart';

class AuthorsScreen extends StatelessWidget {
  final AuthorQuery query;

  const AuthorsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final lookups = context.watch<LookupNotifier>();
    return AppShell(
      section: Section.authors,
      title: 'Авторы',
      child: EntityListPage<Author, AuthorQuery>(
        query: query,
        notifier: notifier,
        searchLabel: 'Поиск по фамилии или стране',
        itemLabel: (a) => a.fullName,
        detailsLocation: (a) => '/authors/${a.id}',
        isDeleted: (a) => a.isDeleted,
        cardTitle: (a) => a.fullName,
        cardSubtitle: (a) => '${a.country} · ${a.birthYear} г. р.',
        onDataChanged: context.read<LookupNotifier>().load,
        activeFilterCount: (q) => q.country == null ? 0 : 1,
        filters: (q, apply) => [
          FilterDropdown<String>(
            label: 'Страна',
            allLabel: 'Все страны',
            value: q.country,
            options: [for (final c in lookups.countries) (c, c)],
            onChanged: (c) => apply(q.copyWith(country: c)),
          ),
        ],
        columns: [
          TableColumnSpec(
            label: 'Фамилия',
            sortField: 'lastName',
            build: (a) => Text(a.lastName),
          ),
          TableColumnSpec(
            label: 'Имя',
            sortField: 'firstName',
            build: (a) => Text(a.firstName),
          ),
          TableColumnSpec(
            label: 'Отчество',
            build: (a) => Text(a.middleName.isEmpty ? '—' : a.middleName),
          ),
          TableColumnSpec(
            label: 'Страна',
            sortField: 'country',
            build: (a) => Text(a.country),
          ),
          TableColumnSpec(
            label: 'Год рождения',
            sortField: 'birthYear',
            numeric: true,
            build: (a) => Text('${a.birthYear}'),
          ),
        ],
      ),
    );
  }
}
