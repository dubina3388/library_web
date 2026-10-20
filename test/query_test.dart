import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/models/author_query.dart';
import 'package:library_web/models/book_query.dart';

void main() {
  group('BookQuery и адрес', () {
    test('разбирает адрес со всеми условиями отбора', () {
      final uri = Uri.parse(
          '/books?search=война&genreId=2&publisherId=1&yearFrom=2015&yearTo=2020&sort=year,desc&page=3&size=25&deleted=1');
      final q = BookQuery.fromParams(uri.queryParameters);
      expect(q.search, 'война');
      expect(q.genreId, 2);
      expect(q.publisherId, 1);
      expect(q.yearFrom, 2015);
      expect(q.yearTo, 2020);
      expect(q.sortField, 'year');
      expect(q.sortAscending, isFalse);
      expect(q.page, 3);
      expect(q.size, 25);
      expect(q.includeDeleted, isTrue);
    });

    test('адрес по умолчанию не содержит лишних параметров', () {
      expect(BookQuery().toLocation(), '/books');
    });

    test('состояние восстанавливается из собственного адреса', () {
      final q = BookQuery(
        search: 'мир',
        genreId: 1,
        yearFrom: 2010,
        sortField: 'pages',
        sortAscending: false,
        page: 2,
      );
      final restored =
          BookQuery.fromParams(Uri.parse(q.toLocation()).queryParameters);
      expect(restored, q);
      expect(restored.page, 2);
    });

    test('некорректные значения заменяются значениями по умолчанию', () {
      final q = BookQuery.fromParams(
          {'page': '-4', 'size': '13', 'sort': 'hack,desc', 'genreId': 'x'});
      expect(q.page, 1);
      expect(q.size, 10);
      expect(q.sortField, 'title');
      expect(q.sortAscending, isTrue);
      expect(q.genreId, isNull);
    });

    test('смена условий отбора возвращает на первую страницу', () {
      final q = BookQuery(page: 5, genreId: 3);
      expect(q.copyWith(search: 'а').page, 1);
      expect(q.copyWith(size: 25).page, 1);
      expect(q.toPage(4).page, 4);
    });

    test('copyWith отличает «не передан» от «сбросить в null»', () {
      final q = BookQuery(genreId: 3, publisherId: 2);
      expect(q.copyWith(search: 'x').genreId, 3);
      expect(q.copyWith(genreId: null).genreId, isNull);
      expect(q.copyWith(genreId: null).publisherId, 2);
    });

    test('повторная сортировка по тому же полю меняет направление', () {
      final q = BookQuery();
      expect(q.sortedBy('title').sortAscending, isFalse);
      expect(q.sortedBy('year').sortField, 'year');
      expect(q.sortedBy('year').sortAscending, isTrue);
    });
  });

  test('AuthorQuery хранит страну в адресе', () {
    final q = AuthorQuery(country: 'Россия', sortField: 'birthYear');
    final restored =
        AuthorQuery.fromParams(Uri.parse(q.toLocation()).queryParameters);
    expect(restored.country, 'Россия');
    expect(restored.sortField, 'birthYear');
    expect(restored.copyWith(country: null).country, isNull);
  });
}
