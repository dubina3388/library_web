import '../models/book.dart';
import '../models/book_query.dart';
import '../repositories/book_repository.dart';
import 'entity_list_notifier.dart';

class BookListNotifier extends EntityListNotifier<Book, BookQuery> {
  BookListNotifier(BookRepository repository)
      : super(repository, BookQuery(), (b) => b.id);
}
