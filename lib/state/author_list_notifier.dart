import '../models/author.dart';
import '../models/author_query.dart';
import '../repositories/author_repository.dart';
import 'entity_list_notifier.dart';

class AuthorListNotifier extends EntityListNotifier<Author, AuthorQuery> {
  AuthorListNotifier(AuthorRepository repository)
      : super(repository, AuthorQuery(), (a) => a.id);
}
