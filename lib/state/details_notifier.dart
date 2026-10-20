import 'package:flutter/foundation.dart';

import 'entity_list_notifier.dart';

class DetailsNotifier<T> extends ChangeNotifier {
  final Future<T?> Function() _loader;

  DetailsNotifier(this._loader);

  T? _item;
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  T? get item => _item;
  LoadStatus get status => _status;
  String? get error => _error;
  bool get notFound => _status == LoadStatus.success && _item == null;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _item = await _loader();
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить запись: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }
}
