import 'package:flutter/foundation.dart';

class NfcProvider with ChangeNotifier {
  String? _pendingRoute;

  String? get pendingRoute => _pendingRoute;

  void setPendingRoute(String? route) {
    _pendingRoute = route;
    notifyListeners(); // 필요하다면 UI 업데이트 가능
  }

  void clearPendingRoute() {
    _pendingRoute = null;
    notifyListeners();
  }
}
