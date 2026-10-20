import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import 'author_repository.dart';
import 'entity_repository.dart';
import 'seed_data.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  final FaultInjector faults;
  final Duration latency;
  final List<Author> _authors = [...seedAuthors];
  int _nextId = seedAuthors.length + 1;

  InMemoryAuthorRepository({
    FaultInjector? faults,
    this.latency = const Duration(milliseconds: 250),
  }) : faults = faults ?? FaultInjector();

  @override
  Future<PageResult<Author>> find(AuthorQuery q) async {
    await Future.delayed(latency);
    faults.check();

    var rows =
        _authors.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((a) =>
              a.lastName.toLowerCase().contains(needle) ||
              a.country.toLowerCase().contains(needle))
          .toList();
    }

    if (q.country != null) {
      rows = rows.where((a) => a.country == q.country).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'firstName' => a.firstName.compareTo(b.firstName),
        'country' => a.country.compareTo(b.country),
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        _ => a.lastName.compareTo(b.lastName),
      };
      final ordered = q.sortAscending ? result : -result;
      return ordered != 0 ? ordered : a.id.compareTo(b.id);
    });

    return PageResult.slice(rows, q.page, q.size);
  }

  @override
  Future<List<Author>> all() async => List.unmodifiable(_authors);

  @override
  Future<Author?> findById(int id) async {
    await Future.delayed(latency);
    faults.check();
    for (final author in _authors) {
      if (author.id == id) return author;
    }
    return null;
  }

  @override
  Future<Author> create(Author author) async {
    final created = author.copyWith(id: _nextId++);
    _authors.add(created);
    return created;
  }

  @override
  Future<Author> update(Author author) async {
    final i = _authors.indexWhere((a) => a.id == author.id);
    if (i == -1) throw RepositoryException('Автор ${author.id} не найден');
    _authors[i] = author;
    return author;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw RepositoryException('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _authors.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw RepositoryException('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
