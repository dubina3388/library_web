const pageSizes = [10, 25, 50];

abstract class ListQuery<Q extends ListQuery<Q>> {
  String get path;
  String get search;
  String get sortField;
  bool get sortAscending;
  int get page;
  int get size;
  bool get includeDeleted;

  Q copyWith({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  });

  Map<String, String> filterParams();

  Q cleared();

  bool get hasFilters;

  String toLocation();

  Q toPage(int value) => copyWith(page: value);

  Q sortedBy(String field) => copyWith(
        sortField: field,
        sortAscending: field == sortField ? !sortAscending : true,
      );

  Map<String, String> toParams(String defaultSort) {
    final sort = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    return {
      if (search.trim().isNotEmpty) 'search': search.trim(),
      ...filterParams(),
      if (sort != '$defaultSort,asc') 'sort': sort,
      if (page != 1) 'page': '$page',
      if (size != pageSizes.first) 'size': '$size',
      if (includeDeleted) 'deleted': '1',
    };
  }

  String location(String defaultSort) {
    final params = toParams(defaultSort);
    return Uri(path: path, queryParameters: params.isEmpty ? null : params)
        .toString();
  }
}

int? parseInt(String? raw) => raw == null ? null : int.tryParse(raw.trim());

int parsePage(String? raw) {
  final value = parseInt(raw);
  return value == null || value < 1 ? 1 : value;
}

int parseSize(String? raw) {
  final value = parseInt(raw);
  return pageSizes.contains(value) ? value! : pageSizes.first;
}

(String, bool) parseSort(String? raw, Set<String> allowed, String fallback) {
  if (raw == null) return (fallback, true);
  final parts = raw.split(',');
  final field = parts.first.trim();
  if (!allowed.contains(field)) return (fallback, true);
  final ascending = parts.length < 2 || parts[1].trim().toLowerCase() != 'desc';
  return (field, ascending);
}
