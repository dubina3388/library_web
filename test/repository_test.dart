import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/models/author_query.dart';
import 'package:library_web/models/book_query.dart';
import 'package:library_web/repositories/entity_repository.dart';
import 'package:library_web/repositories/in_memory_author_repository.dart';
import 'package:library_web/repositories/in_memory_book_repository.dart';
import 'package:library_web/repositories/seed_data.dart';

void main() {
  late InMemoryBookRepository books;
  late InMemoryAuthorRepository authors;

  setUp(() {
    books = InMemoryBookRepository(latency: Duration.zero);
    authors = InMemoryAuthorRepository(latency: Duration.zero);
  });

  test('начальный набор: не менее 20 книг и 8 авторов', () {
    expect(seedBooks.length, greaterThanOrEqualTo(20));
    expect(seedAuthors.length, greaterThanOrEqualTo(8));
  });

  test('поиск книг по названию и по ISBN без учёта регистра', () async {
    final byTitle = await books.find(BookQuery(search: 'МАСТЕР'));
    expect(byTitle.items.single.title, 'Мастер и Маргарита');
    final byIsbn = await books.find(BookQuery(search: '978-5-04-157843'));
    expect(byIsbn.items.single.title, '451 градус по Фаренгейту');
  });

  test('фильтры комбинируются между собой и с поиском', () async {
    final page = await books.find(BookQuery(
      genreId: 5,
      publisherId: 1,
      yearFrom: 2016,
      yearTo: 2020,
    ));
    expect(page.items.map((b) => b.title),
        containsAll(['Пикник на обочине', 'Трудно быть богом']));
    for (final b in page.items) {
      expect(b.genreIds, contains(5));
      expect(b.publisherId, 1);
      expect(b.year, inInclusiveRange(2016, 2020));
    }
    final withSearch = await books.find(BookQuery(
        genreId: 5, publisherId: 1, yearFrom: 2016, yearTo: 2020, search: 'бог'));
    expect(withSearch.total, 1);
  });

  test('постраничный вывод', () async {
    final first = await books.find(BookQuery());
    expect(first.total, seedBooks.length);
    expect(first.items.length, 10);
    expect(first.totalPages, 3);
    expect(first.hasPrevious, isFalse);
    final last = await books.find(BookQuery(page: 3));
    expect(last.items.length, seedBooks.length - 20);
    expect(last.hasNext, isFalse);
    final beyond = await books.find(BookQuery(page: 9));
    expect(beyond.items, isEmpty);
    final big = await books.find(BookQuery(size: 50));
    expect(big.items.length, seedBooks.length);
  });

  test('сортировка по году по убыванию', () async {
    final page = await books
        .find(BookQuery(sortField: 'year', sortAscending: false, size: 50));
    final years = page.items.map((b) => b.year).toList();
    expect(years, [...years]..sort((a, b) => b.compareTo(a)));
  });

  test('deleteMany помечает только ещё не удалённые записи', () async {
    await books.softDelete(1);
    final count = await books.deleteMany([1, 2, 3, 999]);
    expect(count, 2);
    final page = await books.find(BookQuery(size: 50));
    expect(page.items.map((b) => b.id), isNot(contains(2)));
    expect(page.total, seedBooks.length - 3);
  });

  test('логическое удаление, восстановление и физическое удаление', () async {
    await books.softDelete(5);
    expect((await books.find(BookQuery(size: 50))).total, seedBooks.length - 1);
    final withDeleted =
        await books.find(BookQuery(size: 50, includeDeleted: true));
    expect(withDeleted.total, seedBooks.length);
    expect((await books.findById(5))!.isDeleted, isTrue);

    await books.restore(5);
    expect((await books.findById(5))!.isDeleted, isFalse);

    await books.hardDelete(5);
    expect(await books.findById(5), isNull);
    expect((await books.find(BookQuery(size: 50, includeDeleted: true))).total,
        seedBooks.length - 1);
  });

  test('поиск авторов по фамилии и стране, фильтр по стране', () async {
    expect((await authors.find(AuthorQuery(search: 'стругацк'))).total, 2);
    expect((await authors.find(AuthorQuery(search: 'британ'))).total, 3);
    final germany = await authors.find(AuthorQuery(country: 'Германия'));
    expect(germany.items.single.lastName, 'Ремарк');
  });

  test('имитация сбоя приводит к исключению', () async {
    final faults = FaultInjector()..enabled = true;
    final failing =
        InMemoryBookRepository(faults: faults, latency: Duration.zero);
    expect(() => failing.find(BookQuery()), throwsA(isA<RepositoryException>()));
  });
}
