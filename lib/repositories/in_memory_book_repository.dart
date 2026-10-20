import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'book_repository.dart';
import 'entity_repository.dart';
import 'seed_data.dart';

class InMemoryBookRepository implements BookRepository {
  final FaultInjector faults;
  final Duration latency;
  final List<Book> _books = [...seedBooks];
  int _nextId = seedBooks.length + 1;

  InMemoryBookRepository({
    FaultInjector? faults,
    this.latency = const Duration(milliseconds: 250),
  }) : faults = faults ?? FaultInjector();

  @override
  Future<PageResult<Book>> find(BookQuery q) async {
    await Future.delayed(latency);
    faults.check();

    var rows = _books.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) =>
              b.title.toLowerCase().contains(needle) ||
              b.isbn.toLowerCase().contains(needle))
          .toList();
    }

    if (q.authorId != null) {
      rows = rows.where((b) => b.authorIds.contains(q.authorId)).toList();
    }
    if (q.genreId != null) {
      rows = rows.where((b) => b.genreIds.contains(q.genreId)).toList();
    }
    if (q.publisherId != null) {
      rows = rows.where((b) => b.publisherId == q.publisherId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((b) => b.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((b) => b.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'pages' => a.pages.compareTo(b.pages),
        'copies' => a.copiesAvailable.compareTo(b.copiesAvailable),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      final ordered = q.sortAscending ? result : -result;
      return ordered != 0 ? ordered : a.id.compareTo(b.id);
    });

    return PageResult.slice(rows, q.page, q.size);
  }

  @override
  Future<Book?> findById(int id) async {
    await Future.delayed(latency);
    faults.check();
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<Book> create(Book book) async {
    final created = book.copyWith(id: _nextId++);
    _books.add(created);
    return created;
  }

  @override
  Future<Book> update(Book book) async {
    final i = _books.indexWhere((b) => b.id == book.id);
    if (i == -1) throw RepositoryException('Книга ${book.id} не найдена');
    _books[i] = book;
    return book;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw RepositoryException('Книга $id не найдена');
    _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _books.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw RepositoryException('Книга $id не найдена');
    _books[i] = _books[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
