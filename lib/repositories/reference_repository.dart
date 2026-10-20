import '../models/reference.dart';
import 'seed_data.dart';

abstract interface class ReferenceRepository {
  Future<List<Genre>> genres();
  Future<List<Publisher>> publishers();
}

class InMemoryReferenceRepository implements ReferenceRepository {
  @override
  Future<List<Genre>> genres() async => List.unmodifiable(seedGenres);

  @override
  Future<List<Publisher>> publishers() async =>
      List.unmodifiable(seedPublishers);
}
