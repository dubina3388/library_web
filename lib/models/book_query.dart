import 'list_query.dart';

class BookQuery extends ListQuery<BookQuery> {
  static const sortFields = {'title', 'year', 'pages', 'copies'};
  static const defaultSort = 'title';

  @override
  final String search;
  final int? authorId;
  final int? genreId;
  final int? publisherId;
  final int? yearFrom;
  final int? yearTo;
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

  BookQuery({
    this.search = '',
    this.authorId,
    this.genreId,
    this.publisherId,
    this.yearFrom,
    this.yearTo,
    this.sortField = defaultSort,
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  factory BookQuery.fromParams(Map<String, String> params) {
    final (field, ascending) =
        parseSort(params['sort'], sortFields, defaultSort);
    return BookQuery(
      search: params['search'] ?? '',
      authorId: parseInt(params['authorId']),
      genreId: parseInt(params['genreId']),
      publisherId: parseInt(params['publisherId']),
      yearFrom: parseInt(params['yearFrom']),
      yearTo: parseInt(params['yearTo']),
      sortField: field,
      sortAscending: ascending,
      page: parsePage(params['page']),
      size: parseSize(params['size']),
      includeDeleted: params['deleted'] == '1',
    );
  }

  @override
  String get path => '/books';

  @override
  BookQuery copyWith({
    String? search,
    Object? authorId = _unset,
    Object? genreId = _unset,
    Object? publisherId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BookQuery(
      search: search ?? this.search,
      authorId: authorId == _unset ? this.authorId : authorId as int?,
      genreId: genreId == _unset ? this.genreId : genreId as int?,
      publisherId:
          publisherId == _unset ? this.publisherId : publisherId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
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
        if (authorId != null) 'authorId': '$authorId',
        if (genreId != null) 'genreId': '$genreId',
        if (publisherId != null) 'publisherId': '$publisherId',
        if (yearFrom != null) 'yearFrom': '$yearFrom',
        if (yearTo != null) 'yearTo': '$yearTo',
      };

  @override
  bool get hasFilters =>
      search.trim().isNotEmpty ||
      authorId != null ||
      genreId != null ||
      publisherId != null ||
      yearFrom != null ||
      yearTo != null;

  @override
  BookQuery cleared() => BookQuery(
        sortField: sortField,
        sortAscending: sortAscending,
        size: size,
        includeDeleted: includeDeleted,
      );

  @override
  String toLocation() => location(defaultSort);

  @override
  bool operator ==(Object other) =>
      other is BookQuery && other.toLocation() == toLocation();

  @override
  int get hashCode => toLocation().hashCode;
}
