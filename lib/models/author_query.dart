import 'list_query.dart';

class AuthorQuery extends ListQuery<AuthorQuery> {
  static const sortFields = {'lastName', 'firstName', 'country', 'birthYear'};
  static const defaultSort = 'lastName';

  @override
  final String search;
  final String? country;
  @override
  final String sortField;
  @override
  final bool sortAscending;
  @override
  final int page;
  @override
  final int size;
  @override
  final bool includeDeleted;

  AuthorQuery({
    this.search = '',
    this.country,
    this.sortField = defaultSort,
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  factory AuthorQuery.fromParams(Map<String, String> params) {
    final (field, ascending) =
        parseSort(params['sort'], sortFields, defaultSort);
    final country = params['country']?.trim();
    return AuthorQuery(
      search: params['search'] ?? '',
      country: country == null || country.isEmpty ? null : country,
      sortField: field,
      sortAscending: ascending,
      page: parsePage(params['page']),
      size: parseSize(params['size']),
      includeDeleted: params['deleted'] == '1',
    );
  }

  @override
  String get path => '/authors';

  @override
  AuthorQuery copyWith({
    String? search,
    Object? country = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return AuthorQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();

  @override
  Map<String, String> filterParams() => {
        'country': ?country,
      };

  @override
  bool get hasFilters => search.trim().isNotEmpty || country != null;

  @override
  AuthorQuery cleared() => AuthorQuery(
        sortField: sortField,
        sortAscending: sortAscending,
        size: size,
        includeDeleted: includeDeleted,
      );

  @override
  String toLocation() => location(defaultSort);

  @override
  bool operator ==(Object other) =>
      other is AuthorQuery && other.toLocation() == toLocation();

  @override
  int get hashCode => toLocation().hashCode;
}
