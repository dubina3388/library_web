import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/author.dart';
import 'models/author_query.dart';
import 'models/book.dart';
import 'models/book_query.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'screens/author_details_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/book_details_screen.dart';
import 'screens/books_screen.dart';
import 'screens/not_found_screen.dart';
import 'state/details_notifier.dart';

Page<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);

Widget _details<T>(
  GoRouterState state,
  Future<T?> Function(BuildContext context, int id) load,
  Widget screen,
) {
  final id = int.tryParse(state.pathParameters['id'] ?? '');
  if (id == null) return NotFoundScreen(location: state.uri.toString());
  return ChangeNotifierProvider(
    key: ValueKey(state.uri.toString()),
    create: (context) => DetailsNotifier<T>(() => load(context, id))..load(),
    child: screen,
  );
}

final appRouter = GoRouter(
  initialLocation: '/books',
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/books'),
    GoRoute(
      path: '/books',
      pageBuilder: (context, state) => _page(
        state,
        BooksScreen(query: BookQuery.fromParams(state.uri.queryParameters)),
      ),
      routes: [
        GoRoute(
          path: ':id',
          pageBuilder: (context, state) => _page(
            state,
            _details<Book>(
              state,
              (context, id) => context.read<BookRepository>().findById(id),
              const BookDetailsScreen(),
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/authors',
      pageBuilder: (context, state) => _page(
        state,
        AuthorsScreen(query: AuthorQuery.fromParams(state.uri.queryParameters)),
      ),
      routes: [
        GoRoute(
          path: ':id',
          pageBuilder: (context, state) => _page(
            state,
            _details<Author>(
              state,
              (context, id) => context.read<AuthorRepository>().findById(id),
              const AuthorDetailsScreen(),
            ),
          ),
        ),
      ],
    ),
  ],
  errorPageBuilder: (context, state) =>
      _page(state, NotFoundScreen(location: state.uri.toString())),
);
