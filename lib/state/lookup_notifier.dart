import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../models/reference.dart';
import '../repositories/author_repository.dart';
import '../repositories/reference_repository.dart';

class LookupNotifier extends ChangeNotifier {
  final ReferenceRepository _references;
  final AuthorRepository _authors;

  LookupNotifier(this._references, this._authors);

  List<Genre> _genres = const [];
  List<Publisher> _publishers = const [];
  Map<int, Author> _authorById = const {};

  List<Genre> get genres => _genres;
  List<Publisher> get publishers => _publishers;
  List<Author> get authors => _authorById.values.toList();

  List<String> get countries =>
      (_authorById.values.map((a) => a.country).toSet().toList()..sort());

  Future<void> load() async {
    _genres = await _references.genres();
    _publishers = await _references.publishers();
    _authorById = {for (final a in await _authors.all()) a.id: a};
    notifyListeners();
  }

  String genreName(int id) =>
      _genres.where((g) => g.id == id).map((g) => g.name).firstOrNull ?? '—';

  String publisherName(int id) =>
      _publishers.where((p) => p.id == id).map((p) => p.name).firstOrNull ??
      '—';

  Author? author(int id) => _authorById[id];

  String authorNames(List<int> ids) =>
      ids.map((id) => _authorById[id]?.shortName ?? '—').join(', ');

  String genreNames(List<int> ids) => ids.map(genreName).join(', ');
}
