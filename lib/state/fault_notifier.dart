import 'package:flutter/foundation.dart';

import '../repositories/entity_repository.dart';

class FaultNotifier extends ChangeNotifier {
  final FaultInjector _injector;

  FaultNotifier(this._injector);

  bool get enabled => _injector.enabled;

  void toggle() {
    _injector.enabled = !_injector.enabled;
    notifyListeners();
  }
}
