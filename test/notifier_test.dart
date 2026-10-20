import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/models/book_query.dart';
import 'package:library_web/repositories/entity_repository.dart';
import 'package:library_web/repositories/in_memory_book_repository.dart';
import 'package:library_web/state/book_list_notifier.dart';
import 'package:library_web/state/entity_list_notifier.dart';

void main() {
  late FaultInjector faults;
  late BookListNotifier notifier;

  setUp(() {
    faults = FaultInjector();
    notifier = BookListNotifier(
        InMemoryBookRepository(faults: faults, latency: Duration.zero));
  });

  test('успешная загрузка', () async {
    expect(notifier.status, LoadStatus.idle);
    final future = notifier.load();
    expect(notifier.status, LoadStatus.loading);
    await future;
    expect(notifier.status, LoadStatus.success);
    expect(notifier.result.items.length, 10);
  });

  test('пустой результат отличается от загрузки и от ошибки', () async {
    await notifier.applyQuery(BookQuery(search: 'нет такой книги'));
    expect(notifier.status, LoadStatus.success);
    expect(notifier.isEmpty, isTrue);
  });

  test('ошибка загрузки переводит экран в состояние error', () async {
    faults.enabled = true;
    await notifier.load();
    expect(notifier.status, LoadStatus.error);
    expect(notifier.error, contains('имитация сбоя'));
  });

  test('смена условий отбора очищает выделение', () async {
    await notifier.load();
    notifier.toggleSelection(1);
    notifier.toggleSelection(2);
    expect(notifier.selected, {1, 2});
    await notifier.applyQuery(notifier.query.copyWith(genreId: 1));
    expect(notifier.selected, isEmpty);
  });

  test('удаление выбранных записей', () async {
    await notifier.load();
    final ids = notifier.result.items.take(3).map((b) => b.id).toList();
    ids.forEach(notifier.toggleSelection);
    final deleted = await notifier.deleteSelected();
    expect(deleted, 3);
    expect(notifier.hasSelection, isFalse);
    expect(notifier.result.total, 23);
  });
}
